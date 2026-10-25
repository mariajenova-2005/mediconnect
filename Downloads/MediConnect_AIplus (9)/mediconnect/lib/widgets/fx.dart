import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Slowly drifting blurred colour blobs over a deep blue gradient.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});
  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _blob(double size, Color color, Alignment a) => Align(
        alignment: a,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(0.55), color.withOpacity(0)])),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF031F33), AppColors.deepBlue, Color(0xFF0A5C73)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value * 2 * math.pi;
            return Stack(children: [
              _blob(380, AppColors.accentGreen, Alignment(-1 + 0.5 * math.sin(t), -0.8 + 0.3 * math.cos(t))),
              _blob(420, AppColors.primaryBlue, Alignment(1 - 0.4 * math.cos(t), -0.1 + 0.4 * math.sin(t))),
              _blob(340, const Color(0xFF2EE6C5), Alignment(-0.3 + 0.5 * math.cos(t * 1.3), 1 - 0.3 * math.sin(t))),
            ]);
          },
        ),
        const FloatingMedIcons(),
        widget.child,
      ],
    );
  }
}

/// A glowing gradient sphere with tilted spinning rings — a pseudo-3D "Health Twin".
class HealthOrb extends StatefulWidget {
  final double size;
  const HealthOrb({super.key, this.size = 130});
  @override
  State<HealthOrb> createState() => _HealthOrbState();
}

class _HealthOrbState extends State<HealthOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();

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
        final t = _c.value * 2 * math.pi;
        final pulse = 1 + 0.035 * math.sin(t * 6);
        return Transform.translate(
          offset: Offset(0, 6 * math.sin(t)),
          child: SizedBox(
            width: s * 1.7,
            height: s * 1.7,
            child: Stack(alignment: Alignment.center, children: [
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(center: Alignment(-0.4, -0.5), colors: [Colors.white, AppColors.accentGreen, AppColors.primaryBlue, AppColors.deepBlue], stops: [0, 0.3, 0.7, 1]),
                    boxShadow: [BoxShadow(color: AppColors.accentGreen.withOpacity(0.55), blurRadius: 45, spreadRadius: 4)],
                  ),
                  child: Icon(Icons.favorite_rounded, color: Colors.white.withOpacity(0.9), size: s * 0.36),
                ),
              ),
              for (var i = 0; i < 3; i++)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(1.0 + i * 0.45)
                    ..rotateY(i * 0.6)
                    ..rotateZ(t * (i.isEven ? 1 : -1) + i),
                  child: Container(
                    width: s * (1.25 + i * 0.18),
                    height: s * (1.25 + i * 0.18),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.55 - i * 0.12), width: 1.6)),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}

/// Rotating pseudo-3D DNA double helix (depth-sorted, size + opacity by depth).
class DnaHelix extends StatefulWidget {
  final double width, height;
  const DnaHelix({super.key, this.width = 90, this.height = 150});
  @override
  State<DnaHelix> createState() => _DnaHelixState();
}

class _DnaHelixState extends State<DnaHelix> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(size: Size(widget.width, widget.height), painter: _DnaPainter(_c.value)),
      );
}

class _DnaPainter extends CustomPainter {
  final double t;
  _DnaPainter(this.t);
  static const _blue = Color(0xFF5CC8FF);

  @override
  void paint(Canvas canvas, Size s) {
    const n = 16;
    final cx = s.width / 2, amp = s.width * 0.36, phase = t * 2 * math.pi;
    final a = <Offset>[], b = <Offset>[], z = <double>[];
    for (var i = 0; i < n; i++) {
      final y = s.height * (i + 0.5) / n, ang = phase + i * 0.6, c = math.cos(ang);
      z.add(math.sin(ang));
      a.add(Offset(cx + amp * c, y));
      b.add(Offset(cx - amp * c, y));
    }
    final line = Paint()..strokeWidth = 1.6;
    for (var i = 0; i < n; i++) {
      canvas.drawLine(a[i], b[i], line..color = Colors.white.withOpacity(0.12 + 0.18 * z[i].abs()));
      if (i < n - 1) {
        canvas.drawLine(a[i], a[i + 1], line..color = AppColors.accentGreen.withOpacity(0.4));
        canvas.drawLine(b[i], b[i + 1], line..color = _blue.withOpacity(0.4));
      }
    }
    final dots = <(Offset, double, Color)>[
      for (var i = 0; i < n; i++) (a[i], z[i], AppColors.accentGreen),
      for (var i = 0; i < n; i++) (b[i], -z[i], _blue),
    ]..sort((p, q) => p.$2.compareTo(q.$2));
    for (final d in dots) {
      final r = 4.5 + 2.5 * d.$2, op = 0.55 + 0.45 * (d.$2 + 1) / 2;
      canvas.drawCircle(d.$1, r * 1.9, Paint()..color = d.$3.withOpacity(op * 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(d.$1, r, Paint()..color = d.$3.withOpacity(op));
    }
  }

  @override
  bool shouldRepaint(covariant _DnaPainter o) => o.t != t;
}

/// Glass hero card: 3D DNA helix + live BPM + scrolling ECG trace.
class VitalsHero extends StatefulWidget {
  const VitalsHero({super.key});
  @override
  State<VitalsHero> createState() => _VitalsHeroState();
}

class _VitalsHeroState extends State<VitalsHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const DnaHelix(),
        const SizedBox(width: 14),
        Expanded(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final w = _c.value * 2 * math.pi;
              final bpm = 72 + (3 * math.sin(w * 3)).round();
              final beat = 1 + 0.2 * math.pow(math.sin(w * 2).abs(), 10).toDouble();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Transform.scale(scale: beat, child: const Icon(Icons.favorite_rounded, color: AppColors.severe, size: 20)),
                  const SizedBox(width: 6),
                  const Text('LIVE · HEALTH TWIN', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$bpm', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
                  const Padding(padding: EdgeInsets.only(left: 4, bottom: 5), child: Text('BPM', style: TextStyle(color: Colors.white60, fontSize: 12))),
                ]),
                const SizedBox(height: 8),
                SizedBox(height: 56, width: double.infinity, child: CustomPaint(painter: _EcgPainter(_c.value))),
                const Text('Rhythm normal · vitals stable', style: TextStyle(color: AppColors.softGreen, fontSize: 11.5)),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double t;
  _EcgPainter(this.t);
  static const _pts = [(0.0, 0.0), (0.08, 0.0), (0.12, 0.12), (0.16, 0.0), (0.26, 0.0), (0.29, -0.18), (0.33, 1.0), (0.37, -0.35), (0.40, 0.0), (0.52, 0.0), (0.58, 0.22), (0.66, 0.0), (1.0, 0.0)];

  double _f(double u) {
    for (var i = 0; i < _pts.length - 1; i++) {
      if (u <= _pts[i + 1].$1) {
        final k = (u - _pts[i].$1) / (_pts[i + 1].$1 - _pts[i].$1);
        return _pts[i].$2 + (_pts[i + 1].$2 - _pts[i].$2) * k;
      }
    }
    return 0;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path();
    for (double x = 0; x <= s.width; x += 2) {
      final u = (x / s.width * 2 + t) % 1.0;
      final y = s.height * 0.62 - _f(u) * s.height * 0.55;
      x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final shader = LinearGradient(colors: [AppColors.accentGreen.withOpacity(0), AppColors.accentGreen]).createShader(Offset.zero & s);
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..shader = shader..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter o) => o.t != t;
}

/// Faint 3D-spinning medical icons drifting in the background.
class FloatingMedIcons extends StatefulWidget {
  final Color color;
  final double opacity;
  const FloatingMedIcons({super.key, this.color = Colors.white, this.opacity = 0.10});
  @override
  State<FloatingMedIcons> createState() => _FloatingMedIconsState();
}

class _FloatingMedIconsState extends State<FloatingMedIcons> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _items = <(IconData, Alignment)>[
    (Icons.add_rounded, Alignment(-0.9, -0.75)),
    (Icons.medication_rounded, Alignment(0.9, -0.5)),
    (Icons.vaccines_rounded, Alignment(-0.7, 0.0)),
    (Icons.biotech_rounded, Alignment(0.85, 0.2)),
    (Icons.bloodtype_rounded, Alignment(-0.85, 0.65)),
    (Icons.monitor_heart_rounded, Alignment(0.7, 0.85)),
    (Icons.science_rounded, Alignment(0.1, -0.95)),
  ];

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value * 2 * math.pi;
            return Stack(children: [
              for (var i = 0; i < _items.length; i++)
                Align(
                  alignment: _items[i].$2,
                  child: Transform.translate(
                    offset: Offset(0, 12 * math.sin(t + i)),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateY(t + i)..rotateX(0.4 * math.sin(t + i)),
                      child: Icon(_items[i].$1, size: 34.0 + (i % 3) * 12, color: widget.color.withOpacity(widget.opacity)),
                    ),
                  ),
                ),
            ]);
          },
        ),
      );
}

/// 3D "page flip" transition used for every route (via the app theme).
class MedPageTransitions extends PageTransitionsBuilder {
  const MedPageTransitions();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (_, c) => Opacity(
        opacity: curved.value.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()..setEntry(3, 2, 0.0012)..rotateY((1 - curved.value) * 0.35)..translate((1 - curved.value) * 60.0),
          child: c,
        ),
      ),
    );
  }
}

/// Soft animated light-mode backdrop shown behind every screen.
class LightBackdrop extends StatefulWidget {
  const LightBackdrop({super.key});
  @override
  State<LightBackdrop> createState() => _LightBackdropState();
}

class _LightBackdropState extends State<LightBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _blob(Color c, Alignment a) => Align(
        alignment: a,
        child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.withOpacity(0.22), c.withOpacity(0)]))),
      );

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Stack(fit: StackFit.expand, children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgLight, Color(0xFFE2F6F0), Color(0xFFE4F0FA)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = _c.value * 2 * math.pi;
              return Stack(children: [
                _blob(AppColors.accentGreen, Alignment(-1 + 0.4 * math.sin(t), -0.9 + 0.2 * math.cos(t))),
                _blob(AppColors.primaryBlue, Alignment(1 - 0.3 * math.cos(t), 0.9 - 0.3 * math.sin(t))),
              ]);
            },
          ),
          const FloatingMedIcons(color: AppColors.primaryBlue, opacity: 0.07),
        ]),
      );
}

/// Standalone scrolling ECG trace.
class EcgStrip extends StatefulWidget {
  const EcgStrip({super.key});
  @override
  State<EcgStrip> createState() => _EcgStripState();
}

class _EcgStripState extends State<EcgStrip> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _EcgPainter(_c.value), size: Size.infinite));
}

/// Expanding radar rings — used on the emergency screen.
class PulseRadar extends StatefulWidget {
  const PulseRadar({super.key});
  @override
  State<PulseRadar> createState() => _PulseRadarState();
}

class _PulseRadarState extends State<PulseRadar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          for (var i = 0; i < 3; i++)
            Builder(builder: (_) {
              final p = (_c.value + i / 3) % 1.0;
              return Container(width: 36 + 80 * p, height: 36 + 80 * p, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.severe.withOpacity(1 - p), width: 2)));
            }),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.emergencyGradient),
            child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
          ),
        ]),
      );
}
