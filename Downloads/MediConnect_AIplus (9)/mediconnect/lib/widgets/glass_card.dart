import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted glassmorphic container used across the "innovative" dashboards.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Animated orbiting-dot backdrop used behind the patient "Health Twin"
/// header to give a subtle, modern 3D-ish feel without a real 3D engine.
class TwinBackdrop extends StatefulWidget {
  const TwinBackdrop({super.key});
  @override
  State<TwinBackdrop> createState() => _TwinBackdropState();
}

class _TwinBackdropState extends State<TwinBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _OrbitPainter(_c.value), size: Size.infinite),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double t;
  _OrbitPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.16);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(0.18);
    for (final r in [55.0, 90.0, 125.0]) {
      canvas.drawCircle(center, r, ringPaint);
    }
    final dotPaint = Paint()..color = AppColors.softGreen.withOpacity(0.9);
    for (var i = 0; i < 3; i++) {
      final angle = (t * 2 * math.pi) + (i * 2.0);
      final r = 55.0 + i * 35;
      final dx = center.dx + r * math.cos(angle);
      final dy = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => oldDelegate.t != t;
}

/// A card that tilts in 3D (perspective transform) as the user drags across
/// it — used for the "3D twin" feature tiles. Pure Flutter `Matrix4`
/// perspective, no external 3D engine needed.
class TiltCard3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TiltCard3D({super.key, required this.child, this.onTap});

  @override
  State<TiltCard3D> createState() => _TiltCard3DState();
}

class _TiltCard3DState extends State<TiltCard3D> {
  double _rx = 0, _ry = 0;

  void _update(Offset local, Size size) {
    setState(() {
      _ry = ((local.dx / size.width) - 0.5) * 0.35;
      _rx = ((local.dy / size.height) - 0.5) * -0.35;
    });
  }

  void _reset() => setState(() {
        _rx = 0;
        _ry = 0;
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (d) {
        final box = context.findRenderObject() as RenderBox;
        _update(box.globalToLocal(d.globalPosition), box.size);
      },
      onPanEnd: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(_rx)
          ..rotateY(_ry),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
