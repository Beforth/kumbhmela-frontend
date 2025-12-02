import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants.dart';
import '../theme.dart';

class MissingScreen extends StatefulWidget {
  const MissingScreen({Key? key}) : super(key: key);

  @override
  State<MissingScreen> createState() => _MissingScreenState();
}

class _MissingScreenState extends State<MissingScreen> {
  String _activeTab = 'lost';
  bool _showReportModal = false;
  List<MissingPersonReport> _reports = List.from(MOCK_MISSING);
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _handleReportSubmit() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 1), () {
      final newReport = MissingPersonReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        lastSeenLocation: _locationController.text,
        lastSeenTime: 'Just now',
        description: _descriptionController.text,
        status: _activeTab == 'lost' ? ReportStatus.missing : ReportStatus.found,
        imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=${_nameController.text}',
      );

      setState(() {
        _reports.insert(0, newReport);
        _isSubmitting = false;
        _showReportModal = false;
        _nameController.clear();
        _ageController.clear();
        _locationController.clear();
        _descriptionController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _reports.where((r) {
      return _activeTab == 'lost'
          ? r.status == ReportStatus.missing
          : r.status == ReportStatus.found;
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
                        ),
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
                        onTap: () => setState(() => _activeTab = 'lost'),
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
                            'Lost (${_reports.where((r) => r.status == ReportStatus.missing).length})',
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
                        onTap: () => setState(() => _activeTab = 'found'),
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
                            'Found (${_reports.where((r) => r.status == ReportStatus.found).length})',
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    return _buildReportCard(context, filteredReports[index]);
                  },
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

  Widget _buildReportCard(BuildContext context, MissingPersonReport item) {
    final isLost = item.status == ReportStatus.missing;
    final statusColor = isLost ? AppTheme.rose : AppTheme.primaryOrange;
    final bgColor = isLost ? AppTheme.rose.withOpacity(0.1) : AppTheme.primaryOrange.withOpacity(0.1);

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
                            item.name,
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
                    const SizedBox(height: 2),
                    Text(
                      'Age: ${item.age}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
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
                    item.lastSeenLocation,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(LucideIcons.clock, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 6),
                Text(
                  item.lastSeenTime,
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
              onPressed: () {},
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
                      onPressed: () => setState(() => _showReportModal = false),
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

                      // Photo Upload Placeholder
                      GestureDetector(
                        onTap: () {},
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
                          child: Column(
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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
