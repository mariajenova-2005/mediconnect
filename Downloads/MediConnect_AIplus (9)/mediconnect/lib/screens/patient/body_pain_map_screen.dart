import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'find_doctor_screen.dart';
import 'ai_symptom_checker_screen.dart';
import 'emergency_screen.dart';

class _Region {
  final String name, specialist;
  final RRect rr;
  _Region(this.name, this.specialist, this.rr);
}

RRect _r(double l, double t, double r, double b, double rad) => RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

final _regions = <_Region>[
  _Region('Head', 'Neurologist', _r(70, 8, 130, 72, 30)),
  _Region('Chest', 'Cardiologist', _r(70, 82, 130, 165, 16)),
  _Region('Abdomen', 'Gastroenterologist', _r(72, 170, 128, 235, 14)),
  _Region('Right arm', 'Orthopedic', _r(34, 88, 62, 215, 13)),
  _Region('Left arm', 'Orthopedic', _r(138, 88, 166, 215, 13)),
  _Region('Right leg', 'Orthopedic', _r(72, 242, 98, 388, 13)),
  _Region('Left leg', 'Orthopedic', _r(102, 242, 128, 388, 13)),
];

/// Tap where it hurts → suggested specialist + next steps.
class BodyPainMapScreen extends StatefulWidget {
  const BodyPainMapScreen({super.key});
  @override
  State<BodyPainMapScreen> createState() => _BodyPainMapScreenState();
}

class _BodyPainMapScreenState extends State<BodyPainMapScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  _Region? _sel;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _sel != null && (_sel!.name == 'Chest' || _sel!.name == 'Head');
    return Scaffold(
      appBar: AppBar(title: const Text('Pain Map')),
      body: Column(children: [
        Expanded(
          child: LayoutBuilder(builder: (_, box) {
            final scale = math.min(box.maxWidth / 200, box.maxHeight / 400);
            final dx = (box.maxWidth - 200 * scale) / 2, dy = (box.maxHeight - 400 * scale) / 2;
            return GestureDetector(
              onTapDown: (d) {
                final p = Offset((d.localPosition.dx - dx) / scale, (d.localPosition.dy - dy) / scale);
                for (final r in _regions) {
                  if (r.rr.contains(p)) {
                    setState(() => _sel = r);
                    return;
                  }
                }
              },
              child: AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(size: Size.infinite, painter: _BodyPainter(_sel, _c.value, scale, dx, dy))),
            );
          }),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _sel == null
              ? const Padding(padding: EdgeInsets.all(20), child: Text('Tap the area that hurts', style: TextStyle(color: AppColors.textMuted)))
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card3d),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_sel!.name} pain', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('Suggested specialist: ${_sel!.specialist}', style: const TextStyle(color: AppColors.textMuted)),
                    if (urgent) const Padding(padding: EdgeInsets.only(top: 6), child: Text('If sudden or severe, use Emergency SOS immediately.', style: TextStyle(color: AppColors.severe, fontWeight: FontWeight.w600, fontSize: 12.5))),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, children: [
                      ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindDoctorScreen())), child: const Text('Find doctor')),
                      OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AISymptomCheckerScreen())), child: const Text('AI check')),
                      if (urgent) OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())), style: OutlinedButton.styleFrom(foregroundColor: AppColors.severe), child: const Text('SOS')),
                    ]),
                  ]),
                ),
        ),
      ]),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final _Region? sel;
  final double t, scale, dx, dy;
  _BodyPainter(this.sel, this.t, this.scale, this.dx, this.dy);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(dx, dy);
    canvas.scale(scale);
    for (final r in _regions) {
      final selected = identical(r, sel);
      if (selected) canvas.drawRRect(r.rr, Paint()..color = AppColors.severe.withOpacity(0.35 + 0.35 * math.sin(t * 2 * math.pi).abs())..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawRRect(r.rr, Paint()..shader = LinearGradient(colors: selected ? [AppColors.severe, const Color(0xFFF5725B)] : [AppColors.primaryBlue.withOpacity(0.55), AppColors.accentGreen.withOpacity(0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(r.rr.outerRect));
      canvas.drawRRect(r.rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = Colors.white.withOpacity(0.8));
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter o) => true;
}
