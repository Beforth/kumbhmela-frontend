# Kumbh Suraksha - Flutter Android App

A production-ready Native Android App built with Flutter for Kumbh Mela safety and crowd management. This app is a pixel-perfect conversion of the React/Tailwind CSS web application.

## 🎯 Features

### 1. **Authentication**
- Clean login/signup interface
- Email/Password authentication
- Demo mode for testing
- Password visibility toggle

### 2. **Home Dashboard**
- Location-based header
- Real-time crowd alerts
- Quick navigation pills
- Smart navigation card
- Quick access grid
- Daily safety tips

### 3. **Map Dashboard**
- Full-screen interactive map using OpenStreetMap
- Real-time crowd heatmap with color-coded zones
- Live zone status updates
- Detailed zone information
- Capacity indicators
- Heatmap guide

### 4. **Family Tracking**
- Live map preview with family member markers
- Real-time location tracking
- Battery level monitoring
- Distance calculation
- Status indicators (Safe/Moving)
- Invite family members

### 5. **Lost & Found**
- Report lost persons/items
- Report found persons/items
- Search functionality
- Tabbed interface (Lost/Found)
- Photo upload capability
- Contact reporter functionality

### 6. **Profile**
- User profile with avatar
- Account statistics
- Account information management
- Quick action menu
- Logout functionality

## 🎨 Design System

### Colors
- **Primary Orange**: `#F97316`
- **Background Gray**: `#F1F5F9`
- **Emerald**: `#10B981`
- **Yellow**: `#EAB308`
- **Rose**: `#F43F5E`

### Typography
- **Font Family**: Plus Jakarta Sans (Google Fonts)
- Consistent font sizes and weights across all screens

### Components
- Custom cards with soft shadows
- Rounded corners (16px, 24px)
- Floating bottom navigation
- Orange active states
- Smooth animations

## 📦 Dependencies

```yaml
dependencies:
  flutter_map: ^6.1.0          # OpenStreetMap integration
  latlong2: ^0.9.0             # Latitude/Longitude handling
  google_fonts: ^6.1.0         # Plus Jakarta Sans font
  lucide_icons: ^0.0.1         # Icon library
  url_launcher: ^6.2.2         # Phone calls/navigation
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android SDK (API 21+)
- Git

### Installation

1. **Navigate to the Flutter app directory**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle (for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

## 📱 Screens

1. **Auth Screen** - `lib/screens/auth_screen.dart`
2. **Home Screen** - `lib/screens/home_screen.dart`
3. **Map Dashboard** - `lib/screens/map_dashboard_screen.dart`
4. **Family Tracking** - `lib/screens/family_screen.dart`
5. **Lost & Found** - `lib/screens/missing_screen.dart`
6. **Profile** - `lib/screens/profile_screen.dart`

## 🗂️ Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── constants.dart               # Mock data and constants
│   ├── theme.dart                   # App theme configuration
│   ├── screens/
│   │   ├── auth_screen.dart
│   │   ├── home_screen.dart
│   │   ├── map_dashboard_screen.dart
│   │   ├── family_screen.dart
│   │   ├── missing_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/
│       └── bottom_nav_bar.dart      # Custom bottom navigation
├── android/                         # Android-specific files
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## 🎯 Key Implementation Details

### Map Integration
- Uses `flutter_map` package with OpenStreetMap tiles
- Custom circle markers for crowd zones
- Color-coded based on crowd density
- Interactive markers with popups

### State Management
- Simple setState for local state
- Stateful widgets for interactive screens
- Controlled forms with TextEditingController

### Navigation
- Custom bottom navigation bar
- View-based navigation (enum AppView)
- Smooth transitions between screens

### Animations
- Login toast animation
- SOS button pulse effect
- Smooth view transitions

## 🔒 Permissions

The app requires the following Android permissions:
- `INTERNET` - For map tiles and API calls
- `ACCESS_FINE_LOCATION` - For precise location tracking
- `ACCESS_COARSE_LOCATION` - For approximate location

## 🌐 Mock Data

The app includes comprehensive mock data in `constants.dart`:
- 3 family members with real-time tracking data
- 2 missing person reports
- 6 crowd zones with different status levels

## 🎨 Visual Parity

This Flutter app achieves **pixel-perfect visual parity** with the React web app:
- Exact color scheme
- Matching typography (Plus Jakarta Sans)
- Identical component layouts
- Same spacing and padding
- Consistent shadows and borders
- Matching animations and transitions

## 📝 Notes

- The app is configured for demo mode - any email/password will work for login
- All data is currently mocked - integrate with your backend API for production
- Map tiles are loaded from OpenStreetMap (free tier)
- Icons use the Lucide Icons library to match the React app

## 🚧 Future Enhancements

- Backend API integration
- Real-time location tracking
- Push notifications
- Offline mode support
- Multi-language support (Hindi/English)
- Dark mode theme

## 📄 License

This project is created for the Kumbh Mela safety initiative.

## 👨‍💻 Development

For any issues or questions, please refer to the Flutter documentation:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Map Package](https://pub.dev/packages/flutter_map)
- [Google Fonts](https://pub.dev/packages/google_fonts)

---

**Built with ❤️ using Flutter**
