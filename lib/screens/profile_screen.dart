import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Orange Header Card
            Container(
              color: AppTheme.primaryOrange.withOpacity(0.05),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'B',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'badgujaraditya6060',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'badgujaraditya6060@gmail.com',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textDark.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.emerald,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.emerald.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.checkCircle, size: 10, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Account',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.textDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.edit2, size: 12),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit Profile',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.edit2,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(context, '3', 'Family Members', AppTheme.primaryOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(context, '12', 'Days Active', AppTheme.textDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(context, '5', 'Safety Reports', AppTheme.emerald),
                  ),
                ],
              ),
            ),

            // Account Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          context,
                          LucideIcons.user,
                          'Full Name',
                          'badgujaraditya6060',
                          AppTheme.primaryOrange.withOpacity(0.1),
                          AppTheme.primaryOrange,
                        ),
                        const Divider(height: 1, color: Color(0xFFF8FAFC)),
                        _buildInfoTile(
                          context,
                          LucideIcons.mail,
                          'Email Address',
                          'badgujaraditya6060@gmail.com',
                          AppTheme.emerald.withOpacity(0.1),
                          AppTheme.emerald,
                        ),
                        const Divider(height: 1, color: Color(0xFFF8FAFC)),
                        _buildInfoTile(
                          context,
                          LucideIcons.phone,
                          'Phone Number',
                          '+91 9876543210',
                          const Color(0xFFF8FAFC),
                          AppTheme.textMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      children: [
                        _buildActionTile(
                          context,
                          LucideIcons.bell,
                          'Notifications',
                          AppTheme.textLight,
                          () {},
                        ),
                        const Divider(height: 1, color: Color(0xFFF8FAFC)),
                        _buildActionTile(
                          context,
                          LucideIcons.shield,
                          'Security',
                          AppTheme.textLight,
                          () {},
                        ),
                        const Divider(height: 1, color: Color(0xFFF8FAFC)),
                        _buildActionTile(
                          context,
                          LucideIcons.logOut,
                          'Logout',
                          AppTheme.rose,
                          onLogout,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String label,
    Color iconColor,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDestructive ? AppTheme.rose : AppTheme.textMedium,
                  fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
