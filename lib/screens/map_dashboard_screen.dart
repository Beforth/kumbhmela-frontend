import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants.dart';
import '../theme.dart';

class MapDashboardScreen extends StatefulWidget {
  const MapDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MapDashboardScreen> createState() => _MapDashboardScreenState();
}

class _MapDashboardScreenState extends State<MapDashboardScreen> {
  bool _loading = false;

  void _refreshData() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Color _getColorCode(String color) {
    switch (color) {
      case 'red':
        return const Color(0xFFF43F5E);
      case 'orange':
        return const Color(0xFFF97316);
      case 'yellow':
        return const Color(0xFFEAB308);
      case 'green':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

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
                        'Crowd Heatmap',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'भीड़ का नक्शा',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _refreshData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.refreshCw,
                            size: 14,
                            color: AppTheme.textMedium,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Update',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Legend Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLegendItem('Safe', AppTheme.emerald),
                    const SizedBox(width: 12),
                    _buildLegendItem('Moderate', AppTheme.yellow),
                    const SizedBox(width: 12),
                    _buildLegendItem('High', AppTheme.primaryOrange),
                    const SizedBox(width: 12),
                    _buildLegendItem('Critical', AppTheme.rose),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live Updates',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(29.9576, 78.1712),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kumbhsuraksha.app',
                ),
                CircleLayer(
                  circles: CROWD_ZONES.map((zone) {
                    return CircleMarker(
                      point: LatLng(zone.lat, zone.lng),
                      color: _getColorCode(zone.color).withOpacity(0.5),
                      borderColor: _getColorCode(zone.color),
                      borderStrokeWidth: 1,
                      useRadiusInMeter: true,
                      radius: (150 + zone.capacity * 5).toDouble(),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Zone Details List
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Zone Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppTheme.textLight,
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: CROWD_ZONES.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Color(0xFFF8FAFC),
                  ),
                  itemBuilder: (context, index) {
                    final zone = CROWD_ZONES[index];
                    return _buildZoneItem(context, zone);
                  },
                ),
              ],
            ),
          ),

          // Heatmap Guide
          Container(
            color: AppTheme.backgroundGray,
            padding: const EdgeInsets.all(16),
            child: Container(
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
                    'Heatmap Guide',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9A3412),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGuideItem('Green zones are safe with low crowd density', AppTheme.emerald),
                  _buildGuideItem('Yellow indicates moderate crowds - proceed with caution', AppTheme.yellow),
                  _buildGuideItem('Orange zones have high density - consider alternate routes', AppTheme.primaryOrange),
                  _buildGuideItem('Red areas are critical - avoid if possible', AppTheme.rose),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneItem(BuildContext context, CrowdZone zone) {
    Color statusColor = _getColorCode(zone.color);
    Color bgColor = statusColor.withOpacity(0.1);
    Color borderColor = statusColor.withOpacity(0.2);

    String description = zone.color == 'red'
        ? 'Very crowded, avoid if possible'
        : zone.color == 'orange'
            ? 'Main ghat area with moderate crowd'
            : zone.color == 'yellow'
                ? 'Busy but moving freely'
                : 'Peaceful area, safe for families';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: zone.color == 'red' || zone.color == 'orange'
                  ? [
                      BoxShadow(
                        color: statusColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      zone.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        zone.status.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.circle,
                      size: 8,
                      color: zone.color == 'red' ? AppTheme.rose.withOpacity(0.3) : AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${zone.capacity}% capacity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: Text(
              'View',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: AppTheme.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
