export function parseWorkflowIntent(text: string): {
  commands: Array<{
    action: string;
    parameters: Record<string, any>;
    confidence: number;
  }>;
  entities: Record<string, any>;
} {
  const response = await fetch('/api/parse/entities', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text })
  });
  return response.json();
}