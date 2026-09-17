import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_entry.dart';
import 'app_image.dart';

class HeroCarousel extends StatefulWidget {
  final List<String> images;
  final List<String> captions;
  final double height;

  /// When provided, the slide shows this bold headline in place of the
  /// compact caption-only overlay.
  final String? headline;

  /// Secondary line rendered under [headline].
  final String? subheadline;

  /// Adds a "Book a Service" primary button to each slide.
  final VoidCallback? onBookService;

  /// Adds a "Find a Mechanic" secondary button to each slide.
  final VoidCallback? onFindMechanic;

  const HeroCarousel({
    super.key,
    required this.images,
    required this.captions,
    this.height = 220,
    this.headline,
    this.subheadline,
    this.onBookService,
    this.onFindMechanic,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  bool get _showCta => widget.headline != null;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _next());
  }

  void _next() {
    if (!mounted || !_controller.hasClients) return;
    final next = (_current + 1) % widget.images.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final isActive = index == _current;
              return AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: isActive ? 0 : 6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: isActive ? 1.0 : 0.96,
                      child: AppImage(
                        widget.images[index],
                        radius: BorderRadius.circular(24),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _showCta
                              ? const [
                                  Color(0xFF061B2E),
                                  Color(0xFF0A2E4B),
                                  Color(0xFF06202F),
                                ]
                              : [
                                  Colors.transparent,
                                  AppTheme.ink.withValues(alpha: 0.35),
                                  AppTheme.ink.withValues(alpha: 0.82),
                                ],
                          stops: _showCta ? null : const [0.35, 0.7, 1.0],
                        ),
                      ),
                    ),
                    if (_showCta) ...[
                      Positioned(
                        right: 26,
                        top: 22,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt,
                                  size: 13, color: Color(0xFF78350F)),
                              SizedBox(width: 5),
                              Text(
                                'Available 24/7',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF78350F),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 26,
                        right: 26,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.headline!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            if (widget.subheadline != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.subheadline!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _CtaButton.primary(
                                  label: 'Book a Service Now',
                                  icon: Icons.calendar_month_outlined,
                                  onTap: widget.onBookService,
                                ),
                                const SizedBox(width: 12),
                                _CtaButton.secondary(
                                  label: 'Find a Mechanic',
                                  icon: Icons.location_on_outlined,
                                  onTap: widget.onFindMechanic,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AutoAssist',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.captions[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 18,
            child: Row(
              children: List.generate(widget.images.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 5),
                  width: active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? (_showCta ? const Color(0xFFF59E0B) : Colors.white)
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  const _CtaButton.primary({
    required this.label,
    required this.icon,
    this.onTap,
  }) : primary = true;

  const _CtaButton.secondary({
    required this.label,
    required this.icon,
    this.onTap,
  }) : primary = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: primary ? null : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: primary ? Colors.transparent : Colors.white54,
            width: 1.4,
          ),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: const Color(0xFFF97316).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: primary ? Colors.white : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: primary ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}