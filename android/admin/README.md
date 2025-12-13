# Zhigo Customer - Android App

## 🚀 Quick Start

### Prerequisites
- Android Studio Hedgehog or later
- JDK 17
- Android SDK 34
- Google Maps API Key

### Setup

1. **Open in Android Studio**
   ```bash
   cd android/customer
   # Open this folder in Android Studio
   ```

2. **Add Google Maps API Key**
   - Get API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Open `app/src/main/AndroidManifest.xml`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key

3. **Configure API URL**
   - For local development (emulator): Uses `http://10.0.2.2:3000` (already configured)
   - For production: Update `API_BASE_URL` in `app/build.gradle`

4. **Build & Run**
   - Click "Run" button in Android Studio
   - Or use command line:
   ```bash
   ./gradlew assembleDebug
   ./gradlew installDebug
   ```

## 📁 Project Structure

```
app/src/main/java/com/zhigo/customer/
├── ZhigoCustomerApp.kt          # Application class
├── MainActivity.kt              # Main activity
├── data/
│   ├── models/                  # Data models
│   │   └── Models.kt
│   ├── api/                     # Retrofit API
│   │   └── ApiService.kt
│   ├── local/                   # Local storage
│   │   └── TokenManager.kt
│   └── repository/              # Repository pattern
│       ├── AuthRepository.kt
│       └── RestaurantRepository.kt
├── di/                          # Dependency Injection
│   └── NetworkModule.kt
├── ui/
│   ├── viewmodels/              # ViewModels
│   │   ├── AuthViewModel.kt
│   │   └── RestaurantViewModel.kt
│   ├── screens/                 # Compose screens
│   │   ├── LoginScreen.kt
│   │   ├── RestaurantListScreen.kt
│   │   └── RestaurantDetailScreen.kt
│   ├── navigation/              # Navigation
│   │   └── NavGraph.kt
│   └── theme/                   # Material 3 theme
│       ├── Color.kt
│       ├── Theme.kt
│       └── Type.kt
```

## 🎨 Features

### Implemented ✅
- **Authentication**
  - Sign in with email/password
  - Token management (DataStore)
  - Auto-login on app start

- **Restaurant Browsing**
  - List all approved restaurants
  - Beautiful cards with images (Coil)
  - Filter by zone/city
  - Pull-to-refresh

- **UI/UX**
  - Material 3 design
  - Dark mode support
  - Smooth animations
  - Error handling

### Coming Soon 🚧
- Restaurant detail with menu
- Shopping cart
- Checkout flow
- Order tracking
- User profile
- Google Maps integration

## 🛠️ Technologies

- **Language**: Kotlin
- **UI**: Jetpack Compose + Material 3
- **Architecture**: MVVM
- **DI**: Hilt
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil
- **Storage**: DataStore
- **Navigation**: Compose Navigation

## 📡 API Integration

The app connects to your Express.js backend:

- **Local**: `http://10.0.2.2:3000` (Android emulator)
- **Production**: Configure in `build.gradle`

### Endpoints Used:
- `POST /api/auth/signin`
- `POST /api/auth/signup`
- `GET /api/auth/me`
- `GET /api/restaurants`
- `GET /api/restaurants/{id}`

## 🧪 Testing

### Run on Emulator
1. Create AVD in Android Studio
2. Select "Pixel 7" or similar
3. Click "Run"

### Run on Physical Device
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect via USB
4. Click "Run" and select your device

### Test Credentials
```
Email: test@example.com
Password: Test123!
```

## 🎨 Customization

### Change Colors
Edit `ui/theme/Color.kt`:
```kotlin
val Primary = Color(0xFFFF6B35)  // Your brand color
val Secondary = Color(0xFF4ECDC4)
```

### Change API URL
Edit `app/build.gradle`:
```gradle
buildConfigField "String", "API_BASE_URL", "\"https://api.yourdomain.com\""
```

## 📦 Build APK

```bash
# Debug APK
./gradlew assembleDebug

# Release APK (requires signing)
./gradlew assembleRelease
```

APK location: `app/build/outputs/apk/`

## 🐛 Troubleshooting

### Build Errors
```bash
# Clean and rebuild
./gradlew clean
./gradlew build
```

### Network Errors
- Check if backend is running
- Verify API URL in build.gradle
- Check internet permission in AndroidManifest.xml

### Hilt Errors
- Rebuild project
- Invalidate caches: File → Invalidate Caches / Restart

## 📝 Notes

- **Minimum SDK**: 24 (Android 7.0)
- **Target SDK**: 34 (Android 14)
- **APK Size**: ~15-20 MB
- **Permissions**: Internet, Location (for maps)

## 🚀 Next Steps

1. Complete remaining screens (detail, checkout, orders)
2. Add Google Maps integration
3. Implement push notifications
4. Add offline support
5. Optimize performance
6. Write unit tests

---

**Ready to build!** Open in Android Studio and click Run.
