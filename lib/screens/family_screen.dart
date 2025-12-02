import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants.dart';
import '../theme.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Tracking',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'परिवार ट्रैकिंग',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.plus, size: 14, color: AppTheme.primaryOrange),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map Preview
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(29.9500, 78.1600),
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kumbhsuraksha.app',
                ),
                MarkerLayer(
                  markers: MOCK_FAMILY.map((member) {
                    return Marker(
                      point: LatLng(member.location.lat, member.location.lng),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.user,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Family Members Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Family Members',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Family Members List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ...MOCK_FAMILY.map((member) => _buildFamilyMemberCard(context, member)),
                const SizedBox(height: 24),
                _buildInviteCard(context),
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

  Widget _buildFamilyMemberCard(BuildContext context, FamilyMember member) {
    Color avatarColor = member.name == 'Rajesh Kumar'
        ? AppTheme.primaryOrange
        : member.name == 'Sunita Devi'
            ? AppTheme.emerald
            : AppTheme.yellow;

    String initials = member.name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: member.status == MemberStatus.safe
                            ? AppTheme.primaryOrange
                            : const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member.status == MemberStatus.safe ? 'Safe' : 'Moving',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.navigation, size: 12, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${member.distanceKm} km away',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      member.lastActive,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.battery, size: 10, color: AppTheme.emerald),
                    const SizedBox(width: 4),
                    Text(
                      '${member.batteryLevel}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Track Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.navigation, size: 12, color: AppTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  'Track',
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
    );
  }

  Widget _buildInviteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.05),
        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Connect Family Members',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF9A3412),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your unique family code with your members to add them to your tracking circle. Ensure they have the app installed.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9A3412),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                foregroundColor: const Color(0xFF9A3412),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.share2, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Share Invite Code',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9A3412),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
