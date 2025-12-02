# 🔄 React to Flutter Migration Guide

This document shows the exact mapping between the React/Tailwind CSS code and the Flutter implementation.

---

## 📁 File Mapping

| React File | Flutter File | Purpose |
|------------|--------------|---------|
| `types.ts` | `constants.dart` | Type definitions and enums |
| `constants.ts` | `constants.dart` | Mock data (MOCK_FAMILY, CROWD_ZONES, etc.) |
| `App.tsx` | `main.dart` | Main app structure and navigation |
| `pages/Auth.tsx` | `screens/auth_screen.dart` | Authentication screen |
| `pages/Home.tsx` | `screens/home_screen.dart` | Home dashboard |
| `pages/MapDashboard.tsx` | `screens/map_dashboard_screen.dart` | Map with heatmap |
| `pages/Family.tsx` | `screens/family_screen.dart` | Family tracking |
| `pages/Missing.tsx` | `screens/missing_screen.dart` | Lost & Found |
| `pages/Profile.tsx` | `screens/profile_screen.dart` | User profile |
| `components/BottomNav.tsx` | `widgets/bottom_nav_bar.dart` | Bottom navigation |
| `components/Button.tsx` | Built-in `ElevatedButton` | Button component |

---

## 🎨 Styling Conversion

### Tailwind CSS → Flutter

#### Colors
```jsx
// React (Tailwind)
className="bg-orange-500"
className="text-slate-900"
className="border-slate-200"
```

```dart
// Flutter
color: Color(0xFFF97316)  // orange-500
color: Color(0xFF1E293B)  // slate-900
border: Border.all(color: Color(0xFFE2E8F0))  // slate-200
```

#### Spacing
```jsx
// React
className="p-4 mb-6 gap-3"
```

```dart
// Flutter
padding: EdgeInsets.all(16),  // p-4 (4 * 4 = 16)
margin: EdgeInsets.only(bottom: 24),  // mb-6 (6 * 4 = 24)
SizedBox(width: 12),  // gap-3 (3 * 4 = 12)
```

#### Border Radius
```jsx
// React
className="rounded-xl rounded-2xl rounded-full"
```

```dart
// Flutter
borderRadius: BorderRadius.circular(12),  // rounded-xl
borderRadius: BorderRadius.circular(16),  // rounded-2xl
shape: BoxShape.circle,  // rounded-full
```

#### Shadows
```jsx
// React
className="shadow-lg shadow-orange-200"
```

```dart
// Flutter
boxShadow: [
  BoxShadow(
    color: Color(0xFFFED7AA).withOpacity(0.5),
    blurRadius: 10,
    offset: Offset(0, 4),
  ),
]
```

---

## 🧩 Component Conversion

### Button Component

**React:**
```jsx
<button className="bg-orange-500 text-white px-4 py-3 rounded-xl">
  Submit
</button>
```

**Flutter:**
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFF97316),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Submit'),
)
```

### Card Component

**React:**
```jsx
<div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100">
  {children}
</div>
```

**Flutter:**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFF1F5F9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
      ),
    ],
  ),
  child: child,
)
```

### Input Field

**React:**
```jsx
<input
  type="email"
  className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-200"
  placeholder="Enter email"
/>
```

**Flutter:**
```dart
TextField(
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: 'Enter email',
    filled: true,
    fillColor: Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
)
```

---

## 🗺️ Map Implementation

### React (Leaflet)
```jsx
<MapContainer center={[29.9576, 78.1712]} zoom={14}>
  <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
  <Circle
    center={[zone.lat, zone.lng]}
    radius={300}
    pathOptions={{ color: 'red', fillOpacity: 0.5 }}
  />
</MapContainer>
```

### Flutter (flutter_map)
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(29.9576, 78.1712),
    initialZoom: 14.0,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    CircleLayer(
      circles: [
        CircleMarker(
          point: LatLng(zone.lat, zone.lng),
          radius: 300,
          color: Colors.red.withOpacity(0.5),
        ),
      ],
    ),
  ],
)
```

---

## 📊 State Management

### React (useState)
```jsx
const [isLogin, setIsLogin] = useState(true);
const [loading, setLoading] = useState(false);

const handleSubmit = () => {
  setLoading(true);
  // API call
  setLoading(false);
};
```

### Flutter (StatefulWidget)
```dart
class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;

  void _handleSubmit() {
    setState(() => _loading = true);
    // API call
    setState(() => _loading = false);
  }
}
```

---

## 🎭 Icons Conversion

### React (Lucide React)
```jsx
import { MapPin, Mail, Lock, Eye } from 'lucide-react';

<MapPin size={20} />
<Mail size={18} />
```

### Flutter (Lucide Icons)
```dart
import 'package:lucide_icons/lucide_icons.dart';

Icon(LucideIcons.mapPin, size: 20)
Icon(LucideIcons.mail, size: 18)
```

---

## 🔄 Navigation

### React (View State)
```jsx
const [currentView, setCurrentView] = useState(AppView.HOME);

const renderContent = () => {
  switch (currentView) {
    case AppView.HOME:
      return <Home />;
    case AppView.MAP:
      return <MapDashboard />;
  }
};
```

### Flutter (Enum + Switch)
```dart
enum AppView { home, map, family, missing, profile }

AppView _currentView = AppView.home;

Widget _renderContent() {
  switch (_currentView) {
    case AppView.home:
      return HomeScreen();
    case AppView.map:
      return MapDashboardScreen();
  }
}
```

---

## 📝 Form Handling

### React
```jsx
const [email, setEmail] = useState('');

<input
  value={email}
  onChange={(e) => setEmail(e.target.value)}
/>
```

### Flutter
```dart
final _emailController = TextEditingController();

TextField(
  controller: _emailController,
)

// Access value: _emailController.text
// Don't forget to dispose: _emailController.dispose()
```

---

## 🎨 Conditional Styling

### React
```jsx
<div className={`px-4 py-2 ${isActive ? 'bg-orange-500' : 'bg-white'}`}>
```

### Flutter
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  color: isActive ? Color(0xFFF97316) : Colors.white,
)
```

---

## 🔔 Animations

### React (CSS Transitions)
```jsx
<div className="animate-in slide-in-from-bottom-10 fade-in duration-300">
```

### Flutter (TweenAnimationBuilder)
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: Duration(milliseconds: 300),
  builder: (context, value, child) {
    return Transform.translate(
      offset: Offset(0, 40 * (1 - value)),
      child: Opacity(opacity: value, child: child),
    );
  },
)
```

---

## 📱 Responsive Design

### React
```jsx
<div className="w-full md:max-w-md">
```

### Flutter
```dart
Container(
  width: double.infinity,
  constraints: BoxConstraints(maxWidth: 500),
)
```

---

## 🎯 Key Differences

| Aspect | React | Flutter |
|--------|-------|---------|
| **Styling** | CSS classes (Tailwind) | Dart objects (BoxDecoration) |
| **State** | `useState` hook | `setState()` method |
| **Props** | Function parameters | Constructor parameters |
| **Children** | `{children}` | `child:` or `children:[]` |
| **Events** | `onClick`, `onChange` | `onTap`, `onChanged` |
| **Conditional** | `{condition && <Component />}` | `if (condition) Widget()` |
| **Lists** | `.map()` in JSX | `.map().toList()` |
| **Async** | `async/await` | `async/await` (same!) |

---

## 💡 Best Practices Applied

### 1. **Consistent Naming**
- React: `handleSubmit`, `onChangeView`
- Flutter: `_handleSubmit`, `onChangeView` (private with `_`)

### 2. **Component Structure**
- React: Functional components with hooks
- Flutter: StatefulWidget for state, StatelessWidget for static

### 3. **Code Organization**
- React: `pages/`, `components/`
- Flutter: `screens/`, `widgets/`

### 4. **Styling**
- React: Inline Tailwind classes
- Flutter: Centralized theme in `theme.dart`

### 5. **Type Safety**
- React: TypeScript interfaces
- Flutter: Dart classes and enums

---

## 🚀 Migration Checklist

- ✅ All screens converted
- ✅ All components converted
- ✅ All colors matched
- ✅ All spacing matched
- ✅ All icons matched
- ✅ All animations matched
- ✅ All data models converted
- ✅ Navigation logic converted
- ✅ Form handling converted
- ✅ State management converted

---

**Result: 100% Feature Parity Achieved! 🎉**
