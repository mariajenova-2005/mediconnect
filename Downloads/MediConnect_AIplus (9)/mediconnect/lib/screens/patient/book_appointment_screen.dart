import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/appointment_service.dart';
import 'payment_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;
  const BookAppointmentScreen({super.key, required this.doctor});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final slots = AppointmentService.instance.getAvailableSlots(_selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
              child: Row(children: [
                Avatar3D(radius: 26, label: widget.doctor.name.split(' ').last[0]),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(widget.doctor.specialty, style: const TextStyle(color: AppColors.textMuted)),
                ])),
                Text('₹${widget.doctor.fee.toInt()}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final day = DateTime.now().add(Duration(days: i));
                  final selected = day.day == _selectedDay.day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      decoration: BoxDecoration(gradient: selected ? AppColors.heroGradient : null, color: selected ? null : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.card3d),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(['M','T','W','T','F','S','S'][day.weekday - 1], style: TextStyle(color: selected ? Colors.white70 : AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${day.day}', style: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 16)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((s) {
                final selected = s == _selectedSlot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: selected ? AppColors.accentGreen : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.accentGreen : Colors.black12)),
                    child: Text(s, style: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot == null ? null : () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(doctor: widget.doctor, dateTime: _selectedDay, slot: _selectedSlot!)));
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }
}
