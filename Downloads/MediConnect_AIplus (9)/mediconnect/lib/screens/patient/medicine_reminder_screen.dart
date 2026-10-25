import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class _Reminder {
  final String name, dose;
  final TimeOfDay time;
  bool taken = false;
  _Reminder(this.name, this.dose, this.time);
}

final List<_Reminder> _reminders = [
  _Reminder('Amoxicillin 500mg', '1 capsule · after food', const TimeOfDay(hour: 8, minute: 0)),
  _Reminder('Vitamin D3', '1 tablet', const TimeOfDay(hour: 13, minute: 30)),
  _Reminder('Salbutamol inhaler', '2 puffs', const TimeOfDay(hour: 21, minute: 0)),
];

/// In-app dose tracker (marks "Due" when the time passes). Push alerts when the app is
/// closed need `flutter_local_notifications` — see README.
class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});
  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  Future<void> _add() async {
    final name = TextEditingController(), dose = TextEditingController();
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Medicine details'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Medicine name')),
          const SizedBox(height: 10),
          TextField(controller: dose, decoration: const InputDecoration(hintText: 'Dose (e.g. 1 tablet)')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save'))],
      ),
    );
    if (name.text.trim().isNotEmpty) setState(() => _reminders.add(_Reminder(name.text.trim(), dose.text.trim(), time)));
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final taken = _reminders.where((r) => r.taken).length;
    final progress = _reminders.isEmpty ? 0.0 : taken / _reminders.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.accentGreen, onPressed: _add, child: const Icon(Icons.add_alarm_rounded, color: Colors.white)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Today's adherence · $taken/${_reminders.length} taken", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: TweenAnimationBuilder<double>(tween: Tween(end: progress), duration: const Duration(milliseconds: 600), builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)))),
          ]),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        for (var i = 0; i < _reminders.length; i++)
          Builder(builder: (_) {
            final r = _reminders[i];
            final due = !r.taken && (r.time.hour * 60 + r.time.minute) <= (now.hour * 60 + now.minute);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: due ? Border.all(color: AppColors.moderate, width: 1.5) : null, boxShadow: AppShadows.card3d),
              child: Row(children: [
                Icon3D(icon: Icons.medication_rounded, color: AppColors.primaryBlue, size: 44),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name, style: TextStyle(fontWeight: FontWeight.w700, decoration: r.taken ? TextDecoration.lineThrough : null)),
                  Text('${r.time.format(context)} · ${r.dose}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                ])),
                if (due) Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.moderate.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Text('DUE', style: TextStyle(color: AppColors.moderate, fontSize: 10.5, fontWeight: FontWeight.w800))),
                IconButton(icon: Icon(r.taken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: r.taken ? AppColors.mild : AppColors.textMuted), onPressed: () => setState(() => r.taken = !r.taken)),
              ]),
            ).animate().fadeIn(delay: (i * 70).ms).slideX(begin: 0.05, end: 0);
          }),
      ]),
    );
  }
}
