import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import '../../theme/app_theme.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});
  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  int _glasses = 3;
  static const _goal = 8;
  final _h = TextEditingController(text: '165'), _w = TextEditingController(text: '60');

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hm = (double.tryParse(_h.text) ?? 0) / 100, kg = double.tryParse(_w.text) ?? 0;
    final bmi = hm > 0 ? kg / (hm * hm) : 0.0;
    final (cat, col) = bmi == 0 ? ('—', AppColors.textMuted) : bmi < 18.5 ? ('Underweight', AppColors.moderate) : bmi < 25 ? ('Normal', AppColors.mild) : bmi < 30 ? ('Overweight', AppColors.moderate) : ('Obese', AppColors.severe);
    return Scaffold(
      appBar: AppBar(title: const Text('Wellness')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
          HeroBanner(title: 'Daily Wellness', subtitle: 'Hydration and body-mass tracking', icon: Icons.water_drop_rounded, colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)]),
          const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.card3d),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 120,
                height: 160,
                color: AppColors.primaryBlue.withOpacity(0.08),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (_glasses / _goal).clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, f, __) => AnimatedBuilder(animation: _wave, builder: (_, __) => CustomPaint(painter: _WavePainter(_wave.value, f))),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hydration', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              Text('$_glasses / $_goal glasses · ${_glasses * 250} ml', style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 14),
              Row(children: [
                IconButton.filledTonal(onPressed: () => setState(() => _glasses = math.max(0, _glasses - 1)), icon: const Icon(Icons.remove_rounded)),
                const SizedBox(width: 10),
                IconButton.filled(style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue), onPressed: () => setState(() => _glasses++), icon: const Icon(Icons.add_rounded)),
              ]),
              if (_glasses >= _goal) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Goal reached 🎉', style: TextStyle(color: AppColors.mild, fontWeight: FontWeight.w700))),
            ])),
          ]),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.card3d),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('BMI Calculator', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _h, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Height (cm)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _w, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Weight (kg)'))),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: col, height: 1)),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: col.withOpacity(0.14), borderRadius: BorderRadius.circular(20)), child: Text(cat, style: TextStyle(color: col, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 6),
            const Text('General guide only — not a diagnosis.', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          ]),
        ),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t, fill;
  _WavePainter(this.t, this.fill);
  @override
  void paint(Canvas canvas, Size s) {
    for (var layer = 0; layer < 2; layer++) {
      final base = s.height * (1 - fill);
      final path = Path()..moveTo(0, s.height);
      for (double x = 0; x <= s.width; x += 3) {
        path.lineTo(x, base + math.sin(x / s.width * 2 * math.pi * 1.5 + t * 2 * math.pi * (layer == 0 ? 1 : -1) + layer) * 6);
      }
      path..lineTo(s.width, s.height)..close();
      canvas.drawPath(path, Paint()..color = (layer == 0 ? AppColors.primaryBlue : AppColors.accentGreen).withOpacity(layer == 0 ? 0.75 : 0.45));
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter o) => o.t != t || o.fill != fill;
}
