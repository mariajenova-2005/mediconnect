import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'find_parking_screen.dart';
import 'ev_charging_screen.dart';
import 'challan_screen.dart';
import 'parking_history_screen.dart';
import 'valet_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'main_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _goto(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: AppTheme.card,
            elevation: 0,
            floating: true,
            pinned: true,
            expandedHeight: 0,
            titleSpacing: 20,
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text('P', style: GoogleFonts.dmSans(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white))),
              ),
              const SizedBox(width: 8),
              RichText(text: TextSpan(children: [
                TextSpan(text: 'ParkIn', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                TextSpan(text: 'Today', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accent)),
              ])),
            ]),
            actions: [
              GestureDetector(
                onTap: () => _goto(const ProfileScreen()),
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentLight, width: 2),
                  ),
                  child: Center(child: Text(
                    (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  )),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Greeting + Location ──
                Container(
                  color: AppTheme.card,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      '$greeting, ${user?.name.split(' ').first ?? 'there'} 👋',
                      style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppTheme.text2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Where are you parking today?',
                      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.text1),
                    ),
                    const SizedBox(height: 14),
                    // Location bar
                    InkWell(
                      onTap: () => _goto(const FindParkingScreen()),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border, width: 1.5),
                        ),
                        child: Row(children: [
                          const Icon(Icons.search_rounded, color: AppTheme.text3, size: 20),
                          const SizedBox(width: 10),
                          Text('Search location or area…', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text3)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.my_location_rounded, color: AppTheme.accent, size: 12),
                              const SizedBox(width: 4),
                              Text('Near me', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Primary Services ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text('Services', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(child: _PrimaryCard(
                      icon: Icons.local_parking_rounded,
                      label: 'Find Parking',
                      sub: 'Spots nearby',
                      color: AppTheme.parkingFg,
                      bg: AppTheme.parkingBg,
                      onTap: () => _goto(const FindParkingScreen()),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _PrimaryCard(
                      icon: Icons.ev_station_rounded,
                      label: 'EV Charging',
                      sub: 'Fast chargers',
                      color: AppTheme.evFg,
                      bg: AppTheme.evBg,
                      onTap: () => _goto(const EVChargingScreen()),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(child: _PrimaryCard(
                      icon: Icons.local_taxi_rounded,
                      label: 'Valet Service',
                      sub: 'Hand-free park',
                      color: AppTheme.valetFg,
                      bg: AppTheme.valetBg,
                      onTap: () => _goto(const ValetScreen()),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _PrimaryCard(
                      icon: Icons.sell_rounded,
                      label: 'Offers & Deals',
                      sub: 'Save more',
                      color: AppTheme.offersFg,
                      bg: AppTheme.offersBg,
                      onTap: () => _goto(const OffersScreen()),
                    )),
                  ]),
                ),

                const SizedBox(height: 20),

                // ── Quick Actions Row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('Quick Actions', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _QuickAction(icon: Icons.description_outlined, label: 'Challan\nCheck', color: AppTheme.challanFg, bg: AppTheme.challanBg, onTap: () => _goto(const ChallanScreen())),
                      _QuickAction(icon: Icons.history_rounded, label: 'Parking\nHistory', color: AppTheme.historyFg, bg: AppTheme.historyBg, onTap: () => _goto(const ParkingHistoryScreen())),
                      _QuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Wallet\n& Credits', color: AppTheme.bookFg, bg: AppTheme.bookBg, onTap: () {}),
                      _QuickAction(icon: Icons.card_giftcard_rounded, label: 'Refer\n& Earn', color: const Color(0xFF7B1FA2), bg: const Color(0xFFF3E5F5), onTap: () {}),
                      _QuickAction(icon: Icons.star_outline_rounded, label: 'My\nRewards', color: const Color(0xFFE65100), bg: const Color(0xFFFFF3E0), onTap: () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Active Vehicle ──
                if (user?.defaultVehicle != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text('Your Vehicle', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ActiveVehicleCard(vehicle: user!.defaultVehicle!),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Promo Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _goto(const OffersScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A1628), Color(0xFF142236)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppTheme.navy.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text('LIMITED TIME', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.accent, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 8),
                          Text('Get 30% off your first booking!', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Use code PARK30 at checkout', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                            child: Text('Claim Offer', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ])),
                        const SizedBox(width: 16),
                        Icon(Icons.local_offer_rounded, color: AppTheme.accent, size: 52),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Recent Activity ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(children: [
                    Text('Recent Activity', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _goto(const ParkingHistoryScreen()),
                      child: Text('See all', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                    ),
                  ]),
                ),
                ..._recentItems.map((r) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _RecentCard(item: r),
                )),

                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Sub-widgets ──

class _PrimaryCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color, bg;
  final VoidCallback onTap;
  const _PrimaryCard({required this.icon, required this.label, required this.sub, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 12),
        Text(label, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        const SizedBox(height: 2),
        Text(sub, style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(children: [
          Text('Explore', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 13, color: color),
        ]),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 80, margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: AppTheme.cardDecoration(radius: 14),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(height: 7),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.text1, height: 1.3)),
      ]),
    ),
  );
}

class _ActiveVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _ActiveVehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: AppTheme.cardDecoration(),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(color: AppTheme.parkingBg, borderRadius: BorderRadius.circular(13)),
        child: Center(child: Text(vehicle.type.emoji, style: const TextStyle(fontSize: 24))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(vehicle.model, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1)),
        const SizedBox(height: 2),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(6)),
            child: Text(vehicle.plate, style: GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text2, letterSpacing: 1.5)),
          ),
          const SizedBox(width: 8),
          Text(vehicle.type.label, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3)),
        ]),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
        child: Text('Default', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
      ),
    ]),
  );
}

class _RecentCard extends StatelessWidget {
  final Map<String, String> item;
  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: AppTheme.cardDecoration(radius: 14),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: item['type'] == 'ev' ? AppTheme.evBg : AppTheme.parkingBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          item['type'] == 'ev' ? Icons.ev_station_rounded : Icons.local_parking_rounded,
          color: item['type'] == 'ev' ? AppTheme.evFg : AppTheme.parkingFg,
          size: 20,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item['name']!, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
        const SizedBox(height: 2),
        Text(item['sub']!, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(item['amount']!, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        const SizedBox(height: 2),
        Text(item['date']!, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
      ]),
    ]),
  );
}

const List<Map<String, String>> _recentItems = [
  {'type': 'parking', 'name': 'City Square Parking', 'sub': 'Slot A-12 · 2h 30m', 'amount': '₹50', 'date': 'Today'},
  {'type': 'ev', 'name': 'Tata Power EZ Charge', 'sub': '15.4 kWh charged', 'amount': '₹277', 'date': 'Yesterday'},
  {'type': 'parking', 'name': 'Park Avenue Basement', 'sub': 'Slot C-05 · 3h 00m', 'amount': '₹90', 'date': '20 Jun'},
];
