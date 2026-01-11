import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import '../theme.dart';
import '../api_client.dart';

class FamilyScreen extends StatefulWidget {
  final String? userEmail;
  final String? accessToken;

  const FamilyScreen({
    Key? key,
    this.userEmail,
    this.accessToken,
  }) : super(key: key);

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _api = ApiClient();
  final _mapController = MapController();
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isLoading = true;
  String? _error;
  bool _isSharingLocation = false;
  Timer? _locationUpdateTimer;
  Timer? _familyMembersRefreshTimer;
  Position? _currentUserPosition;
  Map<String, dynamic>? _selectedMember;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentUserPosition = position;
        });
        
        // Center map on current user location
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _familyMembersRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    if (widget.userEmail == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please login to view family members';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final members = await _api.getFamilyMembers(
        userEmail: widget.userEmail!,
      );
      setState(() {
        _familyMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading family members: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getAvatarColor(int index) {
    final colors = [
      AppTheme.primaryOrange,
      AppTheme.emerald,
      AppTheme.yellow,
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadFamilyMembers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  // Location Sharing Toggle Button
                  InkWell(
                    onTap: _toggleLocationSharing,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isSharingLocation 
                            ? AppTheme.emerald.withOpacity(0.1)
                            : AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSharingLocation ? LucideIcons.mapPin : LucideIcons.mapPinOff,
                            size: 14,
                            color: _isSharingLocation ? AppTheme.emerald : AppTheme.primaryOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSharingLocation ? 'Stop Sharing' : 'Start Sharing',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isSharingLocation ? AppTheme.emerald : AppTheme.primaryOrange,
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

          // Map Preview
          SizedBox(
            height: 200,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentUserPosition != null
                    ? LatLng(_currentUserPosition!.latitude, _currentUserPosition!.longitude)
                    : const LatLng(29.9500, 78.1600),
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onTap: (tapPosition, point) {
                  // Clear selection when tapping on map
                  setState(() {
                    _selectedMember = null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kumbhsuraksha.app',
                ),
                // Current user location marker
                if (_currentUserPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_currentUserPosition!.latitude, _currentUserPosition!.longitude),
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.emerald,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.emerald.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.mapPin,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                // Family members markers
                MarkerLayer(
                  markers: _familyMembers
                      .where((member) {
                        final lat = _parseDouble(member['lat'] ?? member['latitude']);
                        final lng = _parseDouble(member['lng'] ?? member['longitude']);
                        return lat != 0.0 && lng != 0.0;
                      })
                      .map((member) {
                        final lat = _parseDouble(member['lat'] ?? member['latitude']);
                        final lng = _parseDouble(member['lng'] ?? member['longitude']);
                        final index = _familyMembers.indexOf(member);
                        final isSelected = _selectedMember != null && 
                                         _selectedMember!['id'] == member['id'];
                        return Marker(
                          point: LatLng(lat, lng),
                          width: isSelected ? 50 : 40,
                          height: isSelected ? 50 : 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMember = member;
                              });
                              // Center map on selected member
                              _mapController.move(LatLng(lat, lng), 15.0);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryOrange : _getAvatarColor(index),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSelected ? AppTheme.primaryOrange : _getAvatarColor(index)).withOpacity(0.5),
                                    blurRadius: isSelected ? 12 : 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.user,
                                color: Colors.white,
                                size: 16,
                              ),
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
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadFamilyMembers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_familyMembers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(LucideIcons.users, size: 48, color: AppTheme.textLight),
                        const SizedBox(height: 16),
                        Text(
                          'No family members yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Invite family members to start tracking',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ..._familyMembers.map((member) => _buildFamilyMemberCard(context, member)),
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
      ),
    );
  }

  Widget _buildFamilyMemberCard(BuildContext context, Map<String, dynamic> member) {
    final name = member['name'] as String? ?? 'Unknown';
    final relationship = member['relationship_display'] as String? ?? member['relationship'] as String? ?? '';
    final phone = member['phone'] as String? ?? '';
    final lat = _parseDouble(member['lat'] ?? member['latitude']);
    final lng = _parseDouble(member['lng'] ?? member['longitude']);
    final hasLocation = lat != 0.0 && lng != 0.0;
    final lastUpdate = member['last_location_update'] as String?;
    
    final index = _familyMembers.indexOf(member);
    final avatarColor = _getAvatarColor(index);

    String initials = name
        .split(' ')
        .where((n) => n.isNotEmpty)
        .take(2)
        .map((n) => n[0].toUpperCase())
        .join('');

    if (initials.isEmpty) {
      initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'Never';
      try {
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inMinutes < 1) return 'Just now';
        if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
        if (difference.inHours < 24) return '${difference.inHours}h ago';
        if (difference.inDays < 7) return '${difference.inDays}d ago';
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return 'Unknown';
      }
    }

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
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (relationship.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasLocation ? AppTheme.emerald : AppTheme.textLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          relationship,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (hasLocation) ...[
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'Location available',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPinOff, size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'No location',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (lastUpdate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 10, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'Updated: ${formatDate(lastUpdate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.phone, size: 10, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Track Buttons
          if (hasLocation)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    // Show member on map
                    setState(() {
                      _selectedMember = member;
                    });
                    // Center map on member location
                    _mapController.move(LatLng(lat, lng), 15.0);
                    // Scroll to map
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.navigation, size: 12, color: AppTheme.textMedium),
                        const SizedBox(width: 4),
                        Text(
                          'Show on Map',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _openGoogleMaps(lat, lng),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryOrange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: AppTheme.primaryOrange),
                        const SizedBox(width: 4),
                        Text(
                          'Show on GMap',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final destination = '$latitude,$longitude';
    final urlsToTry = <Uri>[];

    // Try Google Maps app with location
    urlsToTry.add(Uri.parse('https://www.google.com/maps/search/?api=1&query=$destination'));
    
    // Try Google Maps app scheme (if installed)
    urlsToTry.add(Uri.parse('comgooglemaps://?q=$destination'));
    
    // Try Google Maps web
    urlsToTry.add(Uri.parse('https://maps.google.com/?q=$destination'));

    bool launched = false;
    for (final url in urlsToTry) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google Maps. Please install Google Maps app or use a browser.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleLocationSharing() async {
    if (widget.userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to share location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSharingLocation = !_isSharingLocation;
    });

    if (_isSharingLocation) {
      // Start sharing location
      await _requestLocationPermission();
      await _updateCurrentUserLocation();
      _startLocationUpdates();
      _startFamilyMembersRefresh();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location sharing started'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Stop sharing location
      _stopLocationUpdates();
      _stopFamilyMembersRefresh();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location sharing stopped'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSharingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSharingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied. Please enable them in settings.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSharingLocation = false;
      });
      return;
    }
  }

  Future<void> _updateCurrentUserLocation() async {
    if (widget.userEmail == null || widget.accessToken == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update state with current position for map display
      if (mounted) {
        setState(() {
          _currentUserPosition = position;
        });
        
        // Center map on current user location if first time
        if (_currentUserPosition != null) {
          _mapController.move(
            LatLng(_currentUserPosition!.latitude, _currentUserPosition!.longitude),
            15.0,
          );
        }
      }

      // Use the new API endpoint to update location for all family member records
      await _api.updateUserLocation(
        userEmail: widget.userEmail!,
        latitude: position.latitude,
        longitude: position.longitude,
        accessToken: widget.accessToken,
      );
      
      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error getting/updating location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isSharingLocation && mounted) {
        _updateCurrentUserLocation();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  void _startFamilyMembersRefresh() {
    _familyMembersRefreshTimer?.cancel();
    _familyMembersRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isSharingLocation && mounted) {
        _loadFamilyMembers();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopFamilyMembersRefresh() {
    _familyMembersRefreshTimer?.cancel();
    _familyMembersRefreshTimer = null;
  }

  void _showInviteDialog() {
    if (widget.userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to invite family members'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emailController = TextEditingController();
    String? selectedRelationship;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the email of the person you want to invite. They must have an account in the app.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'child', child: Text('Child')),
                  DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                  DropdownMenuItem(value: 'grandparent', child: Text('Grandparent')),
                  DropdownMenuItem(value: 'grandchild', child: Text('Grandchild')),
                  DropdownMenuItem(value: 'uncle', child: Text('Uncle')),
                  DropdownMenuItem(value: 'aunt', child: Text('Aunt')),
                  DropdownMenuItem(value: 'cousin', child: Text('Cousin')),
                  DropdownMenuItem(value: 'friend', child: Text('Friend')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  selectedRelationship = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an email address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final result = await _api.createFamilyInvitation(
                  inviterEmail: widget.userEmail!,
                  inviteeEmail: emailController.text.trim(),
                  relationship: selectedRelationship,
                  accessToken: widget.accessToken,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  final invitationLink = result['invitation_link'] as String?;
                  
                  if (invitationLink != null) {
                    // Directly open share sheet
                    try {
                      await Share.share(
                        'Join my family on Kumbh Suraksha!\n\n$invitationLink\n\nClick the link to accept the invitation.',
                        subject: 'Family Invitation - Kumbh Suraksha',
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sharing link: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                    // Refresh family members list
                    _loadFamilyMembers();
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
              }
            },
            child: const Text('Generate Link'),
          ),
        ],
      ),
    );
  }

  void _showInvitationLinkDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.link, color: AppTheme.primaryOrange),
            SizedBox(width: 8),
            Text('Invitation Link Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this link with the person you want to invite:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'They will need to login with their email and password to accept the invitation.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied to clipboard!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await Share.share(
                  'Join my family on Kumbh Suraksha!\n\n$link\n\nClick the link to accept the invitation.',
                  subject: 'Family Invitation - Kumbh Suraksha',
                );
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sharing link: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(LucideIcons.share2, size: 16),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
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
            'Enter the email of the person you want to invite. They must have an account in the app. A secure invitation link will be generated that they can use to join your family.',
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
              onPressed: _showInviteDialog,
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
                    'Share Invite Link',
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
