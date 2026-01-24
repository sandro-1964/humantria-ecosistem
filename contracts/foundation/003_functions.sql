-- HUMANTRÍA — FOUNDATION FUNCTIONS V1
-- Status: BLOQUEANTE
-- Escopo: Funções governadas (SECURITY INVOKER, sem bypass invisível)

SET search_path TO foundation, public;

-- ============================================================================
-- TENANCY
-- ============================================================================

-- Obter tenant_id do contexto (via JWT ou session)
CREATE OR REPLACE FUNCTION foundation.get_current_tenant_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- Tenta obter do JWT claim 'tenant_id'
    v_tenant_id := (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid;
    
    -- Se não encontrou no JWT, tenta da session
    IF v_tenant_id IS NULL THEN
        BEGIN
            v_tenant_id := current_setting('app.current_tenant_id', true)::uuid;
        EXCEPTION
            WHEN OTHERS THEN
                v_tenant_id := NULL;
        END;
    END IF;
    
    RETURN v_tenant_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;

COMMENT ON FUNCTION foundation.get_current_tenant_id() IS 'Retorna tenant_id do contexto (JWT ou session)';

-- Verificar se é Platform Owner
CREATE OR REPLACE FUNCTION foundation.is_platform_owner()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_role TEXT;
BEGIN
    v_role := current_setting('request.jwt.claims', true)::json->>'role';
    RETURN v_role = 'platform_owner';
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

COMMENT ON FUNCTION foundation.is_platform_owner() IS 'Verifica se o usuário atual é Platform Owner';

-- ============================================================================
-- AUDIT
-- ============================================================================

-- Registrar audit log técnico
CREATE OR REPLACE FUNCTION foundation.audit_log_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_user_id UUID;
    v_user_email TEXT;
    v_tenant_id UUID;
    v_changes JSONB;
BEGIN
    -- Obtém dados do contexto
    BEGIN
        v_user_id := (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid;
        v_user_email := current_setting('request.jwt.claims', true)::json->>'email';
    EXCEPTION
        WHEN OTHERS THEN
            v_user_id := NULL;
            v_user_email := NULL;
    END;
    
    v_tenant_id := foundation.get_current_tenant_id();
    
    -- Calcula mudanças (para UPDATE)
    IF TG_OP = 'UPDATE' THEN
        v_changes := jsonb_build_object(
            'old', to_jsonb(OLD),
            'new', to_jsonb(NEW)
        );
    ELSIF TG_OP = 'INSERT' THEN
        v_changes := jsonb_build_object('new', to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        v_changes := jsonb_build_object('old', to_jsonb(OLD));
    END IF;
    
    -- Insere no audit_log
    INSERT INTO foundation.audit_log (
        tenant_id,
        operation,
        table_schema,
        table_name,
        record_id,
        user_id,
        user_email,
        changes,
        ip_address,
        user_agent
    ) VALUES (
        v_tenant_id,
        TG_OP,
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        v_user_id,
        v_user_email,
        v_changes,
        inet_client_addr(),
        current_setting('request.headers', true)::json->>'user-agent'
    );
    
    RETURN COALESCE(NEW, OLD);
EXCEPTION
    WHEN OTHERS THEN
        RETURN COALESCE(NEW, OLD);
END;
$$;

COMMENT ON FUNCTION foundation.audit_log_insert() IS 'Trigger function para registrar audit log técnico';

-- Registrar audit log funcional (decisão/evidência)
CREATE OR REPLACE FUNCTION foundation.audit_log_functional_insert(
    p_decision_type TEXT,
    p_entity_type TEXT,
    p_entity_id UUID,
    p_context JSONB DEFAULT '{}'::jsonb,
    p_justification TEXT DEFAULT NULL,
    p_evidence_refs JSONB DEFAULT '[]'::jsonb,
    p_attachments JSONB DEFAULT '[]'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_user_id UUID;
    v_user_email TEXT;
    v_tenant_id UUID;
    v_audit_id UUID;
BEGIN
    BEGIN
        v_user_id := (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid;
        v_user_email := current_setting('request.jwt.claims', true)::json->>'email';
    EXCEPTION
        WHEN OTHERS THEN
            v_user_id := NULL;
            v_user_email := NULL;
    END;
    
    v_tenant_id := foundation.get_current_tenant_id();
    
    INSERT INTO foundation.audit_log_functional (
        tenant_id,
        decision_type,
        entity_type,
        entity_id,
        user_id,
        user_email,
        context,
        justification,
        evidence_refs,
        attachments
    ) VALUES (
        v_tenant_id,
        p_decision_type,
        p_entity_type,
        p_entity_id,
        v_user_id,
        v_user_email,
        p_context,
        p_justification,
        p_evidence_refs,
        p_attachments
    ) RETURNING id INTO v_audit_id;
    
    RETURN v_audit_id;
END;
$$;

COMMENT ON FUNCTION foundation.audit_log_functional_insert IS 'Registra decisão/evidência no audit log funcional';

-- ============================================================================
-- EVENTS
-- ============================================================================

-- Publicar evento no outbox
CREATE OR REPLACE FUNCTION foundation.publish_event(
    p_event_type TEXT,
    p_entity_type TEXT,
    p_entity_id UUID,
    p_payload JSONB,
    p_payload_version TEXT DEFAULT '1.0',
    p_correlation_id UUID DEFAULT NULL,
    p_causation_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_tenant_id UUID;
    v_event_id UUID;
BEGIN
    v_tenant_id := foundation.get_current_tenant_id();
    
    INSERT INTO foundation.events_outbox (
        correlation_id,
        causation_id,
        event_type,
        entity_type,
        entity_id,
        tenant_id,
        payload,
        payload_version
    ) VALUES (
        COALESCE(p_correlation_id, gen_random_uuid()),
        p_causation_id,
        p_event_type,
        p_entity_type,
        p_entity_id,
        v_tenant_id,
        p_payload,
        p_payload_version
    ) RETURNING id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION foundation.publish_event IS 'Publica evento no outbox (bridge-first)';

-- Marcar evento como processado
CREATE OR REPLACE FUNCTION foundation.mark_event_processed(
    p_event_id UUID,
    p_consumer_name TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
    UPDATE foundation.events_outbox
    SET status = 'processed',
        processed_at = NOW()
    WHERE id = p_event_id;
    
    UPDATE foundation.event_consumers
    SET last_processed_event_id = p_event_id,
        last_processed_at = NOW(),
        updated_at = NOW()
    WHERE consumer_name = p_consumer_name;
END;
$$;

COMMENT ON FUNCTION foundation.mark_event_processed IS 'Marca evento como processado e atualiza checkpoint do consumer';

-- Obter próximo lote de eventos pendentes
CREATE OR REPLACE FUNCTION foundation.get_next_events_batch(
    p_consumer_name TEXT,
    p_batch_size INTEGER DEFAULT 100
)
RETURNS TABLE (
    id UUID,
    correlation_id UUID,
    causation_id UUID,
    event_type TEXT,
    entity_type TEXT,
    entity_id UUID,
    tenant_id UUID,
    payload JSONB,
    payload_version TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_last_event_id UUID;
BEGIN
    -- Obtém último evento processado pelo consumer
    SELECT last_processed_event_id
    INTO v_last_event_id
    FROM foundation.event_consumers
    WHERE consumer_name = p_consumer_name;
    
    -- Retorna próximo lote
    RETURN QUERY
    SELECT 
        e.id,
        e.correlation_id,
        e.causation_id,
        e.event_type,
        e.entity_type,
        e.entity_id,
        e.tenant_id,
        e.payload,
        e.payload_version,
        e.created_at
    FROM foundation.events_outbox e
    WHERE e.status = 'pending'
        AND (v_last_event_id IS NULL OR e.id > v_last_event_id)
    ORDER BY e.created_at ASC
    LIMIT p_batch_size;
END;
$$;

COMMENT ON FUNCTION foundation.get_next_events_batch IS 'Retorna próximo lote de eventos pendentes para processamento';

-- Marcar evento como falha
CREATE OR REPLACE FUNCTION foundation.mark_event_failed(
    p_event_id UUID,
    p_error_message TEXT,
    p_max_retries INTEGER DEFAULT 3
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_retry_count INTEGER;
BEGIN
    SELECT retry_count INTO v_retry_count
    FROM foundation.events_outbox
    WHERE id = p_event_id;
    
    v_retry_count := COALESCE(v_retry_count, 0) + 1;
    
    IF v_retry_count >= p_max_retries THEN
        UPDATE foundation.events_outbox
        SET status = 'failed',
            retry_count = v_retry_count,
            error_message = p_error_message
        WHERE id = p_event_id;
    ELSE
        UPDATE foundation.events_outbox
        SET status = 'pending',
            retry_count = v_retry_count,
            error_message = p_error_message
        WHERE id = p_event_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION foundation.mark_event_failed IS 'Marca evento como falha e incrementa retry_count';

-- ============================================================================
-- TENANT SETTINGS
-- ============================================================================

-- Obter feature flag para tenant
CREATE OR REPLACE FUNCTION foundation.get_feature_flag(
    p_tenant_id UUID,
    p_flag_code TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_override_value BOOLEAN;
    v_default_value BOOLEAN;
BEGIN
    -- Tenta obter override do tenant
    SELECT tff.value INTO v_override_value
    FROM foundation.tenant_feature_flags tff
    JOIN foundation.feature_flags ff ON tff.feature_flag_id = ff.id
    WHERE tff.tenant_id = p_tenant_id
        AND ff.code = p_flag_code;
    
    IF v_override_value IS NOT NULL THEN
        RETURN v_override_value;
    END IF;
    
    -- Retorna valor padrão
    SELECT default_value INTO v_default_value
    FROM foundation.feature_flags
    WHERE code = p_flag_code;
    
    RETURN COALESCE(v_default_value, FALSE);
END;
$$;

COMMENT ON FUNCTION foundation.get_feature_flag IS 'Retorna valor de feature flag para tenant (override ou default)';

-- Obter quota para tenant
CREATE OR REPLACE FUNCTION foundation.get_quota(
    p_tenant_id UUID,
    p_quota_code TEXT
)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY INVOKER
STABLE
AS $$
DECLARE
    v_override_value NUMERIC;
    v_default_value NUMERIC;
BEGIN
    -- Tenta obter override do tenant
    SELECT tq.value INTO v_override_value
    FROM foundation.tenant_quotas tq
    JOIN foundation.quotas q ON tq.quota_id = q.id
    WHERE tq.tenant_id = p_tenant_id
        AND q.code = p_quota_code;
    
    IF v_override_value IS NOT NULL THEN
        RETURN v_override_value;
    END IF;
    
    -- Retorna valor padrão
    SELECT default_value INTO v_default_value
    FROM foundation.quotas
    WHERE code = p_quota_code;
    
    RETURN COALESCE(v_default_value, 0);
END;
$$;

COMMENT ON FUNCTION foundation.get_quota IS 'Retorna valor de quota para tenant (override ou default)';

-- ============================================================================
-- TRIGGERS: Publicar eventos automaticamente
-- ============================================================================

-- Trigger para publicar evento quando tenant é criado/atualizado
CREATE OR REPLACE FUNCTION foundation.trigger_tenant_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_event_type TEXT;
    v_payload JSONB;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'tenant.created';
        v_payload := jsonb_build_object(
            'tenant_id', NEW.id,
            'name', NEW.name,
            'slug', NEW.slug,
            'status', NEW.status
        );
        
        PERFORM foundation.publish_event(
            v_event_type,
            'tenant',
            NEW.id,
            v_payload,
            '1.0',
            gen_random_uuid(),
            NULL
        );
        
    ELSIF TG_OP = 'UPDATE' THEN
        v_event_type := 'tenant.updated';
        v_payload := jsonb_build_object(
            'tenant_id', NEW.id,
            'name', NEW.name,
            'slug', NEW.slug,
            'status', NEW.status,
            'changes', jsonb_build_object(
                'status', CASE WHEN OLD.status != NEW.status THEN jsonb_build_object('old', OLD.status, 'new', NEW.status) ELSE NULL END
            )
        );
        
        PERFORM foundation.publish_event(
            v_event_type,
            'tenant',
            NEW.id,
            v_payload,
            '1.0',
            gen_random_uuid(),
            NULL
        );
    END IF;
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NEW;
END;
$$;

COMMENT ON FUNCTION foundation.trigger_tenant_event() IS 'Publica eventos quando tenant é criado/atualizado';

CREATE TRIGGER trigger_tenant_event
    AFTER INSERT OR UPDATE ON foundation.tenants
    FOR EACH ROW
    EXECUTE FUNCTION foundation.trigger_tenant_event();

-- ============================================================================
-- VIEWS: Consultas úteis
-- ============================================================================

-- View: Eventos pendentes por tenant
CREATE OR REPLACE VIEW foundation.v_events_pending_by_tenant AS
SELECT 
    tenant_id,
    COUNT(*) as pending_count,
    MIN(created_at) as oldest_pending,
    MAX(created_at) as newest_pending
FROM foundation.events_outbox
WHERE status = 'pending'
GROUP BY tenant_id;

COMMENT ON VIEW foundation.v_events_pending_by_tenant IS 'Eventos pendentes agrupados por tenant';

-- View: Estatísticas de eventos
CREATE OR REPLACE VIEW foundation.v_events_stats AS
SELECT 
    tenant_id,
    status,
    COUNT(*) as count,
    MIN(created_at) as first_event,
    MAX(created_at) as last_event
FROM foundation.events_outbox
GROUP BY tenant_id, status;

COMMENT ON VIEW foundation.v_events_stats IS 'Estatísticas de eventos por tenant e status';
