import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const AuthScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _showPassword = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _handleSubmit() {
    setState(() => _loading = true);
    
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _loading = false);
        widget.onLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kumbh Suraksha',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'कुंभ सुरक्षा - Welcome Back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 32),

                // Card Section
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin 
                          ? 'Sign in to continue to your account'
                          : 'Create an account to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      // Form
                      if (!_isLogin) ...[
                        _buildLabel('Full Name'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Enter your name',
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildLabel('Email Address'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Enter your email',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        icon: LucideIcons.lock,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: AppTheme.textLight,
                          ),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),

                      if (_isLogin) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                          ),
                          child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFF1F5F9))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFF1F5F9))),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Toggle
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account? " : "Already have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => setState(() => _isLogin = !_isLogin),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isLogin ? 'Sign Up' : 'Sign In',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Demo Mode Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Demo Mode: Use any email and password to login',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9A3412),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textLight,
        ),
        prefixIcon: icon != null 
          ? Icon(icon, size: 18, color: AppTheme.textLight)
          : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: icon != null ? 12 : 16,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
