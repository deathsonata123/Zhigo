# Flutter Implementation Guide

## Files Created

### 1. Partner Banner Widget
**Location:** `e:\visual_studio_code\zhigo-clean\android\customer_mobile\lib\widgets\partner_banner.dart`

This widget displays a "Become a Zhigo Partner" banner at the top of the app. Features:
- Dismissible banner with close button
- Checks if user already has a restaurant
- Only shows if user is authenticated and doesn't have a restaurant
- Navigates to partner onboarding screen

### 2. Map Screen
**Location:** `e:\visual_studio_code\zhigo-clean\android\customer_mobile\lib\screens\map_screen.dart`

Full-featured Mapbox map screen with:
- 3D terrain enabled
- Camera settings (center: Dhaka, zoom 16, pitch 70°, bearing -17.6°)
- Right sidebar with circular action buttons for:
  - Restaurants navigation
  - Map view (current page)
  - Time of day selector (Day/Dawn/Dusk/Night)
  - Shopping cart
  - User profile
- Mapbox Streets style

### 3. Updated App Header
**Modified:** `e:\visual_studio_code\zhigo-clean\android\customer_mobile\lib\widgets\app_header.dart`

Added partner banner integration:
- New `showPartnerBanner` parameter (defaults to `true`)
- Displays `PartnerBanner` widget above the AppBar
- Dynamically adjusts `preferredSize` based on banner visibility

## Setup Instructions

### 1. Install Dependencies
Run this command to install the new Mapbox dependency:
```bash
cd e:\visual_studio_code\zhigo-clean\android\customer_mobile
flutter pub get
```

### 2. Configure Mapbox API Key

You need to add your Mapbox access token. There are two ways to do this:

**Option A: Environment Variable (Recommended)**
Add to your app's initialization code:
```dart
// In main.dart or where you initialize your app
const String mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue: 'YOUR_MAPBOX_TOKEN_HERE',
);
```

**Option B: Direct Configuration**
Edit `map_screen.dart` and add at the top of the file:
```dart
const String mapboxAccessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';
```

To get a Mapbox access token:
1. Go to https://account.mapbox.com/
2. Sign up or log in
3. Navigate to your access tokens
4. Copy your default public token

### 3. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <!-- Add inside application tag -->
        <meta-data
            android:name="com.mapbox.token"
            android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
    </application>
</manifest>
```

### 4. Add Route to Navigation

In your main app file (likely `main.dart` or route configuration), add the map screen route:

```dart
routes: {
  '/map': (context) => const MapScreen(),
  // ... other routes
},
```

### 5. Where to Paste the Mapbox Access Token

**Paste your Mapbox access token in TWO places:**

1. **In `map_screen.dart`**: Add this constant at the top of the file after the imports:
   ```dart
   const String mapboxAccessToken = 'pk.YOUR_MAPBOX_TOKEN_HERE';
   ```

2. **In `android/app/src/main/AndroidManifest.xml`**: Replace `YOUR_MAPBOX_ACCESS_TOKEN` with your actual token

## Usage

### Display Partner Banner
The partner banner is automatically displayed in any screen using `AppHeader`. To hide it on specific screens:

```dart
appBar: const AppHeader(
  title: 'My Screen',
  showPartnerBanner: false, // Hide banner on this screen
),
```

### Navigate to Map Screen
```dart
Navigator.pushNamed(context, '/map');
```

## Web Component Reference

The Flutter implementation matches the functionality from these web components:
- **Header Banner**: `packages/shared-ui/src/components/header.tsx` (lines 14-64)
- **Map Implementation**: `packages/shared-ui/src/components/map.tsx`

## Next Steps

1. ✅ Created partner banner widget
2. ✅ Created map screen with Mapbox
3. ✅ Integrated banner into app header
4. ✅ Added Mapbox dependency
5. ⏳ Run `flutter pub get` to install dependencies
6. ⏳ Add Mapbox access token (see instructions above)
7. ⏳ Add route configuration for `/map`
8. ⏳ Test on device/emulator
