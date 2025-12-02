import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_dashboard_screen.dart';
import 'screens/family_screen.dart';
import 'screens/missing_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const KumbhSurakshaApp());
}

class KumbhSurakshaApp extends StatelessWidget {
  const KumbhSurakshaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kumbh Suraksha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isAuthenticated = false;
  AppView _currentView = AppView.home;
  bool _showLoginToast = false;

  void _handleLogin() {
    setState(() {
      _isAuthenticated = true;
      _showLoginToast = true;
    });
    
    // Hide toast after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showLoginToast = false);
      }
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _currentView = AppView.home;
    });
  }

  void _handleChangeView(AppView view) {
    setState(() => _currentView = view);
  }

  Widget _renderContent() {
    switch (_currentView) {
      case AppView.home:
        return HomeScreen(onChangeView: _handleChangeView);
      case AppView.map:
        return const MapDashboardScreen();
      case AppView.family:
        return const FamilyScreen();
      case AppView.missing:
        return const MissingScreen();
      case AppView.profile:
        return ProfileScreen(onLogout: _handleLogout);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(onLogin: _handleLogin);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              Expanded(child: _renderContent()),
              BottomNavBar(
                currentView: _currentView,
                onChangeView: _handleChangeView,
              ),
            ],
          ),

          // Login Success Toast
          if (_showLoginToast)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        color: AppTheme.emerald,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login Successful!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Welcome back to Kumbh Suraksha',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // SOS Floating Button
          Positioned(
            bottom: 110,
            right: 16,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.rose,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.rose.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // SOS action
                    },
                    customBorder: const CircleBorder(),
                    child: const Center(
                      child: Icon(
                        LucideIcons.alertCircle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
