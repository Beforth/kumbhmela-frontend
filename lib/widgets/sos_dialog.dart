import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import '../api_client.dart';
import '../theme.dart';

enum SosType {
  medical('Medical Emergency', 'I need immediate medical assistance', LucideIcons.heart, AppTheme.rose),
  lost('Lost Person', 'I am lost and need help finding my group', LucideIcons.mapPin, AppTheme.primaryOrange),
  danger('In Danger', 'I am in immediate danger and need help', LucideIcons.alertTriangle, AppTheme.rose),
  crowd('Crowd Emergency', 'Crowd situation getting out of control', LucideIcons.users, AppTheme.textDark),
  other('Other Emergency', 'I need urgent assistance', LucideIcons.helpCircle, AppTheme.emerald);

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const SosType(this.title, this.description, this.icon, this.color);
}

class SosScreen extends StatefulWidget {
  final Function(SosType, int?) onSosActivated;
  final String? userEmail;
  final String? userName;
  final String? accessToken;

  const SosScreen({
    Key? key,
    required this.onSosActivated,
    this.userEmail,
    this.userName,
    this.accessToken,
  }) : super(key: key);

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  SosType? _selectedType;
  bool _isSending = false;
  bool _hasSent = false; // Track if SOS has already been sent
  final _api = ApiClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedType?.color ?? AppTheme.rose,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Emergency SOS',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the type of emergency',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // SOS Type Options
                ...SosType.values.map((type) => _buildSosOption(context, type)),
                
                const SizedBox(height: 32),

                // Action Buttons
                if (_selectedType != null) ...[
                  // Send SOS Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSending || _hasSent) ? null : () => _sendSos(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _selectedType!.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'SEND SOS REQUEST',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  void _sendSos() async {
    if (_selectedType == null || _isSending || _hasSent) {
      print('SOS send prevented: selectedType=$_selectedType, isSending=$_isSending, hasSent=$_hasSent');
      return; // Prevent double submission
    }

    setState(() {
      _isSending = true;
      _hasSent = true; // Mark as sent immediately to prevent duplicate calls
    });

    try {
      // Get user's current location
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location services are disabled. Please enable location services.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSending = false);
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location permissions are denied. Please enable location permissions.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isSending = false);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are permanently denied. Please enable in settings.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSending = false);
          return;
        }

        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('Error getting location: $e');
        position = null;
      }

      // Map SosType enum to backend string
      String sosTypeString;
      switch (_selectedType!) {
        case SosType.medical:
          sosTypeString = 'medical';
          break;
        case SosType.lost:
          sosTypeString = 'lost';
          break;
        case SosType.danger:
          sosTypeString = 'danger';
          break;
        case SosType.crowd:
          sosTypeString = 'crowd';
          break;
        case SosType.other:
          sosTypeString = 'other';
          break;
      }

      // Send SOS request to backend
      if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
        double lat, lng;
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          print('Sending SOS with GPS location: $lat, $lng');
        } else {
          lat = 29.9457; // Default location
          lng = 78.1642;
          print('Sending SOS with default location: $lat, $lng');
        }

        final result = await _api.createSosRequest(
          userEmail: widget.userEmail!,
          userName: widget.userName,
          sosType: sosTypeString,
          latitude: lat,
          longitude: lng,
          description: _selectedType!.description,
          accessToken: widget.accessToken,
        );
        print('SOS request sent successfully: $result');
        
        // Get the request ID and call callback to navigate to alert screen
        final sosRequestId = result['id'] as int?;
        if (mounted) {
          widget.onSosActivated(_selectedType!, sosRequestId);
        }
      } else {
        print('Cannot send SOS: User email is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to send SOS requests'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() => _isSending = false);
        }
      }
    } catch (e) {
      print('Error sending SOS request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isSending = false);
      }
    }
  }

  Widget _buildSosOption(BuildContext context, SosType type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = isSelected ? null : type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  LucideIcons.checkCircle,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SosAlertScreen extends StatefulWidget {
  final SosType sosType;
  final int? sosRequestId; // ID of the SOS request from backend
  final String? accessToken; // For polling status

  const SosAlertScreen({
    Key? key, 
    required this.sosType,
    this.sosRequestId,
    this.accessToken,
  }) : super(key: key);

  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  bool _isActive = true;
  String _status = 'open';
  Timer? _statusPollTimer;

  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _startAlert();
    
    // Start polling for status if we have a request ID
    if (widget.sosRequestId != null) {
      _startStatusPolling();
    }
  }

  void _startStatusPolling() {
    // Poll every 3 seconds to check if status changed to "in_progress"
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _status != 'open') {
        timer.cancel();
        return;
      }

      try {
        final sosRequest = await _api.getSosRequest(widget.sosRequestId!);
        final newStatus = sosRequest['status'] as String?;
        
        if (newStatus != null && newStatus != _status) {
          if (mounted) {
            setState(() {
              _status = newStatus;
            });
            
            if (newStatus == 'in_progress') {
              // Status changed to in_progress, stop alert and show message
              _stopAlert();
              timer.cancel();
              
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS request has been acknowledged. Help is on the way!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
                
                // Auto-close after showing message
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            }
          }
        }
      } catch (e) {
        print('Error polling SOS status: $e');
        // Continue polling even if there's an error
      }
    });
  }

  void _startAlert() {
    // Vibrate on start
    HapticFeedback.heavyImpact();
    
    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    // Continuous vibration pattern
    _vibratePattern();
  }

  void _vibratePattern() async {
    while (_isActive && mounted) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _stopAlert() {
    setState(() {
      _isActive = false;
    });
    _pulseController.stop();
    _shakeController.stop();
    _statusPollTimer?.cancel();
  }

  void _forceClose() {
    _stopAlert();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _cancelSos() async {
    if (widget.sosRequestId == null) {
      // No request ID, just close
      _forceClose();
      return;
    }

    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel SOS Request?'),
        content: const Text('Are you sure you want to cancel this SOS request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    // Update status to cancelled
    try {
      await _api.updateSosRequest(
        widget.sosRequestId!,
        status: 'cancelled',
        accessToken: widget.accessToken,
      );
      
      if (mounted) {
        _stopAlert();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS request has been cancelled'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error cancelling SOS request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel SOS: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _statusPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _status != 'open', // Prevent back button if status is still "open"
      child: Scaffold(
        backgroundColor: widget.sosType.color,
        body: SafeArea(
          child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    widget.sosType.color,
                    widget.sosType.color.withOpacity(0.7 + (_pulseController.value * 0.3)),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SOS Icon with pulse
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (_pulseController.value * 0.2),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.sosType.icon,
                              size: 60,
                              color: widget.sosType.color,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'SOS ACTIVATED',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.sosType.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.sosType.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _status == 'open' 
                                ? 'Alerting authorities...' 
                                : 'Request acknowledged!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (_status == 'open') ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Waiting for response...\nThis alert will remain active until help arrives.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    if (_status == 'open') ...[
                      // Cancel Button
                      SizedBox(
                        width: 200,
                        child: OutlinedButton(
                          onPressed: _cancelSos,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CANCEL SOS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _status == 'open' ? null : _forceClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: widget.sosType.color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          disabledBackgroundColor: Colors.white.withOpacity(0.5),
                        ),
                        child: Text(
                          _status == 'open' 
                              ? 'WAITING FOR HELP...' 
                              : 'CLOSE',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}

