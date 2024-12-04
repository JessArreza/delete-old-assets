
Write-Host "Starting releases cleanup..."

Write-Host "Fetching all releases..."
$currentReleaseTag = "${{github.run_number}}"
Write-Host "Current release tag: $currentReleaseTag"

$releases = gh api repos/${{ github.repository }}/releases --paginate -q '.[] | [.id, .tag_name] | @tsv'
        
if (-not $releases) {
    Write-Host "No releases found to delete. Skipping release cleanup."
} 
else 
{
    Write-Host "Found releases. Starting deletion..."
    $releases | ConvertFrom-Csv -Delimiter "`t" -Header "Id", "TagName" | ForEach-Object {
    if ($_.TagName -ne $currentReleaseTag) {
        Write-Host "Deleting release: $($_.TagName) (ID: $($_.Id))"
        try {
            gh api repos/${{ github.repository }}/releases/$($_.Id) -X DELETE
            Write-Host "Successfully deleted release: $($_.TagName)"
        } catch {
            Write-Host "Failed to delete release: $($_.TagName)"
        }
    } else {
        Write-Host "Skipping current release: $($_.TagName)"
    }
    }
}
Write-Host "Release cleanup completed."