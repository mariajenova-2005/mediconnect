import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/parking_models.dart';
import '../theme/app_theme.dart';

class EVChargingScreen extends StatefulWidget {
  const EVChargingScreen({super.key});
  @override
  State<EVChargingScreen> createState() => _EVChargingScreenState();
}

class _EVChargingScreenState extends State<EVChargingScreen> {
  EVStation? _selected;
  String _filter = 'All';

  List<EVStation> get _filtered {
    if (_filter == 'DC Fast') return mockEVStations.where((s) => s.chargerType.contains('DC')).toList();
    if (_filter == 'AC') return mockEVStations.where((s) => s.chargerType.contains('AC')).toList();
    if (_filter == 'Available') return mockEVStations.where((s) => s.available > 0).toList();
    return mockEVStations;
  }

  Color _sc(SpotStatus s) {
    switch (s) {
      case SpotStatus.available: return AppTheme.green;
      case SpotStatus.limited: return AppTheme.amber;
      case SpotStatus.full: return AppTheme.red;
    }
  }

  String _sl(SpotStatus s) {
    switch (s) {
      case SpotStatus.available: return 'Available';
      case SpotStatus.limited: return 'Limited';
      case SpotStatus.full: return 'Full';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        // Header
        Container(
          color: AppTheme.card,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16, bottom: 16,
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.text1, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text('EV Charging', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppTheme.evBg, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bolt_rounded, size: 14, color: AppTheme.evFg),
                const SizedBox(width: 4),
                Text('${mockEVStations.where((s) => s.available > 0).length} active', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.evFg)),
              ]),
            ),
          ]),
        ),

        // Map placeholder
        Container(
          height: 200,
          color: const Color(0xFFE3F2FD),
          child: Stack(children: [
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.ev_station_rounded, size: 48, color: AppTheme.evFg.withOpacity(0.4)),
              const SizedBox(height: 8),
              Text('EV Station Map', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.evFg.withOpacity(0.6), fontWeight: FontWeight.w600)),
            ])),
            ...List.generate(4, (i) {
              final positions = [
                const Offset(0.2, 0.3), const Offset(0.55, 0.2),
                const Offset(0.4, 0.65), const Offset(0.75, 0.5),
              ];
              final s = mockEVStations[i];
              return Positioned(
                left: positions[i].dx * (MediaQuery.of(context).size.width - 32),
                top: positions[i].dy * 180,
                child: GestureDetector(
                  onTap: () => setState(() => _selected = _selected == s ? null : s),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _selected == s ? AppTheme.evFg : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                    ),
                    child: Icon(Icons.bolt_rounded, size: 16, color: _selected == s ? Colors.white : AppTheme.evFg),
                  ),
                ),
              );
            }),
          ]),
        ),

        // Filters
        Container(
          color: AppTheme.card,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'DC Fast', 'AC', 'Available'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == f ? AppTheme.evFg : AppTheme.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _filter == f ? AppTheme.evFg : AppTheme.border, width: 1.5),
                    ),
                    child: Text(f, style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700,
                        color: _filter == f ? Colors.white : AppTheme.text2)),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),

        // Stations list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final s = _filtered[i];
              return GestureDetector(
                onTap: () => setState(() => _selected = _selected == s ? null : s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selected == s ? AppTheme.evFg : Colors.transparent, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppTheme.evBg, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.ev_station_rounded, color: AppTheme.evFg, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.name, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                        const SizedBox(height: 2),
                        Text(s.address, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(s.pricePerKwh, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _sc(s.status).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(_sl(s.status), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: _sc(s.status))),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      _EVTag(icon: Icons.directions_walk_rounded, label: s.distance),
                      const SizedBox(width: 10),
                      _EVTag(icon: Icons.bolt_rounded, label: s.power),
                      const SizedBox(width: 10),
                      _EVTag(icon: Icons.cable_rounded, label: s.connector),
                      const Spacer(),
                      if (s.available > 0)
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (_) => _EVBookingSheet(station: s),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: AppTheme.evFg, borderRadius: BorderRadius.circular(10)),
                            child: Text('Reserve', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _EVTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EVTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 12, color: AppTheme.text3),
    const SizedBox(width: 3),
    Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text2)),
  ]);
}

// ── EV Booking Sheet ──
class _EVBookingSheet extends StatefulWidget {
  final EVStation station;
  const _EVBookingSheet({required this.station});
  @override
  State<_EVBookingSheet> createState() => _EVBookingSheetState();
}

class _EVBookingSheetState extends State<_EVBookingSheet> {
  int _kwh = 20;
  int _step = 0;

  double get _total => _kwh * (double.tryParse(widget.station.pricePerKwh.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0);

  @override
  Widget build(BuildContext context) {
    if (_step == 1) return _EVSuccessView(station: widget.station, kwh: _kwh, total: _total);

    final vehicle = context.read<AppState>().user?.defaultVehicle;

    return Container(
      decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Text(widget.station.name, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        Text(widget.station.address, style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text2)),
        const SizedBox(height: 16),
        Row(children: [
          _InfoChip(icon: Icons.bolt_rounded, label: widget.station.power, color: AppTheme.evFg),
          const SizedBox(width: 8),
          _InfoChip(icon: Icons.cable_rounded, label: widget.station.connector, color: AppTheme.evFg),
          const SizedBox(width: 8),
          _InfoChip(icon: Icons.bolt_outlined, label: widget.station.pricePerKwh, color: AppTheme.green),
        ]),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 14),

        if (vehicle != null) ...[
          Text('Vehicle', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text3)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Text(vehicle.type.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(vehicle.model, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
              const Spacer(),
              Text(vehicle.plate, style: GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text2, letterSpacing: 1.5)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        Text('Units (kWh)', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text3)),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(
            onTap: () { if (_kwh > 5) setState(() => _kwh -= 5); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
              child: const Icon(Icons.remove, size: 18, color: AppTheme.text1),
            ),
          ),
          Expanded(child: Center(child: Column(children: [
            Text('$_kwh kWh', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            Text('≈ ${(_kwh * 5).toStringAsFixed(0)} km range', style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
          ]))),
          GestureDetector(
            onTap: () { if (_kwh < 80) setState(() => _kwh += 5); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppTheme.evFg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3)),
            Text('₹${_total.toStringAsFixed(0)}', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.text1)),
          ]),
          const Spacer(),
          SizedBox(
            width: 160, height: 50,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.evFg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Reserve Slot', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _EVSuccessView extends StatelessWidget {
  final EVStation station; final int kwh; final double total;
  const _EVSuccessView({required this.station, required this.kwh, required this.total});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppTheme.evBg, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.evFg.withOpacity(0.2), blurRadius: 20)]),
        child: Icon(Icons.ev_station_rounded, color: AppTheme.evFg, size: 34),
      ),
      const SizedBox(height: 16),
      Text('Slot Reserved!', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.text1)),
      const SizedBox(height: 6),
      Text('Your EV charging slot is confirmed', style: GoogleFonts.dmSans(fontSize: 13.5, color: AppTheme.text2)),
      const SizedBox(height: 24),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _Row('Station', station.name),
          _Row('Connector', station.connector),
          _Row('Energy', '$kwh kWh'),
          _Row('Charger', station.chargerType),
          _Row('Total Paid', '₹${total.toStringAsFixed(0)}', bold: true),
          _Row('Session ID', 'EV${DateTime.now().millisecondsSinceEpoch % 100000}'),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.border, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text('Done', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text2)),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.evFg, padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Navigate', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        )),
      ]),
    ]),
  );

  Widget _Row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text3)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: AppTheme.text1)),
    ]),
  );
}
