import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class _Donor {
  final String name, group, area, phone;
  final double km;
  const _Donor(this.name, this.group, this.area, this.km, this.phone);
}

/// SAMPLE donors for the demo — connect to your backend's donor registry for real data.
const _donors = [
  _Donor('Arun Kumar', 'O+', 'T Nagar', 2.1, '+919800000001'),
  _Donor('Meena S', 'A+', 'Adyar', 3.4, '+919800000002'),
  _Donor('Farhan Ali', 'B+', 'Velachery', 4.8, '+919800000003'),
  _Donor('Divya R', 'O-', 'Anna Nagar', 5.2, '+919800000004'),
  _Donor('Prakash M', 'AB+', 'Guindy', 3.9, '+919800000005'),
  _Donor('Lakshmi N', 'A-', 'Mylapore', 2.7, '+919800000006'),
  _Donor('Vignesh T', 'B-', 'Porur', 6.3, '+919800000007'),
];

class BloodDonorScreen extends StatefulWidget {
  const BloodDonorScreen({super.key});
  @override
  State<BloodDonorScreen> createState() => _BloodDonorScreenState();
}

class _BloodDonorScreenState extends State<BloodDonorScreen> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final groups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    final list = _donors.where((d) => _filter == 'All' || d.group == _filter).toList()..sort((a, b) => a.km.compareTo(b.km));
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Donors')),
      body: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: HeroBanner(title: 'Blood Donors', subtitle: 'Find a matching donor nearby', icon: Icons.bloodtype_rounded, colors: [Color(0xFFE94B4B), Color(0xFFF5725B)])),
        SizedBox(
          height: 46,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(label: Text(groups[i]), selected: _filter == groups[i], selectedColor: AppColors.severe, labelStyle: TextStyle(color: _filter == groups[i] ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w700), onSelected: (_) => setState(() => _filter = groups[i])),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No donors for this group yet', style: TextStyle(color: AppColors.textMuted)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final d = list[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
                      child: Row(children: [
                        Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(gradient: AppColors.emergencyGradient, shape: BoxShape.circle), child: Text(d.group, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${d.area} · ${d.km} km away', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5))])),
                        IconButton(icon: const Icon(Icons.call_rounded, color: AppColors.mild), onPressed: () => launchUrl(Uri(scheme: 'tel', path: d.phone))),
                      ]),
                    ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.05, end: 0);
                  },
                ),
        ),
      ]),
    );
  }
}
