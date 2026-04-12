async function orchestrateAIAgents(tasks) {
    const results = [];
    for (const task of tasks) {
        const agent = await selectOptimalAgent(task);
        const result = await agent.execute(task);
        results.push(result);
        await monitorAndOptimize(result);
    }
    return results;
}

function selectOptimalAgent(task) {
    return fetch('/api/agents/best-match', {
        method: 'POST',
        body: JSON.stringify({ task })
    }).then(res => res.json());
}