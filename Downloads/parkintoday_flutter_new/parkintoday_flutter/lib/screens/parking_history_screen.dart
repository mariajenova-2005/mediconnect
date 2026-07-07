import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ParkingHistoryScreen extends StatefulWidget {
  const ParkingHistoryScreen({super.key});
  @override
  State<ParkingHistoryScreen> createState() => _ParkingHistoryScreenState();
}

class _ParkingHistoryScreenState extends State<ParkingHistoryScreen> {
  String _filter = 'All';
  int? _expanded;

  static const _sessions = [
    _Session(id: 'BK0012', spot: 'City Square Parking', location: 'MG Road, Bengaluru', date: 'Today', entry: '09:15 AM', exit: '11:45 AM', duration: '2h 30m', amount: 50, vehicle: 'TN09CD1234'),
    _Session(id: 'BK0011', spot: 'Park Avenue Basement', location: 'Brigade Road, Bengaluru', date: 'Yesterday', entry: '02:00 PM', exit: '05:30 PM', duration: '3h 30m', amount: 105, vehicle: 'TN09CD1234'),
    _Session(id: 'BK0010', spot: 'Metro Hub Parking', location: 'Shivaji Nagar, Bengaluru', date: '20 Jun', entry: '10:00 AM', exit: '12:00 PM', duration: '2h 00m', amount: 30, vehicle: 'TN09CD1234'),
    _Session(id: 'BK0009', spot: 'Green Mall Parking', location: 'Koramangala, Bengaluru', date: '18 Jun', entry: '04:00 PM', exit: '06:15 PM', duration: '2h 15m', amount: 56, vehicle: 'TN09CD1234'),
    _Session(id: 'BK0008', spot: 'Tech Park Lot B', location: 'Whitefield, Bengaluru', date: '15 Jun', entry: '08:30 AM', exit: '06:30 PM', duration: '10h 00m', amount: 400, vehicle: 'TN09CD1234'),
  ];

  static const _stats = [
    _Stat(label: 'Total Trips', value: '28', icon: Icons.repeat_rounded, color: AppTheme.historyFg, bg: AppTheme.historyBg),
    _Stat(label: 'Total Spent', value: '₹1,240', icon: Icons.account_balance_wallet_outlined, color: AppTheme.green, bg: Color(0xFFDCFCE7)),
    _Stat(label: 'Hours Parked', value: '84h', icon: Icons.schedule_rounded, color: AppTheme.accent, bg: AppTheme.accentLight),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        // Header
        Container(
          color: AppTheme.historyFg,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16, bottom: 18,
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Parking History', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
            const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
          ]),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats row
              Row(
                children: _stats.map((s) => Expanded(child: Padding(
                  padding: EdgeInsets.only(right: s != _stats.last ? 10 : 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      Icon(s.icon, color: s.color, size: 20),
                      const SizedBox(height: 6),
                      Text(s.value, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: s.color)),
                      const SizedBox(height: 2),
                      Text(s.label, textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.text2, height: 1.2)),
                    ]),
                  ),
                ))).toList(),
              ),
              const SizedBox(height: 14),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'This Week', 'This Month', 'Last Month'].map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _filter == f ? AppTheme.historyFg : AppTheme.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _filter == f ? AppTheme.historyFg : AppTheme.border, width: 1.5),
                        ),
                        child: Text(f, style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _filter == f ? Colors.white : AppTheme.text2)),
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 14),

              Text('${_sessions.length} Sessions', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3)),
              const SizedBox(height: 10),

              // Sessions
              ..._sessions.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final open = _expanded == i;
                return GestureDetector(
                  onTap: () => setState(() => _expanded = open ? null : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.cardDecoration(radius: 16),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppTheme.historyBg, borderRadius: BorderRadius.circular(11)),
                          child: const Icon(Icons.location_on_rounded, color: AppTheme.historyFg, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.spot, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                          Text(s.location, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('₹${s.amount}', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                          Text(s.date, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
                        ]),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.text3),
                            const SizedBox(width: 4),
                            Text('${s.entry} – ${s.exit}', style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2)),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.historyBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(s.duration, style: GoogleFonts.dmSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.historyFg)),
                        ),
                        const Spacer(),
                        Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppTheme.text3, size: 20),
                      ]),

                      if (open) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Booking ID', value: s.id),
                        _DetailRow(label: 'Vehicle', value: s.vehicle),
                        _DetailRow(label: 'Status', value: 'Completed', valueColor: AppTheme.green),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(color: AppTheme.historyBg, borderRadius: BorderRadius.circular(10)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.receipt_long_rounded, size: 15, color: AppTheme.historyFg),
                              const SizedBox(width: 6),
                              Text('Download Receipt', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.historyFg)),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text3)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.text1)),
    ]),
  );
}

class _Session {
  final String id, spot, location, date, entry, exit, duration, vehicle;
  final int amount;
  const _Session({required this.id, required this.spot, required this.location, required this.date, required this.entry, required this.exit, required this.duration, required this.amount, required this.vehicle});
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _Stat({required this.label, required this.value, required this.icon, required this.color, required this.bg});
}
