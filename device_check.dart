import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DeviceCheckScreen extends StatefulWidget {
  const DeviceCheckScreen({super.key});

  @override
  State<DeviceCheckScreen> createState() => _DeviceCheckScreenState();
}

class _DeviceCheckScreenState extends State<DeviceCheckScreen> {
  bool _eegConnected = false;
  Map<String, dynamic>? _eegDevice;
  bool _microphoneEnabled = false;
  bool _cameraEnabled = false;
  bool _checking = false;

  // Backend API URL
  
  static const String _apiBaseUrl = 'http://192.168.100.9:5000';

  static const Color _bgDark = Color(0xFF020617);
  static const Color _primaryBlue = Color(0xFF4A90E2);

  Map<String, dynamic>? participantData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    participantData = args?['participantData'] as Map<String, dynamic>?;
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final micStatus = await Permission.microphone.status;
      final camStatus = await Permission.camera.status;

      setState(() {
        _microphoneEnabled = micStatus.isGranted;
        _cameraEnabled = camStatus.isGranted;
      });
    } catch (_) {}
  }

  Future<void> _handleEegToggle(bool value) async {
    if (!value) {
      setState(() {
        _eegConnected = false;
        _eegDevice = null;
      });
      return;
    }

    setState(() => _checking = true);

    try {
      final uri = Uri.parse('$_apiBaseUrl/eeg/check');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          (data['connected'] == true)) {
        setState(() {
          _eegConnected = true;
          _eegDevice = data['device'] as Map<String, dynamic>?;
        });

        final dev = _eegDevice;
        final name = dev?['name']?.toString() ?? 'Unknown';
        final battery = dev?['battery']?.toString() ?? '?';

        _showAlert(
          'Success',
          'EEG Headset connected successfully!\n\nDevice: $name\nBattery: $battery%',
        );
      } else {
        setState(() {
          _eegConnected = false;
          _eegDevice = null;
        });

        _showAlert(
          'Error',
          data['message']?.toString() ??
              'EEG Headset is not connected. Please try again.',
        );
      }
    } catch (e) {
      setState(() {
        _eegConnected = false;
        _eegDevice = null;
      });

      _showAlert(
        'Connection Error',
        'Unable to check EEG device. Please check your connection.\n$e',
      );
    } finally {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }

  Future<void> _handleMicrophoneToggle(bool value) async {
    if (!value) {
      setState(() => _microphoneEnabled = false);
      return;
    }

    final result = await Permission.microphone.request();
    if (result.isGranted) {
      setState(() => _microphoneEnabled = true);
      _showAlert('Success', 'Microphone enabled successfully!');
    } else {
      setState(() => _microphoneEnabled = false);
      _showAlert('Error', 'Microphone is not enabled. Please try again.');
    }
  }

  Future<void> _handleCameraToggle(bool value) async {
    if (!value) {
      setState(() => _cameraEnabled = false);
      return;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      setState(() => _cameraEnabled = true);
      _showAlert('Success', 'Camera enabled successfully!');
    } else {
      setState(() => _cameraEnabled = false);
      _showAlert('Error', 'Camera is not enabled. Please try again.');
    }
  }

  void _handleProceed() {
    final missing = <String>[];

    if (!_eegConnected) missing.add('EEG Headset');
    if (!_microphoneEnabled) missing.add('Microphone');
    if (!_cameraEnabled) missing.add('Camera');

    if (missing.isNotEmpty) {
      final devicesList = missing.join(', ');
      final verb = missing.length > 1 ? 'are' : 'is';
      _showAlert(
        'Devices Not Connected',
        '$devicesList $verb not connected. Please connect and try again.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      'StartTest',
      arguments: {
        'participantData': participantData,
        'eegDevice': _eegDevice,
      },
    );
  }

  void _showAlert(String title, String msg) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allDevicesConnected =
        _eegConnected && _microphoneEnabled && _cameraEnabled;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: _primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '←',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Check Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (participantData != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Participant:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${participantData?['fullName']} (${participantData?['participantId']})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Device Connection Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Devices card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1120),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // EEG
                          _DeviceItem(
                            icon: '🧠',
                            name: 'EEG Headset',
                            statusText: _checking
                                ? 'Checking...'
                                : _eegConnected
                                    ? 'Connected${_eegDevice != null ? ' - ${_eegDevice!['name']}' : ''}'
                                    : 'Not Connected',
                            statusConnected: _eegConnected,
                            checking: _checking,
                            onToggle: _handleEegToggle,
                          ),
                          const Divider(color: Color(0xFF1F2937)),
                          // Mic
                          _DeviceItem(
                            icon: '🎤',
                            name: 'Microphone',
                            statusText:
                                _microphoneEnabled ? 'Enabled' : 'Disabled',
                            statusConnected: _microphoneEnabled,
                            onToggle: _handleMicrophoneToggle,
                          ),
                          const Divider(color: Color(0xFF1F2937)),
                          // Camera
                          _DeviceItem(
                            icon: '📷',
                            name: 'Camera',
                            statusText:
                                _cameraEnabled ? 'Enabled' : 'Disabled',
                            statusConnected: _cameraEnabled,
                            onToggle: _handleCameraToggle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'ℹ️',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All devices must be connected before proceeding to the test.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF856404),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Proceed
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            allDevicesConnected ? _handleProceed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: allDevicesConnected
                              ? _primaryBlue
                              : const Color(0xFFB0B0B0),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          shadowColor: _primaryBlue.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Proceed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  final String icon;
  final String name;
  final String statusText;
  final bool statusConnected;
  final bool checking;
  final Future<void> Function(bool) onToggle;

  const _DeviceItem({
    required this.icon,
    required this.name,
    required this.statusText,
    required this.statusConnected,
    required this.onToggle,
    this.checking = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        statusConnected ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: checking ? Colors.amber : statusColor,
                  ),
                ),
              ],
            ),
          ),
          checking
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4A90E2),
                  ),
                )
              : Switch(
                  value: statusConnected,
                  onChanged: (v) => onToggle(v),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF4A90E2),
                  inactiveTrackColor: const Color(0xFFD1D1D1),
                ),
        ],
      ),
    );
  }
}
