Write-Host "Starting tags cleanup..."

Write-Host "Fetching all tags..."
$currentReleaseTag = "${{github.run_number}}"
$tags = gh api repos/${{ github.repository }}/git/refs/tags --paginate -q '.[] | select(.ref | startswith("refs/tags/")) | .ref' `
            | ForEach-Object { $_ -replace 'refs/tags/', '' }

if (-not $tags) {
            Write-Host "No tags found to delete. Skipping tag cleanup."
} else {
        Write-Host "Found tags. Starting deletion..."
        $tags | ForEach-Object {
        if ($_ -ne $currentReleaseTag) {
                Write-Host "Deleting tag: $_"
            try {
                gh api repos/${{ github.repository }}/git/refs/tags/$_ -X DELETE
                Write-Host "Successfully deleted tag: $_"
            } catch {
                Write-Host "Warning: Failed to delete tag: $_"
            }
        } else {
            Write-Host "Skipping current tag: $_"
        }
    }
}
Write-Host "Tag cleanup completed."