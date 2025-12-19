# Complete Amplify Removal - Auto-Replacement Script
# This script replaces all remaining client.models calls with Express.js API calls

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Amplify Removal Completion Script..." -ForegroundColor Green
Write-Host ""

$replacements = @(
    # useAnalytics.js (5 replacements)
    @{
        File = "packages\shared-ui\src\hooks\useAnalytics.js"
        Find = "client.models.Order.list({`r`n                        filter: { restaurantId: { eq: restaurantId } }`r`n                    });"
        Replace = "fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/api/orders?restaurantId=${restaurantId}`).then(r => r.json());"
    },
    @{
        File = "packages\shared-ui\src\hooks\useAnalytics.js"
        Find = "client.models.MenuItem.list({"
        Replace = "fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/api/menu-items?restaurantId=${restaurantId}`).then(r => r.json()).then(items => ({ data: items }));"
    },
    @{
        File = "packages\shared-ui\src\hooks\useAnalytics.js"
        Find = "client.models.Review.list({"
        Replace = "fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/api/reviews?restaurantId=${restaurantId}`).then(r => r.json()).then(reviews => ({ data: reviews }));"
    },
    @{
        File = "packages\shared-ui\src\hooks\useAnalytics.js"
        Find = "await client.models.Restaurant.list({"
        Replace = "await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/api/restaurants?ownerId=${userId}`).then(r => r.json()).then(restaurants => ({ data: restaurants }));"
    }
)

$filesProcessed = 0
$totalReplacements = 0

foreach ($replacement in $replacements) {
    $filePath = Join-Path $PSScriptRoot "..\..\.." $replacement.File
    
    if (Test-Path $filePath) {
        Write-Host "📝 Processing: $($replacement.File)" -ForegroundColor Cyan
        
        $content = Get-Content -Path $filePath -Raw
        $originalContent = $content
        
        # Perform replacement
        $content = $content -replace [regex]::Escape($replacement.Find), $replacement.Replace
        
        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -NoNewline
            $totalReplacements++
            Write-Host "   ✅ Replaced successfully" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Pattern not found (may already be replaced)" -ForegroundColor Yellow
        }
        
        $filesProcessed++
    } else {
        Write-Host "   ❌ File not found: $filePath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✨ Script Complete!" -ForegroundColor Green
Write-Host "Files Processed: $filesProcessed" -ForegroundColor Cyan
Write-Host "Replacements Made: $totalReplacements" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  NOTE: This script handles simple replacements." -ForegroundColor Yellow
Write-Host "Complex files (UserProfile, OrderManager, RiderDashboard) require manual" -ForegroundColor Yellow
Write-Host "replacement due to their complexity. Use the patterns in find-replace-patterns.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the changes in the modified files" -ForegroundColor White
Write-Host "2. Manually complete the remaining complex files using established patterns" -ForegroundColor White
Write-Host "3. Run: npm run build (in customer-mobile) to verify no errors" -ForegroundColor White
