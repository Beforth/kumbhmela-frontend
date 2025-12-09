import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants.dart';
import '../theme.dart';
import '../api_client.dart';

class MissingScreen extends StatefulWidget {
  final String? userEmail;
  final String? accessToken;

  const MissingScreen({
    Key? key,
    this.userEmail,
    this.accessToken,
  }) : super(key: key);

  @override
  State<MissingScreen> createState() => _MissingScreenState();
}

class _MissingScreenState extends State<MissingScreen> {
  final _api = ApiClient();
  String _activeTab = 'lost';
  bool _showReportModal = false;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  final _searchController = TextEditingController();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _api.getLostFoundReports(
        type: _activeTab,
        status: 'open',
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      if (mounted) {
        setState(() {
          _reports = (result['results'] as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading reports: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleReportSubmit() async {
    print('DEBUG: Submitting report');
    print('DEBUG: widget.userEmail = ${widget.userEmail}');
    print('DEBUG: widget.accessToken = ${widget.accessToken != null ? "present" : "null"}');
    
    if (widget.userEmail == null || widget.userEmail!.isEmpty) {
      print('DEBUG: User email is null or empty');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to submit a report'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    print('DEBUG: User email is valid: ${widget.userEmail}');

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get current location if available
      double? latitude;
      double? longitude;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
            );
            latitude = position.latitude;
            longitude = position.longitude;
          }
        }
      } catch (e) {
        print('Error getting location: $e');
        // Continue without location
      }

      await _api.createLostFoundReport(
        reportType: _activeTab,
        userEmail: widget.userEmail!,
        personName: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
        latitude: latitude,
        longitude: longitude,
        accessToken: widget.accessToken,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showReportModal = false;
          _nameController.clear();
          _ageController.clear();
          _locationController.clear();
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload reports
        _loadReports();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter reports by active tab (already filtered by API, but double-check)
    final filteredReports = _reports.where((r) {
      final reportType = r['report_type'] as String? ?? '';
      return reportType == _activeTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.search, size: 18, color: AppTheme.primaryOrange),
                          const SizedBox(width: 8),
                          Text(
                            'LOST & FOUND',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lost & Found',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        'खोया-पाया',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 18, color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name, description, or location...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          onSubmitted: (_) => _loadReports(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.search, size: 18, color: AppTheme.primaryOrange),
                        onPressed: _loadReports,
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeTab = 'lost';
                            _showReportModal = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Report Lost',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _activeTab = 'found';
                            _showReportModal = true;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Report Found',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _activeTab = 'lost');
                          _loadReports();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _activeTab == 'lost'
                                    ? AppTheme.primaryOrange
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Lost (${_reports.where((r) => (r['report_type'] as String? ?? '') == 'lost').length})',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _activeTab == 'lost'
                                  ? AppTheme.primaryOrange
                                  : AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _activeTab = 'found');
                          _loadReports();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _activeTab == 'found'
                                    ? AppTheme.primaryOrange
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Found (${_reports.where((r) => (r['report_type'] as String? ?? '') == 'found').length})',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _activeTab == 'found'
                                  ? AppTheme.primaryOrange
                                  : AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  onPressed: _loadReports,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredReports.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.search, size: 48, color: AppTheme.textLight),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No ${_activeTab == 'lost' ? 'lost' : 'found'} reports yet',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadReports,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredReports.length,
                                  itemBuilder: (context, index) {
                                    return _buildReportCard(context, filteredReports[index]);
                                  },
                                ),
                              ),
              ),
            ],
          ),

          // Modal
          if (_showReportModal) _buildReportModal(context),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> item) {
    final reportType = item['report_type'] as String? ?? '';
    final isLost = reportType == 'lost';
    final statusColor = isLost ? AppTheme.rose : AppTheme.primaryOrange;
    final bgColor = isLost ? AppTheme.rose.withOpacity(0.1) : AppTheme.primaryOrange.withOpacity(0.1);
    
    final personName = item['person_name'] as String? ?? 'Unknown';
    final age = item['age'] as int?;
    final description = item['description'] as String? ?? '';
    final location = item['location'] as String? ?? '';
    final createdAt = item['created_at'] as String?;
    final userPhone = item['user_phone'] as String?;
    final userEmail = item['user_email'] as String?;
    
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'Unknown';
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.user, size: 20, color: statusColor),
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
                            personName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: statusColor.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (age != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Age: $age',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.primaryOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(LucideIcons.clock, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 6),
                Text(
                  formatDate(createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Show contact information
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contact Reporter'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userEmail != null) ...[
                          Row(
                            children: [
                              const Icon(LucideIcons.mail, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(userEmail!)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (userPhone != null) ...[
                          Row(
                            children: [
                              const Icon(LucideIcons.phone, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(userPhone!)),
                            ],
                          ),
                        ],
                        if (userEmail == null && userPhone == null)
                          const Text('No contact information available'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.9),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppTheme.primaryOrange.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Contact Reporter',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportModal(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report ${_activeTab == 'lost' ? 'Lost' : 'Found'} Person/Item',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      color: AppTheme.textLight,
                      onPressed: () {
                        setState(() {
                          _showReportModal = false;
                          _selectedImage = null;
                          _nameController.clear();
                          _ageController.clear();
                          _locationController.clear();
                          _descriptionController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help reunite someone with what they\'ve lost. Please provide accurate details.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      // Photo Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedImage != null
                              ? Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                                      label: const Text('Change Photo'),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppTheme.emerald.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.upload,
                                        color: AppTheme.emerald,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to upload photo',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                    Text(
                                      'JPG, PNG up to 5MB',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildFormField('Person Name / Item', _nameController, required: true),
                      const SizedBox(height: 16),
                      _buildFormField('Age (if person)', _ageController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildFormField('Description', _descriptionController, maxLines: 3, required: true),
                      const SizedBox(height: 16),
                      _buildFormField(
                        _activeTab == 'lost' ? 'Last Seen Location' : 'Found Location',
                        _locationController,
                        required: true,
                      ),

                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _showReportModal = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final isFound = _activeTab == 'found';
                                if (isFound) {
                                  return OutlinedButton(
                                    onPressed: _isSubmitting ? null : _handleReportSubmit,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryOrange,
                                      side: const BorderSide(color: AppTheme.primaryOrange),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                                            ),
                                          )
                                        : const Text('Submit Report'),
                                  );
                                } else {
                                  return ElevatedButton(
                                    onPressed: _isSubmitting ? null : _handleReportSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Submit Report'),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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
              borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

}
