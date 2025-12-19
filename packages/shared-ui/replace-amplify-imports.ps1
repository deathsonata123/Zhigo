# Batch replace all aws-amplify imports with custom utilities
# Replace aws-amplify/auth with ../lib/auth or ../../lib/auth or ../../../lib/auth

$files = @(
    "src\features\rider\RiderOnboarding.tsx",
    "src\features\rider\RiderDashboard.tsx",
    "src\features\rider\EarningsView.tsx",
    "src\features\rider\DeliveryTasks.tsx",
    "src\features\rider\CheckRiderStatus.tsx",
    "src\features\restaurant\ReviewManager.tsx",
    "src\features\restaurant\PartnerOnboarding.tsx",
    "src\features\restaurant\OrderManager.tsx",
    "src\features\restaurant\MenuManagement.tsx",
    "src\features\restaurant\HoursManager.tsx",
    "src\features\customer\UserProfile.tsx",
    "src\features\customer\RestaurantDetails.tsx",
    "src\features\customer\MapBrowser.tsx",
    "src\features\customer\CheckoutFlow.tsx",
    "src\features\admin\AdminRestaurantList.tsx",
    "src\components\oauth-handler.tsx",
    "src\components\map.tsx",
    "src\components\header.tsx",
    "src\components\header-actions.tsx",
    "src\components\edit-menu-item-dialog.tsx",
    "src\components\add-menu-item-dialog.tsx"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processing: $file" -ForegroundColor Yellow
        $content = Get-Content $file -Raw
        
        # Determine relative path depth based on directory level
        $depth = ($file -split '\\').Count - 2  # subtract 'src' and filename
        $libPath = ("..\" * $depth) + "lib"
        
        # Replace aws-amplify/auth imports  
        $content = $content -replace "from 'aws-amplify/auth'", "from '$libPath/auth'"
        $content = $content -replace 'from "aws-amplify/auth"', "from '$libPath/auth'"
        
        # Replace aws-amplify/storage imports
        $content = $content -replace "from 'aws-amplify/storage'", "from '$libPath/storage'"
        $content = $content -replace 'from "aws-amplify/storage"', "from '$libPath/storage'"
        
        Set-Content $file $content -NoNewline
        Write-Host "  ✓ Updated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Red
    }
}

Write-Host "`nAll files processed!" -ForegroundColor Cyan
