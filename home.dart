import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleStartNewTest(BuildContext context) {
    Navigator.pushNamed(context, 'ParticipantData');
  }

  void _handleSessionHistory(BuildContext context) {
    Navigator.pushNamed(context, 'SessionSummary');
  }

  void _handleProfileSettings(BuildContext context) {
    Navigator.pushNamed(context, 'Profile');
  }

  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, 'Login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF020617);
    const Color primaryBlue = Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: primaryBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () => _handleLogout(context),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose an option to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cards
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _HomeCard(
                                icon: '📹',
                                title: 'Start New Test',
                                onTap: () => _handleStartNewTest(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HomeCard(
                                icon: '🕐',
                                title: 'Session History',
                                onTap: () => _handleSessionHistory(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _HomeCard(
                          icon: '⚙️',
                          title: 'Profile & Settings',
                          onTap: () => _handleProfileSettings(context),
                          fullWidth: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Footer
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            'Multimodal Lie Detection System',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI-Powered Truth Analysis',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: fullWidth ? const EdgeInsets.symmetric(horizontal: 6) : null,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1F2937),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 14),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
