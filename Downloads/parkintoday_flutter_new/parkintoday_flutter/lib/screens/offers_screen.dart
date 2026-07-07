import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _copiedCode;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  static const _offers = [
    _Offer(code: 'PARK30', title: '30% Off First Booking', sub: 'Valid on all parking slots', expiry: 'Expires 31 Jul 2024', color: AppTheme.accent, icon: Icons.local_parking_rounded, bg: AppTheme.accentLight),
    _Offer(code: 'EV20', title: '₹20 Off EV Charging', sub: 'Minimum ₹100 session', expiry: 'Expires 15 Aug 2024', color: AppTheme.evFg, icon: Icons.ev_station_rounded, bg: AppTheme.evBg),
    _Offer(code: 'WEEKEND25', title: '25% Off Weekends', sub: 'Saturday & Sunday only', expiry: 'Expires every Sunday', color: AppTheme.offersFg, icon: Icons.wb_sunny_rounded, bg: AppTheme.offersBg),
    _Offer(code: 'VALET50', title: '₹50 Off Valet', sub: 'First valet service free', expiry: 'Expires 30 Jul 2024', color: AppTheme.valetFg, icon: Icons.local_taxi_rounded, bg: AppTheme.valetBg),
  ];

  static const _deals = [
    _Deal(title: 'Monthly Parking Pass', sub: 'Unlimited parking at any spot for 30 days', original: 1200, discounted: 799, tag: 'BEST VALUE'),
    _Deal(title: 'EV Charging Bundle', sub: '100 kWh pre-loaded at discounted rates', original: 2000, discounted: 1499, tag: 'POPULAR'),
    _Deal(title: 'Valet 5-Pack', sub: 'Five valet services at a flat rate', original: 750, discounted: 549, tag: 'SAVE ₹200'),
  ];

  static const _rewards = [
    _Reward(title: 'Bronze Member', points: 0, color: Color(0xFFCD7F32), icon: Icons.star_border_rounded),
    _Reward(title: 'Silver Member', points: 500, color: Color(0xFF9E9E9E), icon: Icons.star_half_rounded),
    _Reward(title: 'Gold Member', points: 1500, color: Color(0xFFFFC107), icon: Icons.star_rounded),
    _Reward(title: 'Platinum Member', points: 5000, color: Color(0xFF00BCD4), icon: Icons.workspace_premium_rounded),
  ];

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copiedCode = code);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Code "$code" copied!', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppTheme.text1,
    ));
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copiedCode = null); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        // Header
        Container(
          color: AppTheme.offersFg,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 0),
          child: Column(children: [
            Row(children: [
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
                Text('Offers & Deals', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Exclusive savings for you', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.75))),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text('240 pts', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            TabBar(
              controller: _tabs,
              labelStyle: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w600),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [Tab(text: 'Coupons'), Tab(text: 'Deals'), Tab(text: 'Rewards')],
            ),
          ]),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              // Coupons tab
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    child: Row(children: [
                      const Icon(Icons.discount_outlined, color: AppTheme.text2, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Enter promo code', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text3))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(color: AppTheme.offersFg, borderRadius: BorderRadius.circular(8)),
                        child: Text('Apply', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Available Coupons', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ..._offers.map((o) => _buildCoupon(o)),
                  const SizedBox(height: 60),
                ],
              ),

              // Deals tab
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.accentGlowDecoration(),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Refer & Save More', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Invite friends. Get ₹50 credit per referral.', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.65))),
                      ])),
                      const Icon(Icons.share_rounded, color: AppTheme.accent, size: 36),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Bundle Deals', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ..._deals.map((d) => _buildDeal(d)),
                  const SizedBox(height: 60),
                ],
              ),

              // Rewards tab
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(children: [
                      Text('Your Points', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('240', style: GoogleFonts.dmSans(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.text1)),
                      Text('ParkIn Credits', style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text2)),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: 240 / 500,
                        backgroundColor: AppTheme.bg,
                        color: AppTheme.accent,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Text('260 points to Silver tier', style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Membership Tiers', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ..._rewards.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration(radius: 14),
                    child: Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: r.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(r.icon, color: r.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.title, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                        Text('${r.points}+ points required', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
                      ])),
                      if (r.points <= 240)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                          child: Text('Active', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.green)),
                        ),
                    ]),
                  )),
                  const SizedBox(height: 60),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildCoupon(_Offer o) {
    final copied = _copiedCode == o.code;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: o.bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(o.icon, color: o.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.title, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.text1)),
              const SizedBox(height: 3),
              Text(o.sub, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
              const SizedBox(height: 3),
              Text(o.expiry, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
            ])),
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: o.color.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
          ),
          child: Row(children: [
            Text(o.code, style: GoogleFonts.spaceMono(fontSize: 15, fontWeight: FontWeight.w700, color: o.color, letterSpacing: 2)),
            const Spacer(),
            GestureDetector(
              onTap: () => _copyCode(o.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: copied ? AppTheme.green : o.color, borderRadius: BorderRadius.circular(8)),
                child: Text(copied ? 'Copied!' : 'Copy', style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDeal(_Deal d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (d.tag.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.offersBg, borderRadius: BorderRadius.circular(6)),
              child: Text(d.tag, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.offersFg, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 6),
          ],
          Text(d.title, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.text1)),
          const SizedBox(height: 3),
          Text(d.sub, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2, height: 1.4)),
          const SizedBox(height: 8),
          Row(children: [
            Text('₹${d.discounted}', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.text1)),
            const SizedBox(width: 8),
            Text('₹${d.original}', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3, decoration: TextDecoration.lineThrough)),
          ]),
        ])),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.offersFg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: Size.zero,
          ),
          child: Text('Buy', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _Offer {
  final String code, title, sub, expiry;
  final Color color, bg;
  final IconData icon;
  const _Offer({required this.code, required this.title, required this.sub, required this.expiry, required this.color, required this.bg, required this.icon});
}

class _Deal {
  final String title, sub, tag;
  final int original, discounted;
  const _Deal({required this.title, required this.sub, required this.original, required this.discounted, required this.tag});
}

class _Reward {
  final String title;
  final int points;
  final Color color;
  final IconData icon;
  const _Reward({required this.title, required this.points, required this.color, required this.icon});
}
