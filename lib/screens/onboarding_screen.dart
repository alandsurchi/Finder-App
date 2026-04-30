import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import '../routes.dart';

class _OnboardingPage {
  final String title;
  final String description;
  const _OnboardingPage({required this.title, required this.description});
}

const _pages = [
  _OnboardingPage(
    title: 'Lost Something?',
    description:
        'Report your missing essentials in seconds. Our neural network connects found items with their owners instantly.',
  ),
  _OnboardingPage(
    title: 'Found Something?',
    description:
        'Post found items and help return them to their rightful owners. Every good deed counts.',
  ),
  _OnboardingPage(
    title: 'Connect &\nCommunicate',
    description:
        'Chat, share details, and return items safely. Build trust within the community.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: logo + skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.ac_unit_rounded, color: t.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Finder',
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: t.onSurfaceVar,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildSlide(context, index, t),
              ),
            ),

            // ── Dots
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentPage == i ? 28 : 7,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? t.primary : t.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // ── Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast ? t.primary : t.surfaceHigh,
                        foregroundColor: isLast
                            ? (t.isDark ? Colors.black : Colors.white)
                            : t.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: isLast
                              ? BorderSide.none
                              : BorderSide(color: t.divider, width: 1.5),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Next',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isLast
                                  ? (t.isDark ? Colors.black : Colors.white)
                                  : t.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: isLast
                                ? (t.isDark ? Colors.black : Colors.white)
                                : t.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: t.onSurfaceVar,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, int index, AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            flex: 5,
            child: [
              _LostIllustration(t: t),
              _FoundIllustration(t: t),
              _ConnectIllustration(t: t),
            ][index],
          ),
          const SizedBox(height: 32),
          Text(
            _pages[index].title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _pages[index].description,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.onSurfaceVar, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Slide 1: Spotlight illustration
class _LostIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _LostIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: CustomPaint(
          painter: _SpotlightPainter(primaryColor: t.primary),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: t.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.primary.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.watch_outlined, color: t.primary, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Color primaryColor;
  const _SpotlightPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, circlePaint);

    final spotPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 0.8,
        colors: [primaryColor.withOpacity(0.20), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spotPaint);

    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.18), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final conePath = Path()
      ..moveTo(center.dx, center.dy - radius + 8)
      ..lineTo(center.dx - 60, center.dy + 40)
      ..lineTo(center.dx + 60, center.dy + 40)
      ..close();
    canvas.drawPath(conePath, conePaint);

    final dotPaint = Paint()..color = primaryColor.withOpacity(0.4);
    canvas.drawCircle(Offset(center.dx - 80, center.dy - 40), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx + 90, center.dy + 10), 2.5, dotPaint);
    canvas.drawCircle(Offset(center.dx + 40, center.dy - 70), 2, dotPaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.primaryColor != primaryColor;
}

// ── Slide 2: Found illustration
class _FoundIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _FoundIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: t.surfaceHigh,
        border: Border.all(color: t.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _FrostPainter(primaryColor: t.primary)),
          ),
          Positioned(
            right: 16,
            bottom: 20,
            child: Icon(
              Icons.vpn_key_rounded,
              color: t.onSurface.withOpacity(0.06),
              size: 80,
            ),
          ),
          Positioned(
            left: 24,
            bottom: 28,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
                border: Border.all(color: t.divider, width: 1),
              ),
              child: Icon(Icons.handshake_outlined, color: t.primary, size: 36),
            ),
          ),
          Positioned(
            right: 28,
            top: 60,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.primary.withOpacity(0.4)),
              ),
              child: Icon(
                Icons.manage_search_rounded,
                color: t.primary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrostPainter extends CustomPainter {
  final Color primaryColor;
  const _FrostPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(x, y), Offset(x + 10, y + 10), paint);
        canvas.drawLine(Offset(x + 10, y), Offset(x, y + 10), paint);
      }
    }
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [primaryColor.withOpacity(0.10), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);
  }

  @override
  bool shouldRepaint(_FrostPainter old) => old.primaryColor != primaryColor;
}

// ── Slide 3: Connect illustration
class _ConnectIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _ConnectIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.divider, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chatBubble(
            t: t,
            isLeft: true,
            avatarIcon: Icons.face_3,
            avatarColor: const Color(0xFFD4927A),
          ),
          const SizedBox(height: 12),
          _chatBubble(
            t: t,
            isLeft: false,
            avatarIcon: Icons.face,
            avatarColor: const Color(0xFF8B6E5A),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: t.divider, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: t.primary, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRUST',
                      style: TextStyle(
                        color: t.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                    Text(
                      'SECURED',
                      style: TextStyle(
                        color: t.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required AppColorTokens t,
    required bool isLeft,
    required IconData avatarIcon,
    required Color avatarColor,
  }) {
    final avatar = Container(
      width: 48,
      height: 52,
      decoration: BoxDecoration(
        color: avatarColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(avatarIcon, color: Colors.white, size: 28),
    );

    final textLines = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: t.onSurfaceVar,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              width: 120,
              decoration: BoxDecoration(
                color: t.onSurfaceVar.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isLeft
          ? [avatar, const SizedBox(width: 10), textLines]
          : [textLines, const SizedBox(width: 10), avatar],
    );
  }
}
