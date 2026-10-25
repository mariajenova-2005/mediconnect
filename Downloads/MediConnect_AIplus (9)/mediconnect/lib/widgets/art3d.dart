import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

Color _shade(Color c, double amount) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Glossy 3D icon tile: depth edge, gradient face, highlight, and a gentle floating tilt.
class Icon3D extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final bool animate;
  const Icon3D({super.key, required this.icon, this.color = AppColors.primaryBlue, this.iconColor = Colors.white, this.size = 44, this.animate = true});
  @override
  State<Icon3D> createState() => _Icon3DState();
}

class _Icon3DState extends State<Icon3D> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late final double _phase = (widget.icon.codePoint % 100) / 100;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = ((_c.value + _phase) % 1.0) * 2 * math.pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, 0.0015)..rotateX(0.2 * math.sin(t))..rotateY(0.3 * math.cos(t)),
          child: SizedBox(
            width: s + 6,
            height: s + 6,
            child: Stack(children: [
              Positioned(top: 6, left: 3, child: Container(width: s, height: s, decoration: BoxDecoration(color: _shade(widget.color, -0.22), borderRadius: BorderRadius.circular(s * 0.3)))),
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_shade(widget.color, 0.14), _shade(widget.color, -0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(s * 0.3),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                  boxShadow: [BoxShadow(color: widget.color.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 8))],
                ),
                child: Stack(children: [
                  Positioned(top: s * 0.08, left: s * 0.12, child: Container(width: s * 0.5, height: s * 0.16, decoration: BoxDecoration(color: Colors.white.withOpacity(0.35), borderRadius: BorderRadius.circular(s)))),
                  Center(child: Icon(widget.icon, color: widget.iconColor, size: s * 0.5, shadows: const [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))])),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

/// Glossy 3D initial avatar (green→blue sphere look).
class Avatar3D extends StatelessWidget {
  final double radius;
  final String label;
  const Avatar3D({super.key, required this.radius, required this.label});
  @override
  Widget build(BuildContext context) => Container(
        width: radius * 2,
        height: radius * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(center: Alignment(-0.4, -0.5), colors: [Color(0xFF8CF5DD), AppColors.accentGreen, AppColors.primaryBlue], stops: [0, 0.45, 1]),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Text(label.isEmpty ? '?' : label.substring(0, 1).toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: radius * 0.85, shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))])),
      );
}

/// Animated gradient banner with floating bubbles and a 3D icon — used at the top of pages.
class HeroBanner extends StatefulWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color> colors;
  const HeroBanner({super.key, required this.title, required this.subtitle, required this.icon, this.colors = const [AppColors.primaryBlue, AppColors.accentGreen]});
  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: widget.colors.first.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(children: [
          Positioned.fill(child: AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _BubblePainter(_c.value)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(widget.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                ]),
              ),
              Icon3D(icon: widget.icon, color: Colors.white, iconColor: widget.colors.first, size: 58),
            ]),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 450.ms).moveY(begin: -14, end: 0, curve: Curves.easeOut);
  }
}

class _BubblePainter extends CustomPainter {
  final double t;
  _BubblePainter(this.t);
  static const _b = [(0.1, 0.9, 16.0), (0.3, 0.6, 9.0), (0.55, 0.85, 22.0), (0.72, 0.5, 12.0), (0.88, 0.8, 18.0), (0.45, 0.3, 7.0)];
  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < _b.length; i++) {
      final p = (t + i / _b.length) % 1.0;
      final x = s.width * _b[i].$1 + 8 * math.sin(p * 2 * math.pi + i);
      final y = s.height * (1.1 - p * 1.3);
      canvas.drawCircle(Offset(x, y), _b[i].$3, Paint()..color = Colors.white.withOpacity(0.10 + 0.08 * math.sin(p * math.pi)));
      canvas.drawCircle(Offset(x, y), _b[i].$3, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withOpacity(0.25));
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter o) => o.t != t;
}
