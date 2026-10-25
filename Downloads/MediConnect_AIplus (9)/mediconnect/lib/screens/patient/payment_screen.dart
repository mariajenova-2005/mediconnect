import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/payment_service.dart';
import '../../services/appointment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime dateTime;
  final String slot;
  const PaymentScreen({super.key, required this.doctor, required this.dateTime, required this.slot});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'UPI';
  bool _processing = false;
  // TODO: put your clinic's real UPI ID here (payments go straight to it — no gateway involved)
  static const clinicUpi = 'yourclinic@upi';

  DateTime _when() {
    final m = RegExp(r'(\d+):(\d+) (AM|PM)').firstMatch(widget.slot);
    if (m == null) return widget.dateTime;
    var h = int.parse(m[1]!) % 12;
    if (m[3] == 'PM') h += 12;
    final d = widget.dateTime;
    return DateTime(d.year, d.month, d.day, h, int.parse(m[2]!));
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    if (_method == 'UPI') {
      try {
        await launchUrl(Uri.parse('upi://pay?pa=$clinicUpi&pn=MediConnect&am=${widget.doctor.fee}&cu=INR'), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    await PaymentService.instance.pay(amount: widget.doctor.fee, method: _method);
    AppointmentService.instance.book(doctorName: widget.doctor.name, specialty: widget.doctor.specialty, dateTime: _when(), fee: widget.doctor.fee, doctorId: widget.doctor.id);
    setState(() => _processing = false);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 56).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 14),
            const Text('Appointment Confirmed!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 6),
            Text('${widget.doctor.name} · ${widget.slot}', style: const TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consultation Fee', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('₹${widget.doctor.fee.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('${widget.doctor.name} · ${widget.slot}', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 24),
            const Text('Choose Payment Method', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _MethodTile(label: 'UPI (opens your UPI app)', icon: Icons.account_balance_wallet_rounded, selected: _method == 'UPI', onTap: () => setState(() => _method = 'UPI')),
            const SizedBox(height: 10),
            _MethodTile(label: 'Pay at Clinic (cash / card)', icon: Icons.storefront_rounded, selected: _method == 'Clinic', onTap: () => setState(() => _method = 'Clinic')),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _pay,
                child: _processing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_method == 'UPI' ? 'Pay ₹${widget.doctor.fee.toInt()} via UPI' : 'Confirm booking · pay at clinic'),
              ),
            ),
            const SizedBox(height: 6),
            const Text('The clinic confirms your payment. UPI opens your own UPI app.', style: TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.accentGreen : Colors.black12, width: selected ? 1.6 : 1)),
        child: Row(children: [
          Icon(icon, color: selected ? AppColors.accentGreen : AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Radio<bool>(value: true, groupValue: selected ? true : null, onChanged: (_) => onTap(), activeColor: AppColors.accentGreen),
        ]),
      ),
    );
  }
}
