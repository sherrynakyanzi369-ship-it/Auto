import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
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
    begin: const Offset(0, 0.18),
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
    await Future<void>.delayed(const Duration(milliseconds: 5550));
    final loggedIn = await AuthService.instance.restoreSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => loggedIn ? const HomeShell() : const LoginScreen(),
      ),
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
          final double breathe = 1.0 + 0.04 * wave;
          final double float = 4.0 + 3.0 * wave;
          final double glow = wave * 0.5 + 0.5;
          final int percent = (p * 100).round();

          return Stack(
            fit: StackFit.expand,
            children: [
              // ---- Animated background ----
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF050B18), Color(0xFF0D3B66), Color(0xFF092A49)],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: -150,
                right: -100,
                child: Transform.translate(
                  offset: Offset(wave * 32, 0),
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accent.withValues(alpha: 0.26),
                          AppTheme.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -170,
                left: -120,
                child: Transform.translate(
                  offset: Offset(-wave * 36, 0),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1F7EB6).withValues(alpha: 0.28),
                          const Color(0xFF1F7EB6).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),

              // ---- Center stage ----
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SlideTransition(
                              position: _slideUp,
                              child: FadeTransition(
                                opacity: _fadeUp,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Transform.translate(
                                    offset: Offset(0, float),
                                    child: Container(
                                      width: 156,
                                      height: 156,
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.accent,
                                            Color(0xFF1F7EB6),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accent.withValues(
                                              alpha: 0.25 + glow * 0.4,
                                            ),
                                            blurRadius: 44 + glow * 34,
                                            spreadRadius: 2 + glow * 7,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Transform.scale(
                                          scale: breathe * 1.12,
                                          child: Image.asset(
                                            'assets/images/Logo.jpeg',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                              Icons.directions_car_filled,
                                              size: 64,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            SlideTransition(
                              position: _slideUp,
                              child: FadeTransition(
                                opacity: _fadeUp,
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD87A),
                                      AppTheme.accent,
                                      Color(0xFFFB8C2C),
                                    ],
                                  ).createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: const Text(
                                    'AutoAssist',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
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
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: const Text(
                                    'ROADSIDE  •  MECHANICS  •  SPARES  •  AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ---- Advanced loader ----
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
                                      minHeight: 5,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.12),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppTheme.accent,
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
                                          Colors.white.withValues(alpha: 0.12),
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Preparing your garage…',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
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
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}