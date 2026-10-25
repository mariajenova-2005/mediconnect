import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/sos_service.dart';
import '../../widgets/fx.dart';
import '../../widgets/art3d.dart';

class SosContactsScreen extends StatefulWidget {
  const SosContactsScreen({super.key});
  @override
  State<SosContactsScreen> createState() => _SosContactsScreenState();
}

class _SosContactsScreenState extends State<SosContactsScreen> {
  final _svc = SosService.instance;

  void _addManual() {
    final name = TextEditingController(), phone = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add emergency contact'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')),
          const SizedBox(height: 10),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 phone number')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty && phone.text.trim().isNotEmpty) {
                setState(() => _svc.contacts.add(SosContact(name.text.trim(), phone.text.trim())));
                _svc.save();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _ContactPicker());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family SOS Alert')),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.accentGreen, onPressed: _addManual, child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white)),
      body: Column(children: [
        GestureDetector(onTap: _svc.sendSms, child: const SizedBox(height: 120, child: Center(child: PulseRadar()))),
        Text(_svc.contacts.isEmpty ? 'Add contacts first, then tap to alert them with your live location' : 'Tap to alert ${_svc.contacts.length} contact(s) with your live location', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
        Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _import, icon: const Icon(Icons.contacts_rounded), label: const Text('Import from phone contacts')))),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _svc.contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = _svc.contacts[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
                child: Row(children: [
                  Avatar3D(radius: 22, label: c.name),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(c.phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5))])),
                  IconButton(icon: const Icon(Icons.call_rounded, color: AppColors.primaryBlue), onPressed: () => _svc.call(c)),
                  IconButton(icon: const Icon(Icons.chat_rounded, color: AppColors.mild), onPressed: () => _svc.sendWhatsApp(c)),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted), onPressed: () {
                    setState(() => _svc.contacts.removeAt(i));
                    _svc.save();
                  }),
                ]),
              ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.05, end: 0);
            },
          ),
        ),
      ]),
    );
  }
}

/// Searchable picker over the phone's real contact book; refreshes live when contacts change.
class _ContactPicker extends StatefulWidget {
  const _ContactPicker();
  @override
  State<_ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<_ContactPicker> {
  List<SosContact> _all = [];
  String _q = '';
  bool _loading = true;
  late final VoidCallback _cb = _load;

  @override
  void initState() {
    super.initState();
    _load();
    SosService.instance.watchDeviceChanges(_cb);
  }

  @override
  void dispose() {
    SosService.instance.unwatchDeviceChanges(_cb);
    super.dispose();
  }

  Future<void> _load() async {
    final l = await SosService.instance.deviceContacts();
    if (mounted) setState(() {
      _all = l;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _all.where((c) => c.name.toLowerCase().contains(_q.toLowerCase()) || c.phone.contains(_q)).toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        const Text('Pick from your contacts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(hintText: 'Search name or number', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No contacts available.\nAllow the Contacts permission (not available in Chrome).', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted))))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final c = list[i];
                        final added = SosService.instance.contacts.any((x) => x.phone == c.phone);
                        return ListTile(
                          leading: Avatar3D(radius: 20, label: c.name),
                          title: Text(c.name),
                          subtitle: Text(c.phone),
                          trailing: Icon(added ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded, color: added ? AppColors.mild : AppColors.primaryBlue),
                          onTap: added
                              ? null
                              : () {
                                  SosService.instance.contacts.add(c);
                                  SosService.instance.save();
                                  setState(() {});
                                },
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
