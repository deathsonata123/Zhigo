#!/usr/bin/env pwsh
# Script to remove all Amplify generateClient imports from shared-ui files
# This is a helper script - review changes before committing

$files = @(
    "packages/shared-ui/src/hooks/useAnalytics.js",
    "packages/shared-ui/src/components/header-actions.tsx",
    "packages/shared-ui/src/components/map.tsx",
    "packages/shared-ui/src/components/DeliveryRequestPopup.tsx",
    "packages/shared-ui/src/components/edit-menu-item-dialog.tsx",
    "packages/shared-ui/src/components/add-menu-item-dialog.tsx",
    "packages/shared-ui/src/components/ActiveDeliveryTracking.tsx",
    "packages/shared-ui/src/features/admin/AdminOverview.tsx",
    "packages/shared-ui/src/features/admin/AdminRestaurantList.tsx",
    "packages/shared-ui/src/features/admin/AdminRiderList.tsx",
    "packages/shared-ui/src/features/customer/UserProfile.tsx",
    "packages/shared-ui/src/features/customer/RestaurantDetails.tsx",
    "packages/shared-ui/src/features/customer/MapBrowser.tsx",
    "packages/shared-ui/src/features/customer/CheckoutFlow.tsx",
    "packages/shared-ui/src/features/restaurant/ReviewManager.tsx",
    "packages/shared-ui/src/features/restaurant/RestaurantDashboard.tsx",
    "packages/shared-ui/src/features/restaurant/PartnerOnboarding.tsx",
    "packages/shared-ui/src/features/restaurant/OrderManager.tsx",
    "packages/shared-ui/src/features/restaurant/MenuManagement.tsx",
    "packages/shared-ui/src/features/restaurant/HoursManager.tsx",
    "packages/shared-ui/src/features/rider/RiderOnboarding.tsx",
    "packages/shared-ui/src/features/rider/RiderDashboard.tsx",
    "packages/shared-ui/src/features/rider/EarningsView.tsx",
    "packages/shared-ui/src/features/rider/DeliveryTasks.tsx",
    "packages/shared-ui/src/features/rider/CheckRiderStatus.tsx"
)

Write-Host "Files with Amplify generateClient:" -ForegroundColor Yellow
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  - $file" -ForegroundColor Cyan
    }
}

Write-Host "`nTotal files to fix: $($files.Count)" -ForegroundColor Green
Write-Host "`nThese files need manual review to replace Amplify calls with Express.js API calls." -ForegroundColor Yellow
