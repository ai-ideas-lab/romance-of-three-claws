$ErrorActionPreference = "Stop"
$upstream = "ava-agent/awesome-ai-ideas"
$fork = "wshten10/awesome-ai-ideas"
$workspace = "C:\Users\admin.DESKTOP-L2K21NT\.openclaw\workspace\prs"

# Get main SHA from upstream
$mainSha = gh api "repos/$upstream/git/ref/heads/main" --jq '.object.sha'
Write-Host "Main SHA: $mainSha"

# Create blobs on fork
$b1 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$workspace\1269-resiliencehub-ai.md"))
$b2 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$workspace\1267-platewise-ai.md"))
$b3 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$workspace\1265-respondermind-ai.md"))

$sha1 = (@{ content = $b1; encoding = "base64" } | ConvertTo-Json -Compress) | gh api "repos/$fork/git/blobs" --input - --jq '.sha'
Write-Host "Blob 1269: $sha1"
$sha2 = (@{ content = $b2; encoding = "base64" } | ConvertTo-Json -Compress) | gh api "repos/$fork/git/blobs" --input - --jq '.sha'
Write-Host "Blob 1267: $sha2"
$sha3 = (@{ content = $b3; encoding = "base64" } | ConvertTo-Json -Compress) | gh api "repos/$fork/git/blobs" --input - --jq '.sha'
Write-Host "Blob 1265: $sha3"

# Get fork's main SHA for base_tree
$forkMainSha = gh api "repos/$fork/git/ref/heads/main" --jq '.object.sha'
Write-Host "Fork main SHA: $forkMainSha"

# Create tree on fork
$treeJson = @{
    base_tree = $forkMainSha
    tree = @(
        @{ path = "prs/1269-resiliencehub-ai.md"; mode = "100644"; type = "blob"; sha = $sha1 }
        @{ path = "prs/1267-platewise-ai.md"; mode = "100644"; type = "blob"; sha = $sha2 }
        @{ path = "prs/1265-respondermind-ai.md"; mode = "100644"; type = "blob"; sha = $sha3 }
    )
} | ConvertTo-Json -Depth 3 -Compress

$treeSha = $treeJson | gh api "repos/$fork/git/trees" --input - --jq '.sha'
Write-Host "Tree: $treeSha"

# Create commit on fork
$commitJson = @{
    message = "feat: add PR documents for #1269, #1267, #1265"
    parents = @($forkMainSha)
    tree = $treeSha
} | ConvertTo-Json -Compress

$commitSha = $commitJson | gh api "repos/$fork/git/commits" --input - --jq '.sha'
Write-Host "Commit: $commitSha"

# Create branch on fork
$branchName = "prs-auto-20260429"
$branchJson = @{ ref = "refs/heads/$branchName"; sha = $commitSha } | ConvertTo-Json -Compress
$branchRef = $branchJson | gh api "repos/$fork/git/refs" --input - --jq '.ref'
Write-Host "Branch: $branchRef"

# Create PRs from fork to upstream
Write-Host "`nCreating PRs..."

$pr1 = @{ title = "feat: ResilienceHub AI (Issue #1269)"; head = "wshten10:$branchName"; base = "main"; body = "Closes #1269`n`nAI-Powered Community Resilience Platform - comprehensive solution for disaster response, community vulnerability assessment, and emergency coordination." } | ConvertTo-Json -Compress
$r1 = $pr1 | gh api "repos/$upstream/pulls" --input - --jq '.html_url'
Write-Host "PR #1269: $r1"

$pr2 = @{ title = "feat: PlateWise AI (Issue #1267)"; head = "wshten10:$branchName"; base = "main"; body = "Closes #1267`n`nAI-Powered Smart Meal Planning and Household Food Management System - reducing food waste by 70% and saving families annually." } | ConvertTo-Json -Compress
$r2 = $pr2 | gh api "repos/$upstream/pulls" --input - --jq '.html_url'
Write-Host "PR #1267: $r2"

$pr3 = @{ title = "feat: ResponderMind AI (Issue #1265)"; head = "wshten10:$branchName"; base = "main"; body = "Closes #1265`n`nAI-Powered Mental Wellness Platform for First Responders - real-time stress monitoring, AI therapy, VR exposure therapy, and peer support." } | ConvertTo-Json -Compress
$r3 = $pr3 | gh api "repos/$upstream/pulls" --input - --jq '.html_url'
Write-Host "PR #1265: $r3"

Write-Host "`nDone!"
