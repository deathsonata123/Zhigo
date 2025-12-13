# Comprehensive script to replace ALL client.models calls with fetch() API calls
# This handles files that still reference 'client' after imports were removed

$apiUrl = 'process.env.NEXT_PUBLIC_API_URL || ''http://localhost:3000'''

# Define replacement patterns
$replacements = @(
    # Restaurant.list()
    @{
        Pattern = 'const \{ data: restaurants \} = await client\.models\.Restaurant\.list\(\);'
        Replacement = "const apiUrl = $apiUrl;`n      const response = await fetch(````${apiUrl}/api/restaurants````);" + "`n      if (!response.ok) throw new Error('Failed to fetch restaurants');`n      const restaurants = await response.json();"
    },
    # Rider.list()
    @{
        Pattern = 'const \{ data: riders(Data)? \} = await client\.models\.Rider\.list\(\);'
        Replacement = "const apiUrl = $apiUrl;`n            const response = await fetch(````${apiUrl}/api/riders````);" + "`n            if (!response.ok) throw new Error('Failed to fetch riders');`n            const ridersData = await response.json();            const riders = ridersData;"
    },
    # Generic list with filter pattern - will need manual handling for complex cases
    @{
        Pattern = 'const \{ data: (\w+) \} = await client\.models\.(\w+)\.list\('
        Replacement = 'const apiUrl = ' + $apiUrl + ';' + "`n      const response = await fetch(````${apiUrl}/api/ENDPOINT````);" + "`n      // TODO: Add query params for filter`n      const `$1 = await response.json();"
    }
)

Write-Host "This script requires manual fixing due to complexity of patterns." -ForegroundColor Yellow
Write-Host "Please use the walkthrough.md guide for step-by-step instructions." -ForegroundColor Cyan
