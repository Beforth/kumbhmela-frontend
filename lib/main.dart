import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_dashboard_screen.dart';
import 'screens/family_screen.dart';
import 'screens/missing_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/sos_dialog.dart';
import 'api_client.dart';
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
      home: MainApp(initialLink: null),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key, this.initialLink}) : super(key: key);
  
  final String? initialLink;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isAuthenticated = false;
  bool _isLoading = true; // Add loading state
  AppView _currentView = AppView.home;
  bool _showLoginToast = false;
  String? _accessToken;
  String? _userEmail;
  String? _fullName;
  final _api = ApiClient();
  String? _pendingInvitationToken; // Store pending invitation token

  static const platform = MethodChannel('com.kumbhsuraksha.app/deeplink');

  @override
  void initState() {
    super.initState();
    _checkAuthState().then((_) {
      // After auth state is checked, handle deep links
      _initDeepLinking();
      
      // Handle initial deep link if app was opened from a link
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.initialLink != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _handleDeepLink(widget.initialLink);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initDeepLinking() {
    // Handle app opened from terminated state
    _handleInitialLink();
  }

  Future<void> _handleInitialLink() async {
    try {
      // Get initial link from Android intent
      final String? initialLink = await platform.invokeMethod('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        print('App opened from deep link: $initialLink');
        // Wait a bit for auth state to be checked first
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Error getting initial link: $e');
      // If platform channel fails, try to handle widget.initialLink
      if (widget.initialLink != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(widget.initialLink);
      }
    }
  }

  Future<void> _handleDeepLink(String? url) async {
    if (url == null) return;
    
    print('Processing deep link: $url');
    
    try {
      final uri = Uri.parse(url);
      
      // Handle kumbhsuraksha://invite?token=xxx
      if (uri.scheme == 'kumbhsuraksha' && uri.host == 'invite') {
        final token = uri.queryParameters['token'];
        
        if (token != null && token.isNotEmpty) {
          print('Found invitation token: $token');
          await _processInvitationToken(token);
        } else {
          print('No token found in deep link');
        }
      } else {
        print('Unknown deep link format: $url');
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  Future<void> _processInvitationToken(String token) async {
    print('Processing invitation token: $token');
    print('Current auth state: isAuthenticated=$_isAuthenticated, userEmail=$_userEmail');
    
    try {
      // Get invitation details first
      final invitationData = await _api.getFamilyInvitation(token);
      final inviteeEmail = invitationData['invitee_email'] as String?;
      
      print('Invitation invitee email: $inviteeEmail');
      
      if (inviteeEmail == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid invitation link'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Check if user is logged in
      if (_isAuthenticated && _userEmail != null) {
        print('User is logged in. Checking email match...');
        // User is logged in - check if email matches
        if (_userEmail!.toLowerCase() == inviteeEmail.toLowerCase()) {
          print('Email matches! Auto-accepting invitation...');
          // Same user - auto-accept invitation
          await _autoAcceptInvitation(token);
        } else {
          print('Email does not match. Current: $_userEmail, Invitation: $inviteeEmail');
          // Different user - show message
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Invitation for Different Account'),
                content: Text(
                  'This invitation is for $inviteeEmail, but you are logged in as $_userEmail. '
                  'Please logout and login with the correct account to accept this invitation.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        print('User not logged in. Showing login dialog with pre-filled email: $inviteeEmail');
        // User not logged in - store token and show login dialog with pre-filled email
        _pendingInvitationToken = token;
        _showInvitationAcceptanceScreen(token, inviteeEmail);
      }
    } catch (e) {
      print('Error processing invitation token: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading invitation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _autoAcceptInvitation(String token) async {
    if (!mounted || _userEmail == null) {
      print('Cannot auto-accept: mounted=$mounted, userEmail=$_userEmail');
      return;
    }
    
    print('Auto-accepting invitation for user: $_userEmail');
    
    try {
      // Get user's password from stored credentials or prompt
      // For now, we'll show a dialog asking for password
      final password = await _showPasswordDialog();
      if (password == null || password.isEmpty) {
        print('User cancelled password dialog');
        return; // User cancelled
      }
      
      print('Accepting invitation with token: $token');
      
      // Accept invitation
      await _api.acceptFamilyInvitation(
        token: token,
        email: _userEmail!,
        password: password,
      );
      
      print('Invitation accepted successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the family!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error accepting invitation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting invitation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    
    print('Showing password dialog for invitation acceptance');
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to accept the family invitation.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Password dialog cancelled');
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = passwordController.text;
              if (password.isNotEmpty) {
                print('Password entered, accepting invitation');
                Navigator.of(context).pop(password);
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showInvitationAcceptanceScreen(String token, String? prefillEmail) {
    // Navigate to a screen that handles invitation acceptance
    // For now, we'll show a dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _InvitationAcceptanceDialog(
        token: token,
        api: _api,
        prefillEmail: prefillEmail,
        onLoginSuccess: (email, password) async {
          // After successful login, auto-accept invitation
          try {
            await _api.acceptFamilyInvitation(
              token: token,
              email: email,
              password: password,
            );
            
            if (mounted) {
              Navigator.of(context).pop(); // Close invitation dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully joined the family!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error accepting invitation: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _checkAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final email = prefs.getString('user_email');
      final fullName = prefs.getString('user_full_name');

      if (token != null && token.isNotEmpty) {
        setState(() {
          _accessToken = token;
          _userEmail = email;
          _fullName = fullName;
          _isAuthenticated = true;
        });
      }
    } catch (e) {
      print('Error checking auth state: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin({
    required String accessToken,
    required String email,
    required String fullName,
  }) async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('user_email', email);
      await prefs.setString('user_full_name', fullName);

      setState(() {
        _isAuthenticated = true;
        _showLoginToast = true;
        _accessToken = accessToken;
        _userEmail = email;
        _fullName = fullName;
      });
      
      // Check if there's a pending invitation token to auto-accept
      if (_pendingInvitationToken != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _processInvitationToken(_pendingInvitationToken!);
        _pendingInvitationToken = null; // Clear after processing
      }
      
      // Hide toast after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showLoginToast = false);
        }
      });
    } catch (e) {
      print('Error saving auth state: $e');
      // Still set state even if saving fails
      setState(() {
        _isAuthenticated = true;
        _showLoginToast = true;
        _accessToken = accessToken;
        _userEmail = email;
        _fullName = fullName;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_email');
      await prefs.remove('user_full_name');
    } catch (e) {
      print('Error clearing auth state: $e');
    }

    setState(() {
      _isAuthenticated = false;
      _currentView = AppView.home;
      _accessToken = null;
      _userEmail = null;
      _fullName = null;
    });
  }

  void _handleChangeView(AppView view) {
    setState(() => _currentView = view);
  }

  void _showSosScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SosScreen(
          onSosActivated: (SosType type, int? sosRequestId) {
            _activateSos(context, type, sosRequestId);
          },
          userEmail: _userEmail,
          userName: _fullName,
          accessToken: _accessToken,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _activateSos(BuildContext context, SosType type, int? sosRequestId) async {
    // Navigate to SOS alert screen with request ID for status polling
    // The request has already been sent from SosScreen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SosAlertScreen(
            sosType: type,
            sosRequestId: sosRequestId,
            accessToken: _accessToken,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget _renderContent() {
    switch (_currentView) {
      case AppView.home:
        return HomeScreen(onChangeView: _handleChangeView);
      case AppView.map:
        return const MapDashboardScreen();
      case AppView.family:
        return FamilyScreen(
          userEmail: _userEmail,
          accessToken: _accessToken,
        );
      case AppView.missing:
        return MissingScreen(
          userEmail: _userEmail,
          accessToken: _accessToken,
        );
      case AppView.profile:
        return ProfileScreen(
          onLogout: _handleLogout,
          accessToken: _accessToken,
          email: _userEmail,
          fullName: _fullName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                      _showSosScreen(context);
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

// Invitation Acceptance Dialog
class _InvitationAcceptanceDialog extends StatefulWidget {
  final String token;
  final ApiClient api;
  final String? prefillEmail;
  final Future<void> Function(String email, String password)? onLoginSuccess;

  const _InvitationAcceptanceDialog({
    required this.token,
    required this.api,
    this.prefillEmail,
    this.onLoginSuccess,
  });

  @override
  State<_InvitationAcceptanceDialog> createState() => _InvitationAcceptanceDialogState();
}

class _InvitationAcceptanceDialogState extends State<_InvitationAcceptanceDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _invitationData;

  @override
  void initState() {
    super.initState();
    // Pre-fill email immediately if provided
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
      print('Pre-filled email: ${widget.prefillEmail}');
    }
    _loadInvitationDetails();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitationDetails() async {
    try {
      final data = await widget.api.getFamilyInvitation(widget.token);
      if (mounted) {
        setState(() {
          _invitationData = data;
          // Only set email if not already pre-filled
          // Check both widget.prefillEmail and current controller value
          if ((widget.prefillEmail == null || widget.prefillEmail!.isEmpty) && 
              _emailController.text.isEmpty &&
              data['invitee_email'] != null) {
            _emailController.text = data['invitee_email'] as String;
            print('Set email from invitation data: ${data['invitee_email']}');
          } else {
            print('Email already set, not overwriting. Prefill: ${widget.prefillEmail}, Controller: ${_emailController.text}');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading invitation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _acceptInvitation() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // If onLoginSuccess callback is provided, use it (for auto-accept after login)
      if (widget.onLoginSuccess != null) {
        await widget.onLoginSuccess!(email, password);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Direct acceptance
        await widget.api.acceptFamilyInvitation(
          token: widget.token,
          email: email,
          password: password,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined the family!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.userPlus, color: AppTheme.primaryOrange),
          SizedBox(width: 8),
          Text('Accept Family Invitation'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_invitationData != null) ...[
              Text(
                'You have been invited by: ${_invitationData!['inviter_email'] ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: widget.prefillEmail == null, // Disable if pre-filled
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _acceptInvitation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Accept Invitation'),
        ),
      ],
    );
  }
}
