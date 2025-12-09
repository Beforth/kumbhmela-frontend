import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../theme.dart';
import '../models/amenity.dart';
import '../api_client.dart';

const _distance = Distance();

class MapDashboardScreen extends StatefulWidget {
  const MapDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MapDashboardScreen> createState() => _MapDashboardScreenState();
}

class _MapDashboardScreenState extends State<MapDashboardScreen> {
  bool _loading = false;
  int _selectedTab = 0; // 0 = Zone Details, 1 = Amenities
  String? _selectedCategory;
  List<Amenity> _filteredAmenities = [];
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _allAmenities = [];
  List<Map<String, dynamic>> _categories = [];
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _userLocation = const LatLng(29.9457, 78.1642); // Default user location
    _getUserLocation();
    _loadZones();
    _loadAmenities();
  }

  Future<void> _loadZones() async {
    setState(() => _loading = true);
    try {
      final zones = await _api.getZones();
      if (mounted) {
        setState(() {
          _zones = zones;
        });
      }
    } catch (e) {
      print('Error loading zones: $e');
      // Fallback to mock data on error
      if (mounted) {
        setState(() {
          _zones = CROWD_ZONES.map((z) => {
            'id': z.id,
            'name': z.name,
            'status': z.status,
            'color': z.color,
            'color_code': z.color,
            'capacity': z.capacity,
            'lat': z.lat,
            'lng': z.lng,
          }).toList();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadAmenities() async {
    try {
      final amenities = await _api.getAmenities();
      final categories = await _api.getAmenityCategories();
      setState(() {
        _allAmenities = amenities;
        _categories = categories;
        _filteredAmenities = _convertToAmenityList(amenities);
      });
    } catch (e) {
      // Fallback to mock data on error
      setState(() {
        _allAmenities = ALL_AMENITIES.map((a) => {
          'id': a.id,
          'name': a.name,
          'category': a.category,
          'lat': a.lat,
          'lng': a.lng,
          'description': a.description,
        }).toList();
        _filteredAmenities = ALL_AMENITIES;
        _categories = AmenityCategory.values.map((cat) => {
          'value': cat.name,
          'label': cat.title,
        }).toList();
      });
    }
  }

  // Helper function to safely parse numbers from API (handles both num and String)
  double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  List<Amenity> _convertToAmenityList(List<Map<String, dynamic>> data) {
    return data.map((item) => Amenity(
      id: _parseInt(item['id']),
      name: item['name']?.toString() ?? '',
      category: item['category']?.toString() ?? '',
      lat: _parseDouble(item['lat'] ?? item['latitude']),
      lng: _parseDouble(item['lng'] ?? item['longitude']),
      description: item['description']?.toString(),
    )).toList();
  }

  Future<void> _getUserLocation() async {
    try {
      // Check if geolocator is available
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled, use default
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions denied, use default
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions permanently denied, use default
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        // Center map on user location
        _mapController.move(_userLocation!, 15.0);
      }
    } catch (e) {
      // Error getting location, use default location (Haridwar center)
      // This handles MissingPluginException and other errors gracefully
      print('Error getting location: $e');
      if (mounted && _userLocation == null) {
        setState(() {
          _userLocation = const LatLng(29.9457, 78.1642); // Default to Haridwar center
        });
      }
    }
  }

  void _centerOnUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      _getUserLocation();
    }
  }

  void _refreshData() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _selectCategory(String? category) async {
    setState(() {
      _selectedCategory = category;
      _loading = true;
    });
    
    try {
      final amenities = await _api.getAmenities(category: category);
      setState(() {
        _filteredAmenities = _convertToAmenityList(amenities);
      });
    } catch (e) {
      // Fallback to local filtering
      setState(() {
        if (category == null) {
          _filteredAmenities = _convertToAmenityList(_allAmenities);
        } else {
          _filteredAmenities = _convertToAmenityList(
            _allAmenities.where((a) => a['category'] == category).toList()
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _navigateToAmenity(Amenity amenity) {
    _mapController.move(LatLng(amenity.lat, amenity.lng), 16.0);
    _showAmenityDialog(amenity);
  }

  void _showAmenityDialog(Amenity amenity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Amenity info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(amenity.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(amenity.category),
                    color: _getCategoryColor(amenity.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amenity.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (amenity.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          amenity.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Get Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openGoogleMapsDirections(amenity);
                },
                icon: const Icon(LucideIcons.navigation, size: 20),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMapsDirections(Amenity amenity) async {
    try {
      final destination = '${amenity.lat},${amenity.lng}';
      
      // Try multiple URL formats
      List<Uri> urlsToTry = [];
      
      // 1. Try Google Maps app with navigation (if installed)
      urlsToTry.add(Uri.parse('google.navigation:q=$destination&mode=w'));
      
      // 2. Try Google Maps app with directions
      String origin = '';
      if (_userLocation != null) {
        origin = '${_userLocation!.latitude},${_userLocation!.longitude}';
        urlsToTry.add(Uri.parse('https://www.google.com/maps/dir/$origin/$destination'));
      } else {
        origin = '29.9457,78.1642'; // Fallback
        urlsToTry.add(Uri.parse('https://www.google.com/maps/dir/$origin/$destination'));
      }
      
      // 3. Try Google Maps web with directions API
      urlsToTry.add(Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=walking',
      ));
      
      // 4. Try simple Google Maps location
      urlsToTry.add(Uri.parse('https://www.google.com/maps/search/?api=1&query=$destination'));
      
      // Try each URL until one works
      bool launched = false;
      for (var url in urlsToTry) {
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          // Try next URL
          continue;
        }
      }
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps. Please install Google Maps app or use a browser.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening directions: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return LucideIcons.heart; // Using heart icon for medical
      case 'food':
        return LucideIcons.utensils;
      case 'restroom':
        return LucideIcons.bath;
      case 'parking':
        return LucideIcons.car;
      case 'accommodation':
        return LucideIcons.bed;
      case 'transport':
        return LucideIcons.bus;
      case 'worship':
        return LucideIcons.church;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'other':
        return LucideIcons.mapPin;
      default:
        return LucideIcons.mapPin;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'medical':
        return AppTheme.rose;
      case 'food':
        return AppTheme.primaryOrange;
      case 'restroom':
        return AppTheme.emerald;
      case 'parking':
        return AppTheme.textDark;
      case 'accommodation':
        return AppTheme.primaryOrange;
      case 'transport':
        return AppTheme.textMedium;
      case 'worship':
        return AppTheme.emerald;
      case 'shopping':
        return AppTheme.primaryOrange;
      case 'other':
        return AppTheme.textMedium;
      default:
        return AppTheme.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(29.9576, 78.1712),
                      initialZoom: 14.0,
                      onTap: (tapPosition, point) {
                        // Check if tapped on an amenity
                        if (_selectedTab == 1) {
                          for (var amenity in _filteredAmenities) {
                            final distanceInMeters = _distance.as(
                              LengthUnit.Meter,
                              point,
                              LatLng(amenity.lat, amenity.lng),
                            );
                            if (distanceInMeters < 100) {
                              _navigateToAmenity(amenity);
                              break;
                            }
                          }
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.kumbhsuraksha.app',
                      ),
                      // User Location Marker - Always visible
                      if (_userLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _userLocation!,
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing circle
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Main marker
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      LucideIcons.navigation,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  // Crowd Zones - only show when Zone Details tab is selected
                  if (_selectedTab == 0) ...[
                    // Polygon layers for zones with polygons
                    PolygonLayer(
                      polygons: _zones.where((zone) {
                        final polygon = zone['polygon'];
                        return polygon != null && polygon is List && (polygon as List).isNotEmpty;
                      }).map((zone) {
                        final color = zone['color_code']?.toString() ?? zone['color']?.toString() ?? 'green';
                        final polygon = zone['polygon'] as List?;
                        if (polygon == null || polygon.isEmpty) return null;
                        
                        // Convert polygon coordinates to LatLng list
                        final points = polygon.map((coord) {
                          if (coord is List && coord.length >= 2) {
                            return LatLng(
                              _parseDouble(coord[0]),
                              _parseDouble(coord[1]),
                            );
                          }
                          return null;
                        }).whereType<LatLng>().toList();
                        
                        if (points.isEmpty) return null;
                        
                        return Polygon(
                          points: points,
                          color: _getColorCode(color).withOpacity(0.3),
                          borderColor: _getColorCode(color),
                          borderStrokeWidth: 2,
                          isFilled: true,
                        );
                      }).whereType<Polygon>().toList(),
                    ),
                    // Circle markers ONLY for zones WITHOUT polygons
                    CircleLayer(
                      circles: _zones.where((zone) {
                        final polygon = zone['polygon'];
                        final hasPolygon = polygon != null && polygon is List && (polygon as List).isNotEmpty;
                        if (hasPolygon) return false; // Skip zones with polygons
                        
                        final lat = _parseDouble(zone['lat'] ?? zone['latitude'], -999);
                        final lng = _parseDouble(zone['lng'] ?? zone['longitude'], -999);
                        return lat != -999 && lng != -999;
                      }).map((zone) {
                        final color = zone['color_code']?.toString() ?? zone['color']?.toString() ?? 'green';
                        final capacity = _parseInt(zone['capacity']);
                        final lat = _parseDouble(zone['lat'] ?? zone['latitude']);
                        final lng = _parseDouble(zone['lng'] ?? zone['longitude']);
                        
                        // Show larger circle based on capacity for zones without polygons
                        return CircleMarker(
                          point: LatLng(lat, lng),
                          color: _getColorCode(color).withOpacity(0.4),
                          borderColor: _getColorCode(color),
                          borderStrokeWidth: 2,
                          useRadiusInMeter: true,
                          radius: (150 + capacity * 5).toDouble(),
                        );
                      }).toList(),
                    ),
                  ],
                  // Amenities Markers - only show when Amenities tab is selected
                  if (_selectedTab == 1)
                    MarkerLayer(
                      markers: _filteredAmenities.map((amenity) {
                        return Marker(
                          point: LatLng(amenity.lat, amenity.lng),
                          width: 32,
                          height: 32,
                          child: GestureDetector(
                            onTap: () => _navigateToAmenity(amenity),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getCategoryColor(amenity.category),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(amenity.category).withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCategoryIcon(amenity.category),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
                  // Center on user location button
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: _centerOnUserLocation,
                      child: Icon(
                        LucideIcons.navigation,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Zone Details', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('Amenities', 1),
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              height: 300,
              color: Colors.white,
              child: _selectedTab == 0 ? _buildZoneDetails() : _buildAmenities(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryOrange : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildZoneDetails() {
    return Column(
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
        Expanded(
          child: _zones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 48,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No zones available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textMedium,
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _zones.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Color(0xFFF8FAFC),
                  ),
                  itemBuilder: (context, index) {
                    final zone = _zones[index];
                    return _buildZoneItem(context, zone);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
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
                'Amenities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_selectedCategory != null)
                TextButton(
                  onPressed: () => _selectCategory(null),
                  child: const Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip('All', null),
              const SizedBox(width: 8),
              ..._categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  cat['label'] as String? ?? cat['value'] as String? ?? '',
                  cat['value'] as String?,
                ),
              )),
            ],
          ),
        ),
        const Divider(height: 1),
        // Amenities List
        Expanded(
          child: _filteredAmenities.isEmpty
              ? Center(
                  child: Text(
                    'No amenities found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMedium,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _filteredAmenities.length,
                  itemBuilder: (context, index) {
                    final amenity = _filteredAmenities[index];
                    return _buildAmenityItem(context, amenity);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _selectCategory(selected ? category : null);
      },
      selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryOrange : AppTheme.textMedium,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAmenityItem(BuildContext context, Amenity amenity) {
    final categoryColor = _getCategoryColor(amenity.category);
    return InkWell(
      onTap: () => _navigateToAmenity(amenity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF8FAFC)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(amenity.category),
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amenity.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (amenity.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      amenity.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      amenity.category.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textLight,
              size: 20,
            ),
          ],
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

  Widget _buildZoneItem(BuildContext context, Map<String, dynamic> zone) {
    final color = zone['color_code']?.toString() ?? zone['color']?.toString() ?? 'green';
    final status = zone['status']?.toString() ?? 'normal';
    final name = zone['name']?.toString() ?? 'Unknown Zone';
    final capacity = _parseInt(zone['capacity']);
    final description = zone['description']?.toString();
    final hasPolygon = zone['polygon'] != null && 
                      zone['polygon'] is List && 
                      (zone['polygon'] as List).isNotEmpty;
    
    Color statusColor = _getColorCode(color);
    Color bgColor = statusColor.withOpacity(0.1);
    Color borderColor = statusColor.withOpacity(0.2);

    String zoneDescription = description ?? (color == 'red'
        ? 'Very crowded, avoid if possible'
        : color == 'orange'
            ? 'Main ghat area with moderate crowd'
            : color == 'yellow'
                ? 'Busy but moving freely'
                : 'Peaceful area, safe for families');

    return InkWell(
      onTap: () {
        // Center map on zone
        final lat = _parseDouble(zone['lat'] ?? zone['latitude']);
        final lng = _parseDouble(zone['lng'] ?? zone['longitude']);
        if (lat != 0.0 && lng != 0.0) {
          _mapController.move(LatLng(lat, lng), 15.0);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: statusColor,
                shape: hasPolygon ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: hasPolygon ? BorderRadius.circular(2) : null,
                boxShadow: color == 'red' || color == 'orange'
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
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (hasPolygon)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            LucideIcons.shapes,
                            size: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
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
                    zoneDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.circle,
                        size: 8,
                        color: color == 'red' ? AppTheme.rose.withOpacity(0.3) : AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$capacity% capacity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasPolygon) ...[
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.map,
                          size: 10,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Polygon',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
