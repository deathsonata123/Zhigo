# PowerShell script to batch-remove Amplify imports from all feature files
# Run from: packages/shared-ui

$files = @(
    "src/features/admin/AdminOverview.tsx",
    "src/features/admin/AdminRestaurantList.tsx",
    "src/features/admin/AdminRiderList.tsx",
    "src/features/customer/UserProfile.tsx",
    "src/features/customer/RestaurantDetails.tsx",
    "src/features/customer/MapBrowser.tsx",
    "src/features/customer/CheckoutFlow.tsx",
    "src/features/restaurant/ReviewManager.tsx",
    "src/features/restaurant/RestaurantDashboard.tsx",
    "src/features/restaurant/PartnerOnboarding.tsx",
    "src/features/restaurant/OrderManager.tsx",
    "src/features/restaurant/MenuManagement.tsx",
    "src/features/restaurant/HoursManager.tsx",
    "src/features/rider/RiderOnboarding.tsx",
    "src/features/rider/RiderDashboard.tsx",
    "src/features/rider/EarningsView.tsx",
    "src/features/rider/DeliveryTasks.tsx",
    "src/features/rider/CheckRiderStatus.tsx"
)

Write-Host "Batch-removing Amplify imports from $($files.Count) files..." -ForegroundColor Cyan

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Remove the import line
        $content = $content -replace "import { generateClient } from 'aws-amplify/data';\r?\n", ""
        
        # Remove the Schema import if on separate line
        $content = $content -replace "import type { Schema } from '@food-delivery/shared-types';\r?\n", ""
        
        # Remove the client declaration
        $content = $content -replace "const client = generateClient<Schema>\(\)( as any)?;\r?\n", ""
        
        Set-Content $file $content -NoNewline
        Write-Host "  OK $file" -ForegroundColor Green
    } else {
        Write-Host "  SKIP $file (not found)" -ForegroundColor Red
    }
}

Write-Host "`nDone! Now manually replace client.models calls with fetch APIs." -ForegroundColor Yellow
