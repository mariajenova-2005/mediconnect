import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/parking_models.dart';
import '../theme/app_theme.dart';

class FindParkingScreen extends StatefulWidget {
  const FindParkingScreen({super.key});
  @override
  State<FindParkingScreen> createState() => _FindParkingScreenState();
}

class _FindParkingScreenState extends State<FindParkingScreen> {
  ParkingSpot? _selected;
  String _filter = 'All';

  List<ParkingSpot> get _filtered {
    if (_filter == 'Available') return mockParkingSpots.where((s) => s.available > 0).toList();
    if (_filter == 'Covered') return mockParkingSpots.where((s) => s.type == SpotType.covered).toList();
    if (_filter == 'Open') return mockParkingSpots.where((s) => s.type == SpotType.open).toList();
    return mockParkingSpots;
  }

  Color _statusColor(SpotStatus s) {
    switch (s) {
      case SpotStatus.available: return AppTheme.green;
      case SpotStatus.limited: return AppTheme.amber;
      case SpotStatus.full: return AppTheme.red;
    }
  }

  String _statusLabel(SpotStatus s) {
    switch (s) {
      case SpotStatus.available: return 'Available';
      case SpotStatus.limited: return 'Limited';
      case SpotStatus.full: return 'Full';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNav = ModalRoute.of(context)?.settings.name == null;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          // Header
          Container(
            color: AppTheme.card,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16, right: 16, bottom: 16,
            ),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.text1, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Find Parking', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.my_location_rounded, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text('Near me', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              // Search bar
              Container(
                height: 48, padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppTheme.border, width: 1.5)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: AppTheme.text3, size: 18),
                  const SizedBox(width: 8),
                  Text('Search area, landmark…', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text3)),
                ]),
              ),
            ]),
          ),

          // Map placeholder
          Container(
            height: 220,
            color: const Color(0xFFD6E4EC),
            child: Stack(children: [
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.map_rounded, size: 48, color: Color(0xFF90A4AE)),
                const SizedBox(height: 8),
                Text('Map View', style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF90A4AE), fontWeight: FontWeight.w600)),
                Text('(Requires Google Maps API key)', style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFFB0BEC5))),
              ])),
              // Mock markers
              ...mockParkingSpots.take(4).map((s) {
                final positions = [
                  const Offset(0.25, 0.35), const Offset(0.6, 0.25),
                  const Offset(0.45, 0.65), const Offset(0.75, 0.55),
                ];
                final i = mockParkingSpots.indexOf(s);
                if (i >= 4) return const SizedBox.shrink();
                return Positioned(
                  left: positions[i].dx * (MediaQuery.of(context).size.width - 32),
                  top: positions[i].dy * 200,
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = _selected == s ? null : s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: _selected == s ? _statusColor(s.status) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text('P', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w900,
                        color: _selected == s ? Colors.white : _statusColor(s.status))),
                    ),
                  ),
                );
              }),
            ]),
          ),

          // Filter chips
          Container(
            color: AppTheme.card,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Available', 'Covered', 'Open'].map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _filter == f ? AppTheme.accent : AppTheme.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filter == f ? AppTheme.accent : AppTheme.border, width: 1.5),
                      ),
                      child: Text(f, style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: _filter == f ? Colors.white : AppTheme.text2)),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Spots list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _SpotCard(
                spot: _filtered[i],
                selected: _selected == _filtered[i],
                statusColor: _statusColor(_filtered[i].status),
                statusLabel: _statusLabel(_filtered[i].status),
                onTap: () => setState(() => _selected = _filtered[i]),
                onBook: () => _showBookingSheet(context, _filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext ctx, ParkingSpot spot) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(spot: spot),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final ParkingSpot spot;
  final bool selected;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap, onBook;
  const _SpotCard({required this.spot, required this.selected, required this.statusColor, required this.statusLabel, required this.onTap, required this.onBook});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppTheme.accent : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.parkingBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_parking_rounded, color: AppTheme.parkingFg, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(spot.name, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.text3),
              const SizedBox(width: 3),
              Text(spot.address, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(spot.pricePerHour, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _Tag(icon: Icons.directions_walk_rounded, label: spot.distance),
          const SizedBox(width: 10),
          _Tag(icon: spot.type == SpotType.covered ? Icons.garage_rounded : Icons.wb_sunny_rounded,
              label: spot.type == SpotType.covered ? 'Covered' : 'Open'),
          const SizedBox(width: 10),
          _Tag(icon: Icons.event_seat_rounded, label: '${spot.available}/${spot.total} free'),
          const Spacer(),
          if (spot.available > 0)
            GestureDetector(
              onTap: onBook,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                child: Text('Book', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
        ]),
      ]),
    ),
  );
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 12, color: AppTheme.text3),
    const SizedBox(width: 3),
    Text(label, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2)),
  ]);
}

// ── Booking Sheet ──
class _BookingSheet extends StatefulWidget {
  final ParkingSpot spot;
  const _BookingSheet({required this.spot});
  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _hours = 2;
  int _step = 0; // 0 = details, 1 = success

  double get _total => widget.spot.priceNum * _hours;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppState>().user;
    final vehicle = user?.defaultVehicle;

    if (_step == 1) return _SuccessView(spot: widget.spot, hours: _hours, total: _total);

    return Container(
      decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.spot.name, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            const SizedBox(height: 3),
            Text(widget.spot.address, style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text2)),
          ])),
          Text(widget.spot.pricePerHour, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.accent)),
        ]),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // Vehicle
        Text('Vehicle', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text3)),
        const SizedBox(height: 8),
        if (vehicle != null)
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

        // Duration
        Text('Duration', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text3)),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(
            onTap: () { if (_hours > 1) setState(() => _hours--); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
              child: const Icon(Icons.remove, size: 18, color: AppTheme.text1),
            ),
          ),
          Expanded(child: Center(child: Text(
            '$_hours hr${_hours > 1 ? 's' : ''}',
            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text1),
          ))),
          GestureDetector(
            onTap: () { if (_hours < 12) setState(() => _hours++); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
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
              child: Text('Confirm Booking', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Booking Success View ──
class _SuccessView extends StatelessWidget {
  final ParkingSpot spot;
  final int hours;
  final double total;
  const _SuccessView({required this.spot, required this.hours, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.green.withOpacity(0.2), blurRadius: 20)]),
          child: const Icon(Icons.check_rounded, color: AppTheme.green, size: 36),
        ),
        const SizedBox(height: 16),
        Text('Booking Confirmed!', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.text1)),
        const SizedBox(height: 6),
        Text('Your parking slot is reserved', style: GoogleFonts.dmSans(fontSize: 13.5, color: AppTheme.text2)),
        const SizedBox(height: 24),

        Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            _ConfRow(label: 'Location', value: spot.name),
            _ConfRow(label: 'Duration', value: '$hours hr${hours > 1 ? 's' : ''}'),
            _ConfRow(label: 'Slot', value: 'A-${(spot.id * 3) + 9}'),
            _ConfRow(label: 'Total Paid', value: '₹${total.toStringAsFixed(0)}', bold: true),
            _ConfRow(label: 'Booking ID', value: 'BK${DateTime.now().millisecondsSinceEpoch % 100000}'),
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Navigate', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          )),
        ]),
      ]),
    );
  }
}

class _ConfRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _ConfRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: AppTheme.text1)),
    ]),
  );
}
