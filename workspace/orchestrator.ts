export function createWorkspaceOrchestrator() {
  return {
    orchestrator: new WorkspaceOrchestrator(),
    executeWorkflow: (workflow: Workflow) => orchestrator.execute(workflow),
    analyzeIntent: (input: string) => orchestrator.parse(input),
    scheduleTasks: (tasks: Task[]) => orchestrator.schedule(tasks),
    monitorProgress: (workflowId: string) => orchestrator.getStatus(workflowId)
  }
}