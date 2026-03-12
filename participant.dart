import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParticipantDataScreen extends StatefulWidget {
  const ParticipantDataScreen({super.key});

  @override
  State<ParticipantDataScreen> createState() => _ParticipantDataScreenState();
}

class _ParticipantDataScreenState extends State<ParticipantDataScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pidController    = TextEditingController();
  final TextEditingController _nameController   = TextEditingController();
  final TextEditingController _ageController    = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController  = TextEditingController();

  bool _loading = false;

  // same as JS
  static const String _apiBaseUrl = 'http://192.168.100.9:5000';

  static const Color _bgDark = Color(0xFF020617);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _cardBorder = Color(0xFF60A5FA);

  @override
  void dispose() {
    _pidController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showAlert(String title, String msg, {VoidCallback? onOk}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final pid    = _pidController.text.trim();
    final name   = _nameController.text.trim();
    final age    = _ageController.text.trim();
    final gender = _genderController.text.trim();
    final email  = _emailController.text.trim();

    setState(() => _loading = true);

    try {
      // React Native code ka base URL: 'http://...:5000/participants/'
      // wahan call: `${API_BASE_URL}/participants` (thoda buggy)
      // Flutter me clean kar ke: 'http://ip:5000/participants/'
      final uri = Uri.parse('$_apiBaseUrl/participants/');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pid': pid,
          'name': name,
          'age': int.tryParse(age) ?? 0,
          'gender': gender,
          'email': email,
        }),
      );

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _showAlert(
          'Server Error',
          data['message']?.toString() ?? 'Participant not saved',
        );
        return;
      }

      _showAlert('Success', 'Participant saved successfully', onOk: () {
        Navigator.pushNamed(
          context,
          'DeviceCheck',
          arguments: {
            'participant': {
              'pid': pid,
              'name': name,
              'age': age,
              'gender': gender,
              'email': email,
            },
          },
        );
      });
    } catch (e) {
      _showAlert(
        'Connection Error',
        'Backend not reachable. Check WiFi and Flask server.\n$e',
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1120),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _cardBorder,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Participant Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),

                          // PID
                          _AppTextField(
                            controller: _pidController,
                            label: 'Participant ID (PID)',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please fill all fields'
                                    : null,
                          ),
                          const SizedBox(height: 15),

                          // Name
                          _AppTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please fill all fields'
                                    : null,
                          ),
                          const SizedBox(height: 15),

                          // Age
                          _AppTextField(
                            controller: _ageController,
                            label: 'Age',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please fill all fields'
                                    : null,
                          ),
                          const SizedBox(height: 15),

                          // Gender
                          _AppTextField(
                            controller: _genderController,
                            label: 'Gender',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please fill all fields'
                                    : null,
                          ),
                          const SizedBox(height: 15),

                          // Email
                          _AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please fill all fields'
                                    : null,
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _loading
                                    ? const Color(0xFF4B5563)
                                    : _primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Next',
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: const Color(0xFF020617),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF60A5FA),
            width: 1.7,
          ),
        ),
      ),
    );
  }
}
