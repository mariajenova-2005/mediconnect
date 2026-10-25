import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Animated gradient ring gauge + sub-scores. Values are demo data until wired to real vitals.
class HealthScoreCard extends StatelessWidget {
  final int score;
  const HealthScoreCard({super.key, this.score = 86});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score / 100),
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => SizedBox(
            width: 104,
            height: 104,
            child: CustomPaint(painter: _RingPainter(v), child: Center(child: Text('${(v * 100).round()}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)))),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Health Score', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            Text('Excellent · up 3 this week', style: TextStyle(color: AppColors.softGreen, fontSize: 12)),
            SizedBox(height: 10),
            _Bar('Heart', 0.9),
            _Bar('Sleep', 0.74),
            _Bar('Activity', 0.82),
          ]),
        ),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double v;
  const _Bar(this.label, this.v);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          SizedBox(width: 52, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: v), duration: const Duration(milliseconds: 1500), builder: (_, x, __) => LinearProgressIndicator(value: x, minHeight: 6, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen))))),
        ]),
      );
}

class _RingPainter extends CustomPainter {
  final double v;
  _RingPainter(this.v);
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset(8, 8) & Size(s.width - 16, s.height - 16);
    canvas.drawArc(rect, 0, 2 * math.pi, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 10..color = Colors.white24);
    final shader = SweepGradient(colors: const [AppColors.primaryBlue, AppColors.accentGreen, Color(0xFFB9F2E4)], transform: const GradientRotation(-math.pi / 2)).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * v, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.v != v;
}
