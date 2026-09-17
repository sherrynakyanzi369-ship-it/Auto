import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Branding extracted from assets/images/Logo.jpeg:
  // a white canvas with navy ink and orange accents.
  static const Color _ink = Color(0xFF153043);
  static const Color _orange = Color(0xFFF49F2B);
  static const Color _orangeDeep = Color(0xFFD97B0F);

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final AnimationController _loader = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  late final Animation<double> _fadeUp = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.10, 0.45, curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.16),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.30, curve: Curves.elasticOut),
  );
  late final Animation<double> _loaderFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loader.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    // Restore a saved session if one exists. Guests are NOT sent to the auth
    // screen — they land on the home dashboard and are asked to sign in only
    // when they request a service.
    await AuthService.instance.restoreSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_entrance, _loader]),
        builder: (context, _) {
          final double p = _loader.value;
          final double wave = math.sin(p * math.pi * 2);
          final double breathe = 1.0 + 0.03 * wave;
          final double float = 3.0 + 3.0 * wave;
          final double glow = wave * 0.5 + 0.5;
          final int percent = (p * 100).round();

          return Stack(
            fit: StackFit.expand,
            children: [
              // ---- Bright canvas (matches the logo's white background) ----
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                  ),
                ),
              ),
              Positioned(
                top: -140,
                left: -110,
                child: Transform.translate(
                  offset: Offset(wave * 26, 0),
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _orange.withValues(alpha: 0.22),
                          _orange.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -120,
                child: Transform.translate(
                  offset: Offset(-wave * 28, 0),
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _ink.withValues(alpha: 0.14),
                          _ink.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter(color: _ink)),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ---- Logo card (updated from Logo.jpeg) ----
                              SlideTransition(
                                position: _slideUp,
                                child: FadeTransition(
                                  opacity: _fadeUp,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: Transform.translate(
                                      offset: Offset(0, float),
                                      child: Container(
                                        width: 212,
                                        height: 212 * (848 / 1024),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          border: Border.all(
                                            color: Colors.black
                                                .withValues(alpha: 0.06),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _ink.withValues(
                                                alpha: 0.10 + glow * 0.10,
                                              ),
                                              blurRadius: 36 + glow * 20,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Transform.scale(
                                            scale: breathe * 1.01,
                                            child: Image.asset(
                                              'assets/images/Logo.jpeg',
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) =>
                                                  const ColoredBox(
                                                color: Color(0xFFE8EDF5),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.directions_car_filled,
                                                    size: 56,
                                                    color: _ink,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // ---- Wordmark "AA AutoAssist" ----
                              SlideTransition(
                                position: _slideUp,
                                child: FadeTransition(
                                  opacity: _fadeUp,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'AA',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                          color: _orange,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'AutoAssist',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.8,
                                          color: _ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // ---- Tagline texts ----
                              SlideTransition(
                                position: _slideUp,
                                child: FadeTransition(
                                  opacity: _fadeUp,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: _orange.withValues(alpha: 0.35),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _ink.withValues(alpha: 0.05),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'ROADSIDE  •  MECHANICS  •  SPARES  •  AI',
                                      style: TextStyle(
                                        color: _ink,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SlideTransition(
                                position: _slideUp,
                                child: FadeTransition(
                                  opacity: _fadeUp,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: _orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '24/7 Roadside Help',
                                        style: TextStyle(
                                          color: _ink.withValues(alpha: 0.6),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---- Loader ----
                    FadeTransition(
                      opacity: _loaderFade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _loader.value,
                                      minHeight: 6,
                                      backgroundColor:
                                          _ink.withValues(alpha: 0.08),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        _orange,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Transform.rotate(
                                    angle: p * math.pi * 2,
                                    child: CircularProgressIndicator(
                                      value: _loader.value,
                                      strokeWidth: 3,
                                      backgroundColor:
                                          _ink.withValues(alpha: 0.08),
                                      color: _orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Preparing your garage…',
                                  style: TextStyle(
                                    color: _ink.withValues(alpha: 0.55),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    color: _orangeDeep,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
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
            ],
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.color != color;
}