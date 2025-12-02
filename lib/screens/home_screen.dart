import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

enum AppView { home, map, family, missing, profile }

class HomeScreen extends StatelessWidget {
  final Function(AppView) onChangeView;

  const HomeScreen({Key? key, required this.onChangeView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kumbh Suraksha',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'कुंभ सुरक्षा',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, size: 20),
                        color: AppTheme.textLight,
                        onPressed: () {},
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.user, size: 14, color: AppTheme.textMedium),
                            const SizedBox(width: 6),
                            Text(
                              'Hindi',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFCE8),
                      border: Border.all(color: const Color(0xFFFDE047)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow(),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: Color(0xFFCA8A04),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Moderate Crowd Alert',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF854D0E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Har Ki Pauri area has moderate crowd density. Please follow safety guidelines.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF92400E),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPill(context, LucideIcons.map, 'Heatmap', () => onChangeView(AppView.map)),
                        const SizedBox(width: 8),
                        _buildPill(context, LucideIcons.navigation, 'Navigate', () => onChangeView(AppView.map)),
                        const SizedBox(width: 8),
                        _buildPill(context, LucideIcons.users, 'Family', () => onChangeView(AppView.family)),
                        const SizedBox(width: 8),
                        _buildPill(context, LucideIcons.users, 'Find', () => onChangeView(AppView.missing)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Smart Navigation Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cardDecoration(radius: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.emerald.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.navigation,
                            color: AppTheme.emerald,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Smart Navigation',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find amenities and navigate safely',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => onChangeView(AppView.map),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Open Navigation',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Access
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Quick Access',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildQuickAccessCard(
                        context,
                        LucideIcons.navigation,
                        'Navigate',
                        'Find amenities',
                        AppTheme.emerald,
                        () => onChangeView(AppView.map),
                      ),
                      _buildQuickAccessCard(
                        context,
                        LucideIcons.users,
                        'Family Track',
                        'Track loved ones',
                        AppTheme.primaryOrange,
                        () => onChangeView(AppView.family),
                      ),
                      _buildQuickAccessCard(
                        context,
                        LucideIcons.heart,
                        'Lost & Found',
                        'Report or find',
                        AppTheme.rose,
                        () => onChangeView(AppView.missing),
                      ),
                      _buildQuickAccessCard(
                        context,
                        LucideIcons.mapPin,
                        'Shahi Marg',
                        'Procession route',
                        AppTheme.textDark,
                        () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Safety Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.05),
                      border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Tip of the Day',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Always stay hydrated and carry your emergency contact card. Keep your family tracking enabled.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMedium,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 100),
                ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.softShadow(),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textMedium),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
