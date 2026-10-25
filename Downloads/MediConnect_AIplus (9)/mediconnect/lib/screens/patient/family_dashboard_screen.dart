import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/records_service.dart';

class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final family = RecordsService.instance.getFamily();
    return Scaffold(
      appBar: AppBar(title: const Text('Family Healthcare')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        onPressed: () {},
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: family.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = family[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
            child: Row(
              children: [
                Avatar3D(radius: 26, label: m.name[0]),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${m.relation} · ${m.age} yrs · ${m.bloodGroup}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Book', style: TextStyle(fontSize: 12.5))),
                    TextButton(onPressed: () {}, child: const Text('Records', style: TextStyle(fontSize: 12.5))),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }
}
