import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'profile_setup_screen.dart';
import 'challan_screen.dart';
import 'parking_history_screen.dart';
import 'offers_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out?', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: AppTheme.text1)),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.dmSans(color: AppTheme.text2, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppTheme.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Log Out', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: AppTheme.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<AppState>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    final menuSections = [
      _Section(title: 'Parking', items: [
        _MenuItem(icon: Icons.bookmark_border_rounded, label: 'My Bookings', screen: null),
        _MenuItem(icon: Icons.history_rounded, label: 'Parking History', screen: const ParkingHistoryScreen()),
        _MenuItem(icon: Icons.description_outlined, label: 'Challan Check', screen: const ChallanScreen()),
      ]),
      _Section(title: 'Account', items: [
        _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Wallet & Payments', screen: null),
        _MenuItem(icon: Icons.sell_rounded, label: 'Offers & Deals', screen: const OffersScreen()),
        _MenuItem(icon: Icons.card_giftcard_rounded, label: 'Refer & Earn', sub: 'Get ₹50', screen: null),
        _MenuItem(icon: Icons.star_outline_rounded, label: 'My Rewards', screen: null),
        _MenuItem(icon: Icons.monetization_on_outlined, label: 'ParkinToday Credits', screen: null),
      ]),
      _Section(title: 'Support', items: [
        _MenuItem(icon: Icons.shield_outlined, label: 'Safety', screen: null),
        _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', screen: null),
        _MenuItem(icon: Icons.description_outlined, label: 'Claims', screen: null),
        _MenuItem(icon: Icons.settings_outlined, label: 'Settings', screen: null),
      ]),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.card,
            elevation: 0, pinned: true, floating: true, expandedHeight: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: Text('Profile', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1)),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  color: AppTheme.card,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentLight, width: 3),
                      ),
                      child: Center(child: Text(
                        (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user?.name ?? 'User', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                      const SizedBox(height: 2),
                      Text('+91 ${user?.phone ?? ''}', style: GoogleFonts.dmSans(fontSize: 13.5, color: AppTheme.text2)),
                    ])),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.text3),
                  ]),
                ),

                const SizedBox(height: 12),

                // Vehicles
                _VehiclesSection(user: user),
                const SizedBox(height: 12),

                // Earn banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.accentGlowDecoration(),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Earn with ParkInToday', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('List your parking space & earn passive income.', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.65), height: 1.4)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                          child: Text('Get Started', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ])),
                      const SizedBox(width: 12),
                      const Icon(Icons.business_rounded, color: AppTheme.accent, size: 44),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Menu sections
                ...menuSections.map((sec) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                      child: Text(sec.title.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.text3, letterSpacing: 1)),
                    ),
                    Container(
                      color: AppTheme.card,
                      child: Column(
                        children: List.generate(sec.items.length, (i) {
                          final item = sec.items[i];
                          return Column(
                            children: [
                              InkWell(
                                onTap: item.screen != null
                                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen!))
                                    : () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  child: Row(children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
                                      child: Icon(item.icon, size: 19, color: AppTheme.text2),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(item.label, style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppTheme.text1)),
                                      if (item.sub != null) Text(item.sub!, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w700)),
                                    ])),
                                    const Icon(Icons.chevron_right_rounded, color: AppTheme.text3, size: 20),
                                  ]),
                                ),
                              ),
                              if (i < sec.items.length - 1)
                                Divider(height: 1, indent: 70, color: AppTheme.bg),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                )),

                // Logout
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _confirmLogout(context),
                  child: Container(
                    color: AppTheme.card,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.logout_rounded, size: 19, color: AppTheme.red),
                      ),
                      const SizedBox(width: 14),
                      Text('Log Out', style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.red)),
                    ]),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiclesSection extends StatelessWidget {
  final UserProfile? user;
  const _VehiclesSection({this.user});

  @override
  Widget build(BuildContext context) {
    final vehicles = user?.vehicles ?? [];
    return Container(
      color: AppTheme.card,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('My Vehicles', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            const Spacer(),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (_) => const AddVehicleSheet(),
              ),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          if (vehicles.isEmpty)
            Center(child: Text('No vehicles added', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3)))
          else
            ...vehicles.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bg, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: v.isDefault ? AppTheme.accent : Colors.transparent, width: 1.5),
                ),
                child: Row(children: [
                  Text(v.type.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.model, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                    const SizedBox(height: 2),
                    Text(v.plate, style: GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text2, letterSpacing: 1.5)),
                    if (v.rcImagePath != null && v.rcImagePath!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.verified_rounded, size: 13, color: AppTheme.accent),
                        const SizedBox(width: 4),
                        Text('RC uploaded', style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                      ]),
                    ],
                  ])),
                  if (v.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
                      child: Text('Default', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                    )
                  else
                    GestureDetector(
                      onTap: () => context.read<AppState>().setDefaultVehicle(v.id),
                      child: Text('Set default', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text3)),
                    ),
                ]),
              ),
            )),
        ],
      ),
    );
  }
}

class _Section { final String title; final List<_MenuItem> items; const _Section({required this.title, required this.items}); }
class _MenuItem { final IconData icon; final String label; final String? sub; final Widget? screen; const _MenuItem({required this.icon, required this.label, this.sub, this.screen}); }
