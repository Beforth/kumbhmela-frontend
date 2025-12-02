# 🚀 Quick Start Guide - Kumbh Suraksha Flutter App

## Step-by-Step Setup

### 1. Prerequisites Check
Ensure you have the following installed:
- ✅ Flutter SDK (3.0.0+)
- ✅ Android Studio or VS Code
- ✅ Android SDK (API 21+)
- ✅ Java 17 or 21 (JDK)
- ✅ Git

### 2. Verify Flutter Installation
```bash
flutter doctor
```
Make sure all checks pass (especially Android toolchain).

### 3. Navigate to Project
```bash
cd c:\Users\Ady\Desktop\kumnbha\flutter_app
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Connect Device or Start Emulator
**Option A: Physical Device**
- Enable USB debugging on your Android phone
- Connect via USB
- Verify with: `flutter devices`

**Option B: Android Emulator**
- Open Android Studio
- AVD Manager → Create Virtual Device
- Start the emulator

### 6. Run the App
```bash
flutter run
```

## 📱 Testing the App

### Demo Login
- Email: `any@email.com` (any email works)
- Password: `any password` (any password works)

### Features to Test

1. **Home Screen**
   - View crowd alert banner
   - Click navigation pills
   - Try quick access cards

2. **Map Dashboard**
   - Zoom and pan the map
   - Click on crowd zone circles
   - View zone details below map

3. **Family Tracking**
   - See family members on map
   - Check battery levels
   - View distances

4. **Lost & Found**
   - Switch between Lost/Found tabs
   - Click "Report Lost" or "Report Found"
   - Fill out the form and submit

5. **Profile**
   - View account stats
   - Check account information
   - Test logout

## 🔧 Common Issues & Solutions

### Issue: "flutter: command not found"
**Solution**: Add Flutter to your PATH
```bash
# Add to your .bashrc or .zshrc
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "No devices found"
**Solution**: 
- Check USB debugging is enabled
- Try `flutter devices` to list available devices
- Restart ADB: `adb kill-server && adb start-server`

### Issue: "Gradle build failed"
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: "Package not found"
**Solution**:
```bash
flutter pub cache repair
flutter pub get
```

## 🎯 Building for Release

### Build APK
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Bundle location: `build/app/outputs/bundle/release/app-release.aab`

## 📊 Performance Tips

1. **Run in Release Mode**
   ```bash
   flutter run --release
   ```

2. **Profile the App**
   ```bash
   flutter run --profile
   ```

3. **Analyze Code**
   ```bash
   flutter analyze
   ```

## 🎨 Customization

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Your App Name">
```

### Change Package Name
Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.yourcompany.yourapp"
}
```

### Change App Icon
Replace files in `android/app/src/main/res/mipmap-*/ic_launcher.png`

## 📱 Supported Android Versions
- Minimum: Android 5.0 (API 21)
- Target: Android 14 (API 34)

## 🌐 Network Requirements
- Internet connection for map tiles
- Location services for GPS tracking

## 💡 Pro Tips

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` in terminal
3. **Clear Cache**: `flutter clean` before building
4. **Check Logs**: `flutter logs` for debugging

## 📞 Need Help?

- Flutter Docs: https://docs.flutter.dev/
- Flutter Community: https://flutter.dev/community
- Stack Overflow: Tag with `flutter`

---

**Happy Coding! 🎉**
