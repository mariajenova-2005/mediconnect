import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class ValetScreen extends StatefulWidget {
  const ValetScreen({super.key});
  @override
  State<ValetScreen> createState() => _ValetScreenState();
}

class _ValetScreenState extends State<ValetScreen> {
  int _selectedZone = 0;
  int _step = 0; // 0=browse, 1=confirm, 2=success

  static const _zones = [
    _ValetZone(name: 'MG Road Hub', area: 'MG Road, Bengaluru', price: 149, eta: '5 min', available: true),
    _ValetZone(name: 'Brigade Point', area: 'Brigade Road, Bengaluru', price: 129, eta: '8 min', available: true),
    _ValetZone(name: 'Indiranagar Drop', area: 'Indiranagar, Bengaluru', price: 99, eta: '12 min', available: false),
    _ValetZone(name: 'Koramangala Valet', area: 'Koramangala, Bengaluru', price: 119, eta: '10 min', available: true),
  ];

  static const _features = [
    _Feature(icon: Icons.security_rounded, title: 'Insured Parking', sub: 'Your car is covered'),
    _Feature(icon: Icons.speed_rounded, title: 'Quick Retrieval', sub: 'Car back in 5 mins'),
    _Feature(icon: Icons.verified_user_rounded, title: 'Vetted Drivers', sub: 'Background checked'),
    _Feature(icon: Icons.receipt_long_rounded, title: 'Digital Receipt', sub: 'Instant on email'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_step == 2) return _buildSuccess(context);
    if (_step == 1) return _buildConfirm(context);
    return _buildBrowse(context);
  }

  Widget _buildBrowse(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        Container(
          color: AppTheme.valetFg,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 18),
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Valet Service', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Hand-free, hassle-free parking', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.75))),
            ])),
          ]),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.accentGlowDecoration(),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Drive Up & Walk Away', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Our trained valets park and retrieve your car. No hunting for spots.', style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white.withOpacity(0.65), height: 1.5)),
                  ])),
                  const SizedBox(width: 14),
                  const Icon(Icons.local_taxi_rounded, color: AppTheme.valetFg, size: 52),
                ]),
              ),
              const SizedBox(height: 16),

              // Feature grid
              Row(children: List.generate(2, (col) => Expanded(child: Column(
                children: List.generate(2, (row) {
                  final f = _features[col * 2 + row];
                  return Padding(
                    padding: EdgeInsets.only(left: col == 1 ? 6 : 0, right: col == 0 ? 6 : 0, bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: AppTheme.cardDecoration(radius: 14),
                      child: Row(children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(color: AppTheme.valetBg, borderRadius: BorderRadius.circular(9)),
                          child: Icon(f.icon, color: AppTheme.valetFg, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f.title, style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                          Text(f.sub, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text2)),
                        ])),
                      ]),
                    ),
                  );
                }),
              )))),

              Text('Choose a Valet Zone', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.text1)),
              const SizedBox(height: 12),

              ..._zones.asMap().entries.map((e) {
                final i = e.key; final z = e.value;
                final sel = _selectedZone == i;
                return GestureDetector(
                  onTap: z.available ? () => setState(() => _selectedZone = i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: z.available ? AppTheme.card : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? AppTheme.valetFg : Colors.transparent, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: z.available ? AppTheme.valetBg : AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_taxi_rounded, color: z.available ? AppTheme.valetFg : AppTheme.text3, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(z.name, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: z.available ? AppTheme.text1 : AppTheme.text3)),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.text3),
                          const SizedBox(width: 3),
                          Expanded(child: Text(z.area, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text2), overflow: TextOverflow.ellipsis)),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₹${z.price}', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: z.available ? AppTheme.text1 : AppTheme.text3)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: z.available ? const Color(0xFFDCFCE7) : AppTheme.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            z.available ? z.eta : 'Unavailable',
                            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: z.available ? AppTheme.green : AppTheme.text3),
                          ),
                        ),
                      ]),
                      if (sel) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: AppTheme.valetFg, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        ),
                      ],
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _zones[_selectedZone].available ? () => setState(() => _step = 1) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.valetFg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Book Valet — ₹${_zones[_selectedZone].price}', style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildConfirm(BuildContext context) {
    final zone = _zones[_selectedZone];
    final vehicle = context.read<AppState>().user?.defaultVehicle;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        Container(
          color: AppTheme.valetFg,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 18),
          child: Row(children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text('Confirm Booking', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Valet Zone', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(zone.name, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                  Text(zone.area, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 14),

                  if (vehicle != null) ...[
                    Text('Vehicle', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3, fontWeight: FontWeight.w700)),
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
                    const Divider(),
                    const SizedBox(height: 14),
                  ],

                  _SummaryRow(label: 'Valet service', value: '₹${zone.price}'),
                  _SummaryRow(label: 'ETA', value: zone.eta),
                  _SummaryRow(label: 'Driver arrives', value: 'Within ${zone.eta}'),
                  const Divider(height: 20),
                  _SummaryRow(label: 'Total', value: '₹${zone.price}', bold: true),
                ]),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.offersFg, size: 17),
                  const SizedBox(width: 8),
                  Expanded(child: Text('A trained valet driver will arrive at your location and park your vehicle safely.', style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF92400E), height: 1.4))),
                ]),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 2),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.valetFg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('Confirm Valet Booking', style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final zone = _zones[_selectedZone];
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppTheme.valetBg, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.valetFg.withOpacity(0.2), blurRadius: 24)]),
              child: const Icon(Icons.local_taxi_rounded, color: AppTheme.valetFg, size: 38),
            ),
            const SizedBox(height: 20),
            Text('Valet Booked!', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.text1)),
            const SizedBox(height: 8),
            Text('Your valet driver is on the way', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2)),
            const SizedBox(height: 28),

            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(children: [
                _SummaryRow(label: 'Zone', value: zone.name),
                _SummaryRow(label: 'Driver ETA', value: zone.eta),
                _SummaryRow(label: 'Total Paid', value: '₹${zone.price}', bold: true),
                _SummaryRow(label: 'Booking ID', value: 'VL${DateTime.now().millisecondsSinceEpoch % 100000}'),
              ]),
            ),
            const SizedBox(height: 24),

            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () { setState(() => _step = 0); Navigator.pop(context); },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Done', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text2)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.valetFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Track Driver', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: AppTheme.text1)),
    ]),
  );
}

class _ValetZone {
  final String name, area, eta;
  final int price;
  final bool available;
  const _ValetZone({required this.name, required this.area, required this.price, required this.eta, required this.available});
}

class _Feature {
  final IconData icon;
  final String title, sub;
  const _Feature({required this.icon, required this.title, required this.sub});
}
