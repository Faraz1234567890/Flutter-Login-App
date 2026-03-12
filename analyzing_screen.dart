import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      final question = args?['question'] ?? '';
      final recordingTime = args?['recordingTime'] ?? 0;

      final result = _generateAnalysisResult();

      Navigator.pushReplacementNamed(
        context,
        'Result',
        arguments: {
          'question': question,
          'recordingTime': recordingTime,
          'result': result,
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _generateAnalysisResult() {
    final random = Random();
    final confidence = random.nextInt(20) + 75; // 75–94
    final isTruth = confidence > 70;

    return {
      'verdict': isTruth ? 'TRUTH' : 'LIE',
      'confidence': confidence,
      'eegAnalysis': {
        'delta': random.nextBool() ? 'Normal' : 'Elevated',
        'theta': random.nextBool() ? 'Normal' : 'Low',
        'alpha': random.nextBool() ? 'Normal' : 'High',
        'beta': random.nextBool() ? 'Normal' : 'Elevated',
        'gamma': random.nextBool() ? 'Low' : 'Normal',
      },
      'voiceAnalysis': {
        'pitch': random.nextBool() ? 'Normal' : 'Elevated',
        'hesitation': random.nextBool() ? 'None' : 'Moderate',
        'pauses': random.nextBool() ? 'Normal' : 'Frequent',
      },
      'facialExpression': random.nextInt(4), // 0–3
      'contradictionDetected': random.nextDouble() > 0.7,
    };
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Analyzing Session',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B1F5C),
                Color(0xFF020617),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Analyzing data,\nplease wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 30 / 22,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // outer faint ring
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.25),
                                width: 4,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Processing EEG, audio, and video streams...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
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
    );
  }
}
