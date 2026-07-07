import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'find_parking_screen.dart';
import 'ev_charging_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final idx = state.navIndex;

    final screens = [
      const DashboardScreen(),
      const FindParkingScreen(),
      const EVChargingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: idx, children: screens),
      bottomNavigationBar: _BottomNav(currentIndex: idx, onTap: state.setNavIndex),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
      _NavItem(icon: Icons.local_parking_rounded, label: 'Parking'),
      _NavItem(icon: Icons.ev_station_rounded, label: 'EV'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.accent.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(items[i].icon, size: 22, color: active ? AppTheme.accent : AppTheme.text3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          color: active ? AppTheme.accent : AppTheme.text3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
