import React from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/ui/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AIActions } from '@/components/ui/ai-actions';
import { Wizard, WizardActions } from '@/components/ui/wizard';
import { Upload, FileSpreadsheet, CheckCircle, AlertCircle } from 'lucide-react';

const steps = [
  { id: 'upload', title: 'Upload File', description: 'Select your data file' },
  { id: 'map', title: 'Map Fields', description: 'Match columns' },
  { id: 'validate', title: 'Validate', description: 'Check for errors' },
  { id: 'import', title: 'Import', description: 'Process data' },
];

export default function ImportPage() {
  const [currentStep, setCurrentStep] = React.useState(0);

  return (
    <AppLayout>
      <PageHeader
        title="Import Center"
        description="Import data from external sources"
        breadcrumbs={[{ label: 'Core', href: '/core' }, { label: 'Import' }]}
        actions={<AIActions onSuggest={() => {}} onExplain={() => {}} />}
      />
      <div className="p-6 space-y-6">
        <Card>
          <CardContent className="pt-6">
            <Wizard steps={steps} currentStep={currentStep} onStepClick={setCurrentStep} />
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            {currentStep === 0 && (
              <div className="border-2 border-dashed rounded-lg p-12 text-center">
                <Upload className="h-12 w-12 mx-auto text-muted-foreground" />
                <h3 className="mt-4 text-lg font-medium">Drop your file here</h3>
                <p className="mt-2 text-sm text-muted-foreground">CSV, XLSX, or JSON files supported</p>
                <Button className="mt-4">Browse Files</Button>
              </div>
            )}
            {currentStep === 1 && (
              <div className="space-y-4">
                <p className="text-muted-foreground">Map your file columns to system fields</p>
                <div className="grid grid-cols-2 gap-4">
                  {['Name', 'Email', 'Department', 'Job Title'].map((field) => (
                    <div key={field} className="flex items-center justify-between p-3 border rounded-md">
                      <span>{field}</span>
                      <span className="text-muted-foreground">→ Column A</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
            {currentStep === 2 && (
              <div className="space-y-4">
                <div className="flex items-center gap-2 p-4 rounded-md bg-success/10 text-success">
                  <CheckCircle className="h-5 w-5" />
                  <span>245 records validated successfully</span>
                </div>
                <div className="flex items-center gap-2 p-4 rounded-md bg-warning/10 text-warning">
                  <AlertCircle className="h-5 w-5" />
                  <span>3 records have warnings</span>
                </div>
              </div>
            )}
            {currentStep === 3 && (
              <div className="text-center py-8">
                <CheckCircle className="h-16 w-16 mx-auto text-success" />
                <h3 className="mt-4 text-lg font-medium">Import Complete</h3>
                <p className="mt-2 text-muted-foreground">245 records imported successfully</p>
              </div>
            )}
          </CardContent>
        </Card>

        <WizardActions
          onPrevious={currentStep > 0 ? () => setCurrentStep(c => c - 1) : undefined}
          onNext={currentStep < 3 ? () => setCurrentStep(c => c + 1) : undefined}
          previousDisabled={currentStep === 0}
          nextLabel={currentStep === 3 ? 'Done' : 'Next'}
        />
      </div>
    </AppLayout>
  );
}
