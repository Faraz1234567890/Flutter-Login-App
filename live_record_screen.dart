import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firstapp/analyzing_screen.dart';
import 'package:flutter/material.dart';

class LiveRecordingScreen extends StatefulWidget {
  final String question;
  final int questionNumber;
  final int totalQuestions;

  const LiveRecordingScreen({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  State<LiveRecordingScreen> createState() => _LiveRecordingScreenState();
}

class _LiveRecordingScreenState extends State<LiveRecordingScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = true;
  int _recordingTime = 0;

  late List<double> _alpha;
  
  late List<double> _beta;
  late List<double> _gamma;

  late List<double> _audioData;

  Timer? _timer;
  Timer? _eegTimer;
  Timer? _audioTimer;

  late AnimationController _recController;
  late Animation<double> _recScale;

  static const Color _bgColor = Color(0xFF020617);
  static const Color _cardColor = Color(0xFF0B1120);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _borderBlue = Color(0xFF1F2937);

  // CAMERA STATE
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();

    _alpha = List.generate(30, (_) => 30 + Random().nextDouble() * 20);
    _beta = List.generate(30, (_) => 20 + Random().nextDouble() * 15);
    _gamma = List.generate(30, (_) => 15 + Random().nextDouble() * 15);

    _audioData = List.generate(15, (_) => Random().nextDouble() * 60 + 10);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordingTime++;
      });
    });

    _eegTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _alpha = [..._alpha.sublist(1), 30 + Random().nextDouble() * 20];
        _beta = [..._beta.sublist(1), 20 + Random().nextDouble() * 15];
        _gamma = [..._gamma.sublist(1), 15 + Random().nextDouble() * 15];
      });
    });

    _audioTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _audioData = [
          ..._audioData.sublist(1),
          Random().nextDouble() * 60 + 10,
        ];
      });
    });

    _recController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _recScale = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _recController, curve: Curves.easeInOut),
    );

    _recController.repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    // permissions
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      // agar user ne deny kiya to sirf text show kar do
      setState(() {
        _isCameraInitialized = false;
      });
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _isCameraInitialized = false;
      });
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _eegTimer?.cancel();
    _audioTimer?.cancel();
    _recController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleFinishAnswer() async {
    setState(() {
      _isRecording = false;
    });

    _timer?.cancel();
    _eegTimer?.cancel();
    _audioTimer?.cancel();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyzingScreen()),
    );

    if (widget.questionNumber < widget.totalQuestions) {
      Navigator.of(context).pop();
    } else {
      _showTestComplete();
    }
  }

  Future<void> _showTestComplete() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Test Complete',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'All questions answered!',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Done',
                style: TextStyle(color: _primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionNumber = widget.questionNumber;
    final totalQuestions = widget.totalQuestions;

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Live Answer & Recording',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _recScale,
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Live EEG
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live EEG',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderBlue),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 140,
                                width: width - 60,
                                child: CustomPaint(
                                  painter: _EEGPainter(
                                    alpha: _alpha,
                                    beta: _beta,
                                    gamma: _gamma,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: const [
                                  _LegendDot(
                                    color: Color(0xFFFF6384),
                                    label: 'Alpha',
                                  ),
                                  SizedBox(width: 20),
                                  _LegendDot(
                                    color: Color(0xFF36A2EB),
                                    label: 'Beta',
                                  ),
                                  SizedBox(width: 20),
                                  _LegendDot(
                                    color: Color(0xFFFFCE56),
                                    label: 'Gamma',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // VIDEO FEED (Camera Preview)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderBlue),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 200,
                          child: _isCameraInitialized &&
                                  _cameraController != null &&
                                  _cameraController!.value.isInitialized
                              ? CameraPreview(_cameraController!)
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF0B1120),
                                        Color(0xFF1D4ED8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        '📷',
                                        style: TextStyle(fontSize: 50),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Camera Initializing...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Please allow camera permission',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Voice waveform (same as before)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderBlue),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: _audioData
                                      .map(
                                        (h) => Container(
                                          width: 5,
                                          height: h,
                                          decoration: BoxDecoration(
                                            color: h > 40
                                                ? const Color(0xFFFF6384)
                                                : _primaryBlue,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pitch • Pauses • Frequency',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats (same as before)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderBlue),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${_recordingTime}s',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF1F2937),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '$questionNumber/$totalQuestions',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Question',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF1F2937),
                          ),
                          const Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '●',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF22C55E),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Timer
                  Center(
                    child: Text(
                      _formatTime(_recordingTime),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Finish button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _isRecording ? _handleFinishAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: _primaryBlue.withOpacity(0.7),
                      ),
                      child: const Center(
                        child: Text(
                          'FINISH ANSWER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _EEGPainter & _LegendDot same as tumhare code
class _EEGPainter extends CustomPainter {
  final List<double> alpha;
  final List<double> beta;
  final List<double> gamma;

  _EEGPainter({
    required this.alpha,
    required this.beta,
    required this.gamma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1;

    final wavePaintAlpha = Paint()
      ..color = const Color(0xFFFF6384)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final wavePaintBeta = Paint()
      ..color = const Color(0xFF36A2EB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final wavePaintGamma = Paint()
      ..color = const Color(0xFFFFCE56)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final dy = size.height / 4 * i;
      canvas.drawLine(
        Offset(0, dy),
        Offset(size.width, dy),
        gridPaint,
      );
    }

    void drawLine(List<double> data, Paint paint) {
      final path = Path();
      final step = size.width / (data.length - 1);
      for (int i = 0; i < data.length; i++) {
        final x = i * step;
        final y = size.height - (data[i] / 60) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    drawLine(alpha, wavePaintAlpha);
    drawLine(beta, wavePaintBeta);
    drawLine(gamma, wavePaintGamma);
  }

  @override
  bool shouldRepaint(covariant _EEGPainter oldDelegate) {
    return oldDelegate.alpha != alpha ||
        oldDelegate.beta != beta ||
        oldDelegate.gamma != gamma;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
