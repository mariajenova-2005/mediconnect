import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChallanScreen extends StatefulWidget {
  const ChallanScreen({super.key});
  @override
  State<ChallanScreen> createState() => _ChallanScreenState();
}

class _ChallanScreenState extends State<ChallanScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  dynamic _result; // null | 'not_found' | List<_Challan>

  static final _db = {
    'MH12AB1234': [
      _Challan(id: 'CH2024001', offence: 'Signal Jumping', location: 'MG Road, Pune', date: '12 Jun 2024', amount: 500, paid: false),
      _Challan(id: 'CH2024002', offence: 'No Helmet', location: 'FC Road, Pune', date: '3 Mar 2024', amount: 1000, paid: true),
    ],
    'KA01MN5678': [
      _Challan(id: 'CH2024003', offence: 'No Parking Zone', location: 'Brigade Road, Bengaluru', date: '20 May 2024', amount: 250, paid: false),
    ],
    'TN09CD9999': <_Challan>[],
  };

  Future<void> _search() async {
    final key = _ctrl.text.trim().toUpperCase().replaceAll(' ', '');
    if (key.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = _db.containsKey(key) ? _db[key] : 'not_found';
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        Container(
          color: AppTheme.challanFg,
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
            Expanded(child: Text('Challan Check', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Search card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppTheme.challanBg, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.description_outlined, color: AppTheme.challanFg, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text('Check Traffic Challans',
                      style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your vehicle number to view pending & paid challans',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    style: GoogleFonts.spaceMono(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text1, letterSpacing: 3),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'MH12AB1234',
                      hintStyle: GoogleFonts.spaceMono(fontSize: 16, color: AppTheme.text3, letterSpacing: 2),
                    ),
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _ctrl.text.trim().isNotEmpty && !_loading ? _search : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.challanFg,
                        disabledBackgroundColor: AppTheme.challanFg.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Search Challans', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Try: MH12AB1234  or  KA01MN5678',
                      style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3)),
                ]),
              ),

              const SizedBox(height: 16),

              if (_loading) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppTheme.challanFg),
              ] else if (_result is List<_Challan>) ...[
                _buildResults(_result as List<_Challan>),
              ] else if (_result == 'not_found') ...[
                _buildNotFound(),
              ] else ...[
                _buildHowItWorks(),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildResults(List<_Challan> challans) {
    final unpaid = challans.where((c) => !c.paid).length;
    return Column(children: [
      Row(children: [
        Text(
          _ctrl.text.trim().toUpperCase(),
          style: GoogleFonts.spaceMono(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1, letterSpacing: 2),
        ),
        const Spacer(),
        if (challans.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: unpaid > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              unpaid > 0 ? '$unpaid Unpaid' : 'All Clear ✓',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700,
                  color: unpaid > 0 ? AppTheme.red : AppTheme.green),
            ),
          ),
      ]),
      const SizedBox(height: 12),

      if (challans.isEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(28),
          decoration: AppTheme.cardDecoration(),
          child: Column(children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.green, size: 48),
            const SizedBox(height: 12),
            Text('No Challans Found',
                style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
            const SizedBox(height: 6),
            Text(
              'Great! This vehicle has no pending challans.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2),
            ),
          ]),
        )
      else
        ...challans.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(radius: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.id, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(c.offence, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.paid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.paid ? 'Paid' : 'Unpaid',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700,
                        color: c.paid ? AppTheme.green : AppTheme.red)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.text3),
              const SizedBox(width: 5),
              Text(c.date, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
              const SizedBox(width: 14),
              const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.text3),
              const SizedBox(width: 5),
              Expanded(child: Text(c.location, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fine Amount', style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
                Text('₹${c.amount}', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text1)),
              ]),
              const Spacer(),
              if (!c.paid)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size.zero,
                  ),
                  child: Text('Pay Now', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                )
              else
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size.zero,
                  ),
                  child: Text('Receipt', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2)),
                ),
            ]),
          ]),
        )),
    ]);
  }

  Widget _buildNotFound() => Container(
    width: double.infinity, padding: const EdgeInsets.all(28),
    decoration: AppTheme.cardDecoration(),
    child: Column(children: [
      const Icon(Icons.search_off_rounded, color: AppTheme.challanFg, size: 48),
      const SizedBox(height: 12),
      Text('Vehicle Not Found',
          style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
      const SizedBox(height: 6),
      Text(
        'No records for "${_ctrl.text.trim().toUpperCase()}". Please verify the number and try again.',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2, height: 1.5),
      ),
    ]),
  );

  Widget _buildHowItWorks() => Container(
    padding: const EdgeInsets.all(18),
    decoration: AppTheme.cardDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How it works', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.text1)),
      const SizedBox(height: 14),
      ...[
        'Enter your vehicle registration number above',
        'We fetch real-time challan data from traffic authority',
        'View pending challans and pay them instantly',
      ].asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppTheme.challanBg, borderRadius: BorderRadius.circular(7)),
            child: Center(child: Text('${e.key + 1}',
                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.challanFg))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(e.value, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2, height: 1.5))),
        ]),
      )),
    ]),
  );
}

class _Challan {
  final String id, offence, location, date;
  final int amount;
  final bool paid;
  const _Challan({required this.id, required this.offence, required this.location,
      required this.date, required this.amount, required this.paid});
}
