Write-Host "Starting workflow runs cleanup..."

Write-Host "Fetching all workflow runs..."
$currentRunId = $env:GITHUB_RUN_ID
Write-Host "Current running workflow ID: $currentRunId"

$workflowRuns = gh api repos/${{ github.repository }}/actions/runs --paginate -q '.workflow_runs[] | select(.id) | .id'

if (-not $workflowRuns) {
            Write-Host "No workflow runs found to delete. Skipping workflow cleanup."
} else {
        Write-Host "Found workflow runs. Starting deletion..."
        $workflowRuns | ForEach-Object {
        if ($_ -ne $currentRunId) {
            Write-Host "Deleting workflow run ID: $_"
            try {
                gh api repos/${{ github.repository }}/actions/runs/$_ -X DELETE
                Write-Host "Successfully deleted workflow run: $_"
            } catch {
                Write-Host "Failed to delete workflow run: $_"
            }
        } else {
            Write-Host "Skipping current workflow run: $_"
        }
    }
    Write-Host "Workflow cleanup completed. Only the current run is preserved."
}