# API Connection Setup

## You're getting "Connection Refused" because:

Your mobile app is trying to connect to `localhost:3000`, but **localhost on your phone means the phone itself**, not your computer.

## Solution - Choose ONE:

### Option 1: Use Your Computer's Local IP (Physical Device)

1. **Find your computer's IP address:**
   ```bash
   # Windows
   ipconfig
   # Look for "IPv4 Address" (e.g., 192.168.1.100)
   ```

2. **Update `lib/config/api_config.dart` line 9:**
   ```dart
   defaultValue: 'http://192.168.1.100:3000', // Use YOUR IP
   ```

3. **Make sure:**
   - Your phone and computer are on the SAME WiFi
   - Backend is running on your computer (`npm run dev`)
   - Firewall allows port 3000

### Option 2: Use EC2 Backend (Recommended)

If your backend is already deployed to EC2:

1. **Update `lib/config/api_config.dart` line 9:**
   ```dart
   defaultValue: 'https://api.yourdomain.com', // Your EC2 URL
   ```

2. **Make sure:**
   - EC2 instance is running
   - Security group allows HTTPS/HTTP
   - Backend is accessible from internet

### Option 3: Android Emulator (Currently set)

If using Android Studio emulator:
- Already set to `10.0.2.2:3000` (emulator's special address for host PC)
- Make sure backend is running

## Current Setup

**File**: `lib/config/api_config.dart`
**Current default**: `http://10.0.2.2:3000` (for emulator)

**Change this** to match your setup!

## After Changing

1. Save the file
2. Hot restart the app (press `R` in terminal or click reload in Android Studio)
3. Try signing up again
