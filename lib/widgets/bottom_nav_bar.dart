import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/home_screen.dart';
import '../theme.dart';

class BottomNavBar extends StatelessWidget {
  final AppView currentView;
  final Function(AppView) onChangeView;

  const BottomNavBar({
    Key? key,
    required this.currentView,
    required this.onChangeView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      NavItem(view: AppView.home, icon: LucideIcons.home, label: 'Home'),
      NavItem(view: AppView.map, icon: LucideIcons.map, label: 'Map'),
      NavItem(view: AppView.family, icon: LucideIcons.users, label: 'Family'),
      NavItem(view: AppView.missing, icon: LucideIcons.search, label: 'Find'),
      NavItem(view: AppView.profile, icon: LucideIcons.user, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = currentView == item.view;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChangeView(item.view),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive ? AppTheme.primaryOrange : AppTheme.textLight,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: isActive ? AppTheme.primaryOrange : AppTheme.textLight,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final AppView view;
  final IconData icon;
  final String label;

  NavItem({required this.view, required this.icon, required this.label});
}
