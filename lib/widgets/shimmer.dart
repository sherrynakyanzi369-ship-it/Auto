import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? radius;

  const ShimmerBox({super.key, this.width, this.height, this.radius});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFFE8ECF4);
    final highlight = const Color(0xFFF7F9FC);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-1 + 2 * t, 0),
            end: Alignment(1, 0),
          ).createShader(rect),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              borderRadius: widget.radius ?? BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}