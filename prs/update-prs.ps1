$ErrorActionPreference = "Stop"
$upstream = "ava-agent/awesome-ai-ideas"

# Update PR #1283 body
$body1 = '{"body":"Closes #1269\n\nResilienceHub AI - AI-Powered Community Resilience Platform\n\nComprehensive solution for disaster response, community vulnerability assessment, emergency coordination, and post-disaster recovery using multi-modal AI monitoring, predictive analytics, and real-time resource optimization."}'
$blob1 = (@{ body = "Closes #1269`n`nResilienceHub AI - AI-Powered Community Resilience Platform`n`nComprehensive solution for disaster response, community vulnerability assessment, emergency coordination, and post-disaster recovery using multi-modal AI monitoring, predictive analytics, and real-time resource optimization." } | ConvertTo-Json -Compress)
$blob1 | gh api "repos/$upstream/pulls/1283" --method PATCH --input - --jq '.html_url'

# Update PR #1284 body
$blob2 = (@{ body = "Closes #1267`n`nPlateWise AI - AI-Powered Smart Meal Planning and Household Food Management`n`nComprehensive AI-powered household food management system for smart meal planning, grocery optimization, inventory management, and recipe matching - reducing food waste by 70%% and saving families $6,000-12,000 annually." } | ConvertTo-Json -Compress)
$blob2 | gh api "repos/$upstream/pulls/1284" --method PATCH --input - --jq '.html_url'

# Update PR #1285 body  
$blob3 = (@{ body = "Closes #1265`n`nResponderMind AI - AI-Powered Mental Wellness Platform for First Responders`n`nComprehensive AI-driven mental wellness platform with real-time stress monitoring, AI therapy interventions, VR exposure therapy, peer matching, and continuous resilience building - reducing PTSD rates by 50%%." } | ConvertTo-Json -Compress)
$blob3 | gh api "repos/$upstream/pulls/1285" --method PATCH --input - --jq '.html_url'

Write-Host "All PR descriptions updated!"
