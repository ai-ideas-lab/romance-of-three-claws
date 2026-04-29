$ErrorActionPreference = "Stop"
$upstream = "ava-agent/awesome-ai-ideas"
$fork = "wshten10/awesome-ai-ideas"
$workspace = "C:\Users\admin.DESKTOP-L2K21NT\.openclaw\workspace\prs"

# Get fork's main SHA
$forkMainSha = gh api "repos/$fork/git/ref/heads/main" --jq '.object.sha'
Write-Host "Fork main SHA: $forkMainSha"

$files = @(
    @{ issue = "1267"; name = "platewise-ai"; title = "PlateWise AI" },
    @{ issue = "1265"; name = "respondermind-ai"; title = "ResponderMind AI" }
)

foreach ($f in $files) {
    $path = "$workspace\$($f.issue)-$($f.name).md"
    Write-Host "`n--- Processing $($f.issue) ---"
    
    $content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($path))
    $blobSha = (@{ content = $content; encoding = "base64" } | ConvertTo-Json -Compress) | gh api "repos/$fork/git/blobs" --input - --jq '.sha'
    Write-Host "Blob: $blobSha"
    
    $branchName = "pr-$($f.issue)-$($f.name)"
    $treeJson = @{
        base_tree = $forkMainSha
        tree = @(@{ path = "prs/$($f.issue)-$($f.name).md"; mode = "100644"; type = "blob"; sha = $blobSha })
    } | ConvertTo-Json -Depth 3 -Compress
    $treeSha = $treeJson | gh api "repos/$fork/git/trees" --input - --jq '.sha'
    Write-Host "Tree: $treeSha"
    
    $commitJson = @{
        message = "feat: add PR document for #$($f.issue) $($f.title)"
        parents = @($forkMainSha)
        tree = $treeSha
    } | ConvertTo-Json -Compress
    $commitSha = $commitJson | gh api "repos/$fork/git/commits" --input - --jq '.sha'
    Write-Host "Commit: $commitSha"
    
    $branchJson = @{ ref = "refs/heads/$branchName"; sha = $commitSha } | ConvertTo-Json -Compress
    $branchRef = $branchJson | gh api "repos/$fork/git/refs" --input - --jq '.ref'
    Write-Host "Branch: $branchRef"
    
    $body = "Closes #$($f.issue)"
    $prJson = @{ title = "feat: $($f.title) (Issue #$($f.issue))"; head = "wshten10:$branchName"; base = "main"; body = $body } | ConvertTo-Json -Compress
    $prUrl = $prJson | gh api "repos/$upstream/pulls" --input - --jq '.html_url'
    Write-Host "PR: $prUrl"
}

Write-Host "`nAll done!"
