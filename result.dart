import 'dart:math';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Map<String, dynamic> result =
        args['result'] as Map<String, dynamic>;

    final String verdict = result['verdict'] as String;
    final double confidence =
        (result['confidence'] as num).toDouble();
    final Map<String, dynamic> eegAnalysis =
        result['eegAnalysis'] as Map<String, dynamic>;
    final Map<String, dynamic> voiceAnalysis =
        result['voiceAnalysis'] as Map<String, dynamic>;
    final int facialExpression =
        (result['facialExpression'] as num).toInt();
    final bool contradictionDetected =
        result['contradictionDetected'] as bool? ?? false;

    const double circleSize = 120;
    const double strokeWidth = 12;

    final facialEmojis = ['😟', '😊', '😐', '😠'];

    void handleNextQuestion() {
      Navigator.pushNamed(context, 'StartTest');
    }

    void handleEndSession() {
      Navigator.pushNamed(context, 'Home');
    }

    final Color primaryBlue = const Color(0xFF3B82F6);
    final Color bgDark = const Color(0xFF020617);

    final Color verdictColor =
        verdict == 'TRUTH' ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Result',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                // Main glass card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Verdict header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Text(
                              verdict,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: verdictColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              verdict == 'TRUTH'
                                  ? 'Subject likely telling the truth'
                                  : 'High probability of deception',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        color: Color(0xFF1F2937),
                        height: 24,
                        thickness: 1,
                      ),

                      // Circular confidence
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        child: SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(circleSize, circleSize),
                                painter: _CirclePainter(
                                  percentage: confidence / 100,
                                  strokeWidth: strokeWidth,
                                  bgColor:
                                      const Color(0xFF111827), // dark ring
                                  progressColor: verdictColor,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${confidence.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'CONFIDENCE LEVEL',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // EEG Analysis
                      _Section(
                        title: 'EEG Analysis',
                        titleColor: Colors.white,
                        child: Column(
                          children: [
                            _AnalysisItem(
                              label: 'Delta',
                              value: eegAnalysis['delta'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Theta',
                              value: eegAnalysis['theta'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Alpha',
                              value: eegAnalysis['alpha'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Beta',
                              value: eegAnalysis['beta'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Gamma',
                              value: eegAnalysis['gamma'] ?? '',
                            ),
                          ],
                        ),
                      ),

                      // Voice Analysis
                      _Section(
                        title: 'Voice Analysis',
                        titleColor: Colors.white,
                        child: Column(
                          children: [
                            _AnalysisItem(
                              label: 'Pitch',
                              value: voiceAnalysis['pitch'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Hesitation',
                              value: voiceAnalysis['hesitation'] ?? '',
                            ),
                            _AnalysisItem(
                              label: 'Pauses',
                              value: voiceAnalysis['pauses'] ?? '',
                            ),
                          ],
                        ),
                      ),

                      // Facial Expression
                      _Section(
                        title: 'Facial Expression',
                        titleColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            facialEmojis.length,
                            (index) {
                              final selected = facialExpression == index;
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF111827)
                                      : const Color(0xFF020617),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: selected
                                        ? primaryBlue
                                        : const Color(0xFF1F2937),
                                    width: 2,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: primaryBlue
                                                .withOpacity(0.5),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  facialEmojis[index],
                                  style: const TextStyle(fontSize: 26),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Contradiction warning
                      if (contradictionDetected)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF78350F).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFBBF24),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '⚠️',
                                  style: TextStyle(fontSize: 22),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Contradiction detected: Voice and EEG indicators show conflicting patterns.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFBBF24),
                                      height: 18 / 12,
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

                // Buttons (full width)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                            shadowColor:
                                primaryBlue.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Next Question',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: handleEndSession,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.7),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'End Session',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
}

// Section container (dark theme)
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Color titleColor;

  const _Section({
    required this.title,
    required this.child,
    this.titleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// Analysis item (dark theme)
class _AnalysisItem extends StatelessWidget {
  final String label;
  final String value;

  const _AnalysisItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNormal = value == 'Normal';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isNormal
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

// circular progress painter (same logic, colors adjusted)
class _CirclePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color bgColor;
  final Color progressColor;

  _CirclePainter({
    required this.percentage,
    required this.strokeWidth,
    required this.bgColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final double startAngle = -pi / 2 + (pi / 2);
    final double sweepAngle = 2 * pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
