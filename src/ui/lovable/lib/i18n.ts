export type Language = 'pt' | 'en' | 'es';

export interface TranslationKeys {
  // Navigation
  home: string;
  decisionHub: string;
  foundation: string;
  core: string;
  bridges: string;
  strategy: string;
  talent: string;
  evolution: string;
  chronos: string;
  operationsRisk: string;
  grc: string;
  intelligence: string;
  synergy: string;
  orchestra: string;
  tools: string;
  settings: string;
  
  // Common Actions
  save: string;
  cancel: string;
  delete: string;
  edit: string;
  create: string;
  search: string;
  filter: string;
  export: string;
  import: string;
  refresh: string;
  retry: string;
  confirm: string;
  close: string;
  viewDetails: string;
  viewAll: string;
  back: string;
  next: string;
  previous: string;
  submit: string;
  reset: string;
  
  // States
  loading: string;
  noData: string;
  error: string;
  success: string;
  pending: string;
  active: string;
  inactive: string;
  completed: string;
  inProgress: string;
  
  // AI Actions
  aiSuggest: string;
  aiExplain: string;
  aiSimulate: string;
  aiAnalyze: string;
  aiGenerated: string;
  aiInsight: string;
  
  // Header
  globalSearch: string;
  notifications: string;
  messages: string;
  profile: string;
  logout: string;
  
  // Footer
  environment: string;
  version: string;
  health: string;
  
  // Product Headlines
  foundationHeadline: string;
  foundationSubheadline: string;
  coreHeadline: string;
  coreSubheadline: string;
  bridgesHeadline: string;
  bridgesSubheadline: string;
  strategyHeadline: string;
  strategySubheadline: string;
  talentHeadline: string;
  talentSubheadline: string;
  evolutionHeadline: string;
  evolutionSubheadline: string;
  chronosHeadline: string;
  chronosSubheadline: string;
  operationsRiskHeadline: string;
  operationsRiskSubheadline: string;
  grcHeadline: string;
  grcSubheadline: string;
  intelligenceHeadline: string;
  intelligenceSubheadline: string;
  synergyHeadline: string;
  synergySubheadline: string;
  orchestraHeadline: string;
  orchestraSubheadline: string;
  
  // Empty States
  emptyStateTitle: string;
  emptyStateDescription: string;
  emptyStateAction: string;
  noResultsFound: string;
  noDataAvailable: string;
  
  // Error States
  errorStateTitle: string;
  errorStateDescription: string;
  tryAgain: string;
  contactSupport: string;
  
  // CRUD Messages
  createSuccess: string;
  updateSuccess: string;
  deleteSuccess: string;
  createError: string;
  updateError: string;
  deleteError: string;
  confirmDelete: string;
  confirmDeleteMessage: string;
  
  // Dashboard
  dashboardWelcome: string;
  lastUpdated: string;
  quickActions: string;
  recentActivity: string;
  
  // Roles
  admin: string;
  manager: string;
  analyst: string;
  auditor: string;
  viewer: string;
}

export const translations: Record<Language, TranslationKeys> = {
  pt: {
    // Navigation
    home: 'Início',
    decisionHub: 'Hub de Decisões',
    foundation: 'Foundation',
    core: 'Core',
    bridges: 'Bridges',
    strategy: 'Strategy',
    talent: 'Talent',
    evolution: 'Evolution',
    chronos: 'Chronos',
    operationsRisk: 'Operations & Risk',
    grc: 'GRC',
    intelligence: 'Intelligence',
    synergy: 'Synergy',
    orchestra: 'Orchestra',
    tools: 'Tools',
    settings: 'Configurações',
    
    // Common Actions
    save: 'Salvar',
    cancel: 'Cancelar',
    delete: 'Excluir',
    edit: 'Editar',
    create: 'Criar',
    search: 'Buscar',
    filter: 'Filtrar',
    export: 'Exportar',
    import: 'Importar',
    refresh: 'Atualizar',
    retry: 'Tentar novamente',
    confirm: 'Confirmar',
    close: 'Fechar',
    viewDetails: 'Ver detalhes',
    viewAll: 'Ver todos',
    back: 'Voltar',
    next: 'Próximo',
    previous: 'Anterior',
    submit: 'Enviar',
    reset: 'Resetar',
    
    // States
    loading: 'Carregando...',
    noData: 'Nenhum dado encontrado',
    error: 'Ocorreu um erro',
    success: 'Operação realizada com sucesso',
    pending: 'Pendente',
    active: 'Ativo',
    inactive: 'Inativo',
    completed: 'Concluído',
    inProgress: 'Em andamento',
    
    // AI
    aiSuggest: 'Sugerir com IA',
    aiExplain: 'Explicar com IA',
    aiSimulate: 'Simular',
    aiAnalyze: 'Analisar com IA',
    aiGenerated: 'Gerado por IA',
    aiInsight: 'Insight IA',
    
    // Header
    globalSearch: 'Buscar em todo o sistema...',
    notifications: 'Notificações',
    messages: 'Mensagens',
    profile: 'Perfil',
    logout: 'Sair',
    
    // Footer
    environment: 'Ambiente',
    version: 'Versão',
    health: 'Status',
    
    // Product Headlines
    foundationHeadline: 'Foundation',
    foundationSubheadline: 'Administração e governança da plataforma. Tenants, acessos, auditoria, privacidade, políticas e configurações.',
    coreHeadline: 'Core',
    coreSubheadline: 'Estrutura organizacional e catálogos base. Org, pessoas, cargos, níveis, imports e parâmetros econômicos.',
    bridgesHeadline: 'Bridges',
    bridgesSubheadline: 'Integração e operação técnica. Eventos, conectores, sincronizações, falhas e observabilidade.',
    strategyHeadline: 'Strategy',
    strategySubheadline: 'Planejamento e governança estratégica. Objetivos, orçamento e staffing com evidências, aprovações e cenários.',
    talentHeadline: 'Talent',
    talentSubheadline: 'Recrutamento e seleção governados. Vagas, candidatos, etapas, ranking e banco de talentos com IA assistiva.',
    evolutionHeadline: 'Evolution',
    evolutionSubheadline: 'Desempenho, desenvolvimento e aprendizagem. Avaliações, PDI, trilhas e evolução contínua.',
    chronosHeadline: 'Chronos',
    chronosSubheadline: 'Tempo, capacidade e jornada de trabalho. Planejamento temporal, agendas e alocação.',
    operationsRiskHeadline: 'Operations & Risk',
    operationsRiskSubheadline: 'Operação, conformidade e riscos de força de trabalho. Controles, incidentes e mitigação com evidências.',
    grcHeadline: 'GRC',
    grcSubheadline: 'Governança, risco e compliance. Controles, políticas, auditorias e planos de ação.',
    intelligenceHeadline: 'Intelligence',
    intelligenceSubheadline: 'Inteligência e explicabilidade das decisões. Insights, recomendações e narrativas assistidas por IA.',
    synergyHeadline: 'Synergy',
    synergySubheadline: 'Cargos, carreira e recompensas. Arquitetura de cargos, competências e estrutura de remuneração.',
    orchestraHeadline: 'Orchestra',
    orchestraSubheadline: 'Orquestração do modelo de RH. HRBP, SSC, CoEs, comunicação e mudanças.',
    
    // Empty States
    emptyStateTitle: 'Nenhum dado disponível',
    emptyStateDescription: 'Comece criando seu primeiro registro.',
    emptyStateAction: 'Criar novo',
    noResultsFound: 'Nenhum resultado encontrado',
    noDataAvailable: 'Dados não disponíveis',
    
    // Error States
    errorStateTitle: 'Algo deu errado',
    errorStateDescription: 'Não foi possível carregar os dados. Por favor, tente novamente.',
    tryAgain: 'Tentar novamente',
    contactSupport: 'Contatar suporte',
    
    // CRUD Messages
    createSuccess: 'Registro criado com sucesso',
    updateSuccess: 'Registro atualizado com sucesso',
    deleteSuccess: 'Registro excluído com sucesso',
    createError: 'Erro ao criar registro',
    updateError: 'Erro ao atualizar registro',
    deleteError: 'Erro ao excluir registro',
    confirmDelete: 'Confirmar exclusão',
    confirmDeleteMessage: 'Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.',
    
    // Dashboard
    dashboardWelcome: 'Bem-vindo ao HUMANTRÍA',
    lastUpdated: 'Última atualização',
    quickActions: 'Ações rápidas',
    recentActivity: 'Atividade recente',
    
    // Roles
    admin: 'Administrador',
    manager: 'Gestor',
    analyst: 'Analista',
    auditor: 'Auditor',
    viewer: 'Visualizador',
  },
  en: {
    // Navigation
    home: 'Home',
    decisionHub: 'Decision Hub',
    foundation: 'Foundation',
    core: 'Core',
    bridges: 'Bridges',
    strategy: 'Strategy',
    talent: 'Talent',
    evolution: 'Evolution',
    chronos: 'Chronos',
    operationsRisk: 'Operations & Risk',
    grc: 'GRC',
    intelligence: 'Intelligence',
    synergy: 'Synergy',
    orchestra: 'Orchestra',
    tools: 'Tools',
    settings: 'Settings',
    
    // Common Actions
    save: 'Save',
    cancel: 'Cancel',
    delete: 'Delete',
    edit: 'Edit',
    create: 'Create',
    search: 'Search',
    filter: 'Filter',
    export: 'Export',
    import: 'Import',
    refresh: 'Refresh',
    retry: 'Retry',
    confirm: 'Confirm',
    close: 'Close',
    viewDetails: 'View details',
    viewAll: 'View all',
    back: 'Back',
    next: 'Next',
    previous: 'Previous',
    submit: 'Submit',
    reset: 'Reset',
    
    // States
    loading: 'Loading...',
    noData: 'No data found',
    error: 'An error occurred',
    success: 'Operation completed successfully',
    pending: 'Pending',
    active: 'Active',
    inactive: 'Inactive',
    completed: 'Completed',
    inProgress: 'In Progress',
    
    // AI
    aiSuggest: 'Suggest with AI',
    aiExplain: 'Explain with AI',
    aiSimulate: 'Simulate',
    aiAnalyze: 'Analyze with AI',
    aiGenerated: 'AI Generated',
    aiInsight: 'AI Insight',
    
    // Header
    globalSearch: 'Search across all modules...',
    notifications: 'Notifications',
    messages: 'Messages',
    profile: 'Profile',
    logout: 'Sign out',
    
    // Footer
    environment: 'Environment',
    version: 'Version',
    health: 'Health',
    
    // Product Headlines
    foundationHeadline: 'Foundation',
    foundationSubheadline: 'Platform administration and governance. Tenants, access, audit, privacy, policies and configurations.',
    coreHeadline: 'Core',
    coreSubheadline: 'Organizational structure and base catalogs. Org, people, positions, levels, imports and economic parameters.',
    bridgesHeadline: 'Bridges',
    bridgesSubheadline: 'Integration and technical operations. Events, connectors, synchronizations, failures and observability.',
    strategyHeadline: 'Strategy',
    strategySubheadline: 'Strategic planning and governance. Objectives, budget and staffing with evidence, approvals and scenarios.',
    talentHeadline: 'Talent',
    talentSubheadline: 'Governed recruitment and selection. Vacancies, candidates, stages, ranking and talent pool with AI assistance.',
    evolutionHeadline: 'Evolution',
    evolutionSubheadline: 'Performance, development and learning. Assessments, PDP, learning paths and continuous evolution.',
    chronosHeadline: 'Chronos',
    chronosSubheadline: 'Time, capacity and work journey. Time planning, schedules and allocation.',
    operationsRiskHeadline: 'Operations & Risk',
    operationsRiskSubheadline: 'Operations, compliance and workforce risks. Controls, incidents and mitigation with evidence.',
    grcHeadline: 'GRC',
    grcSubheadline: 'Governance, risk and compliance. Controls, policies, audits and action plans.',
    intelligenceHeadline: 'Intelligence',
    intelligenceSubheadline: 'Decision intelligence and explainability. Insights, recommendations and AI-assisted narratives.',
    synergyHeadline: 'Synergy',
    synergySubheadline: 'Positions, career and rewards. Position architecture, competencies and compensation structure.',
    orchestraHeadline: 'Orchestra',
    orchestraSubheadline: 'HR model orchestration. HRBP, SSC, CoEs, communication and change management.',
    
    // Empty States
    emptyStateTitle: 'No data available',
    emptyStateDescription: 'Get started by creating your first record.',
    emptyStateAction: 'Create new',
    noResultsFound: 'No results found',
    noDataAvailable: 'Data not available',
    
    // Error States
    errorStateTitle: 'Something went wrong',
    errorStateDescription: 'Unable to load data. Please try again.',
    tryAgain: 'Try again',
    contactSupport: 'Contact support',
    
    // CRUD Messages
    createSuccess: 'Record created successfully',
    updateSuccess: 'Record updated successfully',
    deleteSuccess: 'Record deleted successfully',
    createError: 'Error creating record',
    updateError: 'Error updating record',
    deleteError: 'Error deleting record',
    confirmDelete: 'Confirm deletion',
    confirmDeleteMessage: 'Are you sure you want to delete this record? This action cannot be undone.',
    
    // Dashboard
    dashboardWelcome: 'Welcome to HUMANTRÍA',
    lastUpdated: 'Last updated',
    quickActions: 'Quick actions',
    recentActivity: 'Recent activity',
    
    // Roles
    admin: 'Administrator',
    manager: 'Manager',
    analyst: 'Analyst',
    auditor: 'Auditor',
    viewer: 'Viewer',
  },
  es: {
    // Navigation
    home: 'Inicio',
    decisionHub: 'Hub de Decisiones',
    foundation: 'Foundation',
    core: 'Core',
    bridges: 'Bridges',
    strategy: 'Strategy',
    talent: 'Talent',
    evolution: 'Evolution',
    chronos: 'Chronos',
    operationsRisk: 'Operations & Risk',
    grc: 'GRC',
    intelligence: 'Intelligence',
    synergy: 'Synergy',
    orchestra: 'Orchestra',
    tools: 'Tools',
    settings: 'Configuración',
    
    // Common Actions
    save: 'Guardar',
    cancel: 'Cancelar',
    delete: 'Eliminar',
    edit: 'Editar',
    create: 'Crear',
    search: 'Buscar',
    filter: 'Filtrar',
    export: 'Exportar',
    import: 'Importar',
    refresh: 'Actualizar',
    retry: 'Reintentar',
    confirm: 'Confirmar',
    close: 'Cerrar',
    viewDetails: 'Ver detalles',
    viewAll: 'Ver todos',
    back: 'Volver',
    next: 'Siguiente',
    previous: 'Anterior',
    submit: 'Enviar',
    reset: 'Restablecer',
    
    // States
    loading: 'Cargando...',
    noData: 'No se encontraron datos',
    error: 'Ocurrió un error',
    success: 'Operación completada con éxito',
    pending: 'Pendiente',
    active: 'Activo',
    inactive: 'Inactivo',
    completed: 'Completado',
    inProgress: 'En progreso',
    
    // AI
    aiSuggest: 'Sugerir con IA',
    aiExplain: 'Explicar con IA',
    aiSimulate: 'Simular',
    aiAnalyze: 'Analizar con IA',
    aiGenerated: 'Generado por IA',
    aiInsight: 'Insight IA',
    
    // Header
    globalSearch: 'Buscar en todo el sistema...',
    notifications: 'Notificaciones',
    messages: 'Mensajes',
    profile: 'Perfil',
    logout: 'Cerrar sesión',
    
    // Footer
    environment: 'Entorno',
    version: 'Versión',
    health: 'Estado',
    
    // Product Headlines
    foundationHeadline: 'Foundation',
    foundationSubheadline: 'Administración y gobernanza de la plataforma. Tenants, accesos, auditoría, privacidad, políticas y configuraciones.',
    coreHeadline: 'Core',
    coreSubheadline: 'Estructura organizacional y catálogos base. Org, personas, puestos, niveles, importaciones y parámetros económicos.',
    bridgesHeadline: 'Bridges',
    bridgesSubheadline: 'Integración y operación técnica. Eventos, conectores, sincronizaciones, fallos y observabilidad.',
    strategyHeadline: 'Strategy',
    strategySubheadline: 'Planificación y gobernanza estratégica. Objetivos, presupuesto y dotación con evidencias, aprobaciones y escenarios.',
    talentHeadline: 'Talent',
    talentSubheadline: 'Reclutamiento y selección gobernados. Vacantes, candidatos, etapas, ranking y banco de talentos con IA asistida.',
    evolutionHeadline: 'Evolution',
    evolutionSubheadline: 'Desempeño, desarrollo y aprendizaje. Evaluaciones, PDP, rutas de aprendizaje y evolución continua.',
    chronosHeadline: 'Chronos',
    chronosSubheadline: 'Tiempo, capacidad y jornada laboral. Planificación temporal, agendas y asignación.',
    operationsRiskHeadline: 'Operations & Risk',
    operationsRiskSubheadline: 'Operación, cumplimiento y riesgos de fuerza laboral. Controles, incidentes y mitigación con evidencias.',
    grcHeadline: 'GRC',
    grcSubheadline: 'Gobernanza, riesgo y cumplimiento. Controles, políticas, auditorías y planes de acción.',
    intelligenceHeadline: 'Intelligence',
    intelligenceSubheadline: 'Inteligencia y explicabilidad de decisiones. Insights, recomendaciones y narrativas asistidas por IA.',
    synergyHeadline: 'Synergy',
    synergySubheadline: 'Puestos, carrera y recompensas. Arquitectura de puestos, competencias y estructura de compensación.',
    orchestraHeadline: 'Orchestra',
    orchestraSubheadline: 'Orquestación del modelo de RH. HRBP, SSC, CoEs, comunicación y gestión del cambio.',
    
    // Empty States
    emptyStateTitle: 'No hay datos disponibles',
    emptyStateDescription: 'Comience creando su primer registro.',
    emptyStateAction: 'Crear nuevo',
    noResultsFound: 'No se encontraron resultados',
    noDataAvailable: 'Datos no disponibles',
    
    // Error States
    errorStateTitle: 'Algo salió mal',
    errorStateDescription: 'No se pudieron cargar los datos. Por favor, intente de nuevo.',
    tryAgain: 'Intentar de nuevo',
    contactSupport: 'Contactar soporte',
    
    // CRUD Messages
    createSuccess: 'Registro creado con éxito',
    updateSuccess: 'Registro actualizado con éxito',
    deleteSuccess: 'Registro eliminado con éxito',
    createError: 'Error al crear registro',
    updateError: 'Error al actualizar registro',
    deleteError: 'Error al eliminar registro',
    confirmDelete: 'Confirmar eliminación',
    confirmDeleteMessage: '¿Está seguro de que desea eliminar este registro? Esta acción no se puede deshacer.',
    
    // Dashboard
    dashboardWelcome: 'Bienvenido a HUMANTRÍA',
    lastUpdated: 'Última actualización',
    quickActions: 'Acciones rápidas',
    recentActivity: 'Actividad reciente',
    
    // Roles
    admin: 'Administrador',
    manager: 'Gerente',
    analyst: 'Analista',
    auditor: 'Auditor',
    viewer: 'Visualizador',
  },
};

export const getTranslation = (lang: Language, key: keyof TranslationKeys): string => {
  return translations[lang][key] || translations.en[key] || key;
};

// Hook-friendly translation function creator
export const createT = (lang: Language) => (key: keyof TranslationKeys): string => {
  return getTranslation(lang, key);
};
