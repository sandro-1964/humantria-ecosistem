import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AppProvider } from "@/contexts/AppContext";
import { SplashScreen, useSplashScreen } from "@/components/layout/SplashScreen";
import LandingPage from "./pages/LandingPage";
import HomePage from "./pages/HomePage";
import NotFound from "./pages/NotFound";

// Foundation Pages
import TenantsPage from "./pages/foundation/TenantsPage";
import IAMPage from "./pages/foundation/IAMPage";
import FeatureFlagsPage from "./pages/foundation/FeatureFlagsPage";
import AuditPage from "./pages/foundation/AuditPage";
import EventsPage from "./pages/foundation/EventsPage";
import PrivacyPage from "./pages/foundation/PrivacyPage";
import AIGovernancePage from "./pages/foundation/AIGovernancePage";
import BillingPage from "./pages/foundation/BillingPage";
import TemplatesPage from "./pages/foundation/TemplatesPage";
import OwnerConsolePage from "./pages/foundation/OwnerConsolePage";

// Core Pages
import OrganizationPage from "./pages/core/OrganizationPage";
import PeoplePage from "./pages/core/PeoplePage";
import AssignmentsPage from "./pages/core/AssignmentsPage";
import JobsPage from "./pages/core/JobsPage";
import CoreImportPage from "./pages/core/ImportPage";
import EconomicsPage from "./pages/core/EconomicsPage";

// Bridges Pages
import BridgesEventsPage from "./pages/bridges/EventsPage";
import ConsumersPage from "./pages/bridges/ConsumersPage";
import FailuresPage from "./pages/bridges/FailuresPage";
import RetriesPage from "./pages/bridges/RetriesPage";
import CorrelationPage from "./pages/bridges/CorrelationPage";
import ConnectorsPage from "./pages/bridges/ConnectorsPage";
import DiagnosticsPage from "./pages/bridges/DiagnosticsPage";

// Strategy Pages
import StrategyDashboardPage from "./pages/strategy/DashboardPage";
import ObjectivesPage from "./pages/strategy/ObjectivesPage";
import StrategyTemplatesPage from "./pages/strategy/TemplatesPage";
import ApprovalsPage from "./pages/strategy/ApprovalsPage";
import BudgetPage from "./pages/strategy/BudgetPage";
import StaffingPage from "./pages/strategy/StaffingPage";
import ScenariosPage from "./pages/strategy/ScenariosPage";
import WorkflowsPage from "./pages/strategy/WorkflowsPage";
import RisksPage from "./pages/strategy/RisksPage";
import AIInsightsPage from "./pages/strategy/AIInsightsPage";
import OrgChartPage from "./pages/strategy/OrgChartPage";

// Talent Pages
import TalentDashboardPage from "./pages/talent/DashboardPage";

// Evolution Pages
import EvolutionDashboardPage from "./pages/evolution/DashboardPage";

// Chronos Pages
import ChronosDashboardPage from "./pages/chronos/DashboardPage";

// Operations & Risk Pages
import OperationsDashboardPage from "./pages/operations/DashboardPage";

// GRC Pages
import GRCDashboardPage from "./pages/grc/DashboardPage";

// Intelligence Pages
import IntelligenceDashboardPage from "./pages/intelligence/DashboardPage";

// Synergy Pages
import SynergyDashboardPage from "./pages/synergy/DashboardPage";

// Orchestra Pages
import OrchestraDashboardPage from "./pages/orchestra/DashboardPage";

// Tools Pages
import SandboxPage from "./pages/tools/SandboxPage";
import ImportCenterPage from "./pages/tools/ImportCenterPage";
import ExportCenterPage from "./pages/tools/ExportCenterPage";
import FilesHubPage from "./pages/tools/FilesHubPage";
import NotificationsPage from "./pages/tools/NotificationsPage";
import MessagesPage from "./pages/tools/MessagesPage";
import HelpCenterPage from "./pages/tools/HelpCenterPage";
import ToolsDiagnosticsPage from "./pages/tools/DiagnosticsPage";
import LanguagesPage from "./pages/tools/LanguagesPage";
import PersonalizationPage from "./pages/tools/PersonalizationPage";
import DocumentationPage from "./pages/tools/DocumentationPage";
import LegacyIntegrationsPage from "./pages/tools/LegacyIntegrationsPage";

// Decision Hub
import DecisionHubPage from "./pages/DecisionHubPage";

// Settings Page
import SettingsPage from "./pages/SettingsPage";

const queryClient = new QueryClient();

function AppContent() {
  const { showSplash, handleSplashComplete } = useSplashScreen();

  return (
    <>
      {showSplash && <SplashScreen onComplete={handleSplashComplete} />}
      <Toaster />
      <Sonner />
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/home" element={<HomePage />} />
            <Route path="/decision-hub" element={<DecisionHubPage />} />
            {/* Foundation Routes */}
            <Route path="/foundation/tenants" element={<TenantsPage />} />
            <Route path="/foundation/iam" element={<IAMPage />} />
            <Route path="/foundation/feature-flags" element={<FeatureFlagsPage />} />
            <Route path="/foundation/audit" element={<AuditPage />} />
            <Route path="/foundation/events" element={<EventsPage />} />
            <Route path="/foundation/privacy" element={<PrivacyPage />} />
            <Route path="/foundation/ai-governance" element={<AIGovernancePage />} />
            <Route path="/foundation/billing" element={<BillingPage />} />
            <Route path="/foundation/templates" element={<TemplatesPage />} />
            <Route path="/foundation/owner" element={<OwnerConsolePage />} />
            
            {/* Core Routes */}
            <Route path="/core/organization" element={<OrganizationPage />} />
            <Route path="/core/people" element={<PeoplePage />} />
            <Route path="/core/assignments" element={<AssignmentsPage />} />
            <Route path="/core/jobs" element={<JobsPage />} />
            <Route path="/core/import" element={<CoreImportPage />} />
            <Route path="/core/economics" element={<EconomicsPage />} />
            
            {/* Bridges Routes */}
            <Route path="/bridges/events" element={<BridgesEventsPage />} />
            <Route path="/bridges/consumers" element={<ConsumersPage />} />
            <Route path="/bridges/failures" element={<FailuresPage />} />
            <Route path="/bridges/retries" element={<RetriesPage />} />
            <Route path="/bridges/correlation" element={<CorrelationPage />} />
            <Route path="/bridges/connectors" element={<ConnectorsPage />} />
            <Route path="/bridges/diagnostics" element={<DiagnosticsPage />} />
            
            {/* Strategy Routes */}
            <Route path="/strategy/dashboard" element={<StrategyDashboardPage />} />
            <Route path="/strategy/objectives" element={<ObjectivesPage />} />
            <Route path="/strategy/templates" element={<StrategyTemplatesPage />} />
            <Route path="/strategy/approvals" element={<ApprovalsPage />} />
            <Route path="/strategy/budget" element={<BudgetPage />} />
            <Route path="/strategy/staffing" element={<StaffingPage />} />
            <Route path="/strategy/scenarios" element={<ScenariosPage />} />
            <Route path="/strategy/workflows" element={<WorkflowsPage />} />
            <Route path="/strategy/risks" element={<RisksPage />} />
            <Route path="/strategy/ai" element={<AIInsightsPage />} />
            <Route path="/strategy/org-chart" element={<OrgChartPage />} />
            
            {/* Talent Routes */}
            <Route path="/talent/dashboard" element={<TalentDashboardPage />} />
            <Route path="/talent/vacancies" element={<TalentDashboardPage />} />
            <Route path="/talent/candidates" element={<TalentDashboardPage />} />
            <Route path="/talent/pool" element={<TalentDashboardPage />} />
            
            {/* Evolution Routes */}
            <Route path="/evolution/dashboard" element={<EvolutionDashboardPage />} />
            <Route path="/evolution/assessments" element={<EvolutionDashboardPage />} />
            <Route path="/evolution/development" element={<EvolutionDashboardPage />} />
            <Route path="/evolution/learning" element={<EvolutionDashboardPage />} />
            
            {/* Chronos Routes */}
            <Route path="/chronos/dashboard" element={<ChronosDashboardPage />} />
            <Route path="/chronos/planning" element={<ChronosDashboardPage />} />
            <Route path="/chronos/schedules" element={<ChronosDashboardPage />} />
            <Route path="/chronos/allocation" element={<ChronosDashboardPage />} />
            
            {/* Operations & Risk Routes */}
            <Route path="/operations/dashboard" element={<OperationsDashboardPage />} />
            <Route path="/operations/controls" element={<OperationsDashboardPage />} />
            <Route path="/operations/incidents" element={<OperationsDashboardPage />} />
            <Route path="/operations/mitigation" element={<OperationsDashboardPage />} />
            
            {/* GRC Routes */}
            <Route path="/grc/dashboard" element={<GRCDashboardPage />} />
            <Route path="/grc/policies" element={<GRCDashboardPage />} />
            <Route path="/grc/audits" element={<GRCDashboardPage />} />
            <Route path="/grc/action-plans" element={<GRCDashboardPage />} />
            
            {/* Intelligence Routes */}
            <Route path="/intelligence/dashboard" element={<IntelligenceDashboardPage />} />
            <Route path="/intelligence/insights" element={<IntelligenceDashboardPage />} />
            <Route path="/intelligence/recommendations" element={<IntelligenceDashboardPage />} />
            <Route path="/intelligence/narratives" element={<IntelligenceDashboardPage />} />
            
            {/* Synergy Routes */}
            <Route path="/synergy/dashboard" element={<SynergyDashboardPage />} />
            <Route path="/synergy/jobs" element={<SynergyDashboardPage />} />
            <Route path="/synergy/competencies" element={<SynergyDashboardPage />} />
            <Route path="/synergy/compensation" element={<SynergyDashboardPage />} />
            
            {/* Orchestra Routes */}
            <Route path="/orchestra/dashboard" element={<OrchestraDashboardPage />} />
            <Route path="/orchestra/hrbp" element={<OrchestraDashboardPage />} />
            <Route path="/orchestra/ssc" element={<OrchestraDashboardPage />} />
            <Route path="/orchestra/coes" element={<OrchestraDashboardPage />} />
            <Route path="/orchestra/change" element={<OrchestraDashboardPage />} />

            {/* Tools Routes */}
            <Route path="/tools/sandbox" element={<SandboxPage />} />
            <Route path="/tools/import" element={<ImportCenterPage />} />
            <Route path="/tools/export" element={<ExportCenterPage />} />
            <Route path="/tools/files" element={<FilesHubPage />} />
            <Route path="/tools/notifications" element={<NotificationsPage />} />
            <Route path="/tools/messages" element={<MessagesPage />} />
            <Route path="/tools/help" element={<HelpCenterPage />} />
            <Route path="/tools/diagnostics" element={<ToolsDiagnosticsPage />} />
            <Route path="/tools/languages" element={<LanguagesPage />} />
            <Route path="/tools/personalization" element={<PersonalizationPage />} />
            <Route path="/tools/documentation" element={<DocumentationPage />} />
            <Route path="/tools/legacy-integrations" element={<LegacyIntegrationsPage />} />
            
            {/* Settings */}
            <Route path="/settings" element={<SettingsPage />} />
            
            {/* Catch-all */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
    </>
  );
}

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AppProvider>
      <TooltipProvider>
        <AppContent />
      </TooltipProvider>
    </AppProvider>
  </QueryClientProvider>
);

export default App;
