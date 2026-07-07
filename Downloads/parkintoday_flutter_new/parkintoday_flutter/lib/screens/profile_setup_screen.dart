import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

/// Shows a bottom sheet letting the user choose Camera or Gallery,
/// then returns the picked image file path (or null if cancelled).
Future<String?> pickRcBookImage(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Text('Upload RC Book', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        const SizedBox(height: 4),
        Text('Choose how you\'d like to add the photo', style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.text3)),
        const SizedBox(height: 18),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.photo_camera_rounded, color: AppTheme.accent, size: 20),
          ),
          title: Text('Take a photo', style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
          onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.photo_library_rounded, color: AppTheme.accent, size: 20),
          ),
          title: Text('Choose from gallery', style: GoogleFonts.dmSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
          onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
        ),
      ]),
    ),
  );

  if (source == null) return null;
  final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600);
  return picked?.path;
}

/// Reusable RC Book upload card used in vehicle forms.
class RcBookUploadField extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onChanged;
  const RcBookUploadField({super.key, required this.imagePath, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        final path = await pickRcBookImage(context);
        if (path != null) onChanged(path);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1.5, style: BorderStyle.solid),
        ),
        child: hasImage
            ? Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(imagePath!), width: 52, height: 52, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('RC Book uploaded', style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  const SizedBox(height: 2),
                  Text('Tap to change photo', style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3)),
                ])),
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.text3),
                ),
              ])
            : Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.description_outlined, color: AppTheme.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Upload RC Book', style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  const SizedBox(height: 2),
                  Text('Camera or gallery · optional', style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3)),
                ])),
                const Icon(Icons.add_a_photo_outlined, color: AppTheme.text3, size: 20),
              ]),
      ),
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  final String phone;
  final String name;
  const ProfileSetupScreen({super.key, required this.phone, required this.name});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl  = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  VehicleType _vehicleType = VehicleType.car;
  bool _loading = false;

  bool get _valid =>
      _nameCtrl.text.trim().length > 1 &&
      _plateCtrl.text.trim().length >= 4 &&
      _modelCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _plateCtrl.dispose(); _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.read<AppState>().registerUser(
      name: _nameCtrl.text.trim(),
      phone: widget.phone,
      plate: _plateCtrl.text.trim().toUpperCase(),
      vehicleType: _vehicleType,
      model: _modelCtrl.text.trim(),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up your profile', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.text1)),
              const SizedBox(height: 6),
              Text(
                'We verify your vehicle once — check-in at any parking slot takes seconds after that.',
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2, height: 1.5),
              ),
              const SizedBox(height: 28),

              _label('Full name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text1),
                decoration: const InputDecoration(hintText: 'e.g. Arjun Kumar'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),

              _label('Vehicle plate number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _plateCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                style: GoogleFonts.spaceMono(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1, letterSpacing: 2),
                decoration: const InputDecoration(hintText: 'TN 09 AB 1234'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),

              _label('Vehicle type'),
              const SizedBox(height: 10),
              Row(
                children: VehicleType.values.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _VehicleTypeChip(
                    type: t, selected: _vehicleType == t,
                    onTap: () => setState(() => _vehicleType = t),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 18),

              _label('Vehicle model'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _modelCtrl,
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text1),
                decoration: const InputDecoration(hintText: 'e.g. Hyundai Creta'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Info note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.accentDark, size: 17),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Your vehicle details will be saved and auto-filled when booking a parking slot. You can add more vehicles later.',
                    style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.accentDark, height: 1.5),
                  )),
                ]),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _valid && !_loading ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    disabledBackgroundColor: const Color(0xFFA8D8E3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Continue', style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text2));
}

class _VehicleTypeChip extends StatelessWidget {
  final VehicleType type;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleTypeChip({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: selected ? AppTheme.accent : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppTheme.accent : AppTheme.border, width: 1.5),
        boxShadow: selected ? [BoxShadow(color: AppTheme.accent.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(type.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(type.label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppTheme.text1)),
      ]),
    ),
  );
}

// ── Add Vehicle Sheet (used from dashboard vehicles page) ──
class AddVehicleSheet extends StatefulWidget {
  const AddVehicleSheet({super.key});
  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  final _plateCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  VehicleType _type = VehicleType.car;
  bool _isDefault = false;
  String? _rcImagePath;

  bool get _valid => _plateCtrl.text.trim().length >= 4 && _modelCtrl.text.trim().isNotEmpty;

  @override
  void dispose() { _plateCtrl.dispose(); _modelCtrl.dispose(); super.dispose(); }

  void _save() {
    const uuid = Uuid();
    context.read<AppState>().addVehicle(Vehicle(
      id: uuid.v4(),
      plate: _plateCtrl.text.trim().toUpperCase(),
      type: _type,
      model: _modelCtrl.text.trim(),
      rcImagePath: _rcImagePath,
      isDefault: _isDefault,
    ));
    Navigator.pop(context);
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text2));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Text('Add New Vehicle', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        const SizedBox(height: 20),

        _label('Plate number'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _plateCtrl,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')), LengthLimitingTextInputFormatter(13)],
          style: GoogleFonts.spaceMono(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1, letterSpacing: 2),
          decoration: const InputDecoration(hintText: 'TN 09 AB 1234'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        _label('Vehicle model'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _modelCtrl,
          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text1),
          decoration: const InputDecoration(hintText: 'e.g. Toyota Fortuner'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        _label('Vehicle type'),
        const SizedBox(height: 10),
        Row(
          children: VehicleType.values.map((t) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _VehicleTypeChip(type: t, selected: _type == t, onTap: () => setState(() => _type = t)),
          )).toList(),
        ),
        const SizedBox(height: 16),

        _label('RC Book'),
        const SizedBox(height: 6),
        RcBookUploadField(
          imagePath: _rcImagePath,
          onChanged: (path) => setState(() => _rcImagePath = path),
        ),
        const SizedBox(height: 14),

        Row(children: [
          Checkbox(
            value: _isDefault, activeColor: AppTheme.accent,
            onChanged: (v) => setState(() => _isDefault = v ?? false),
          ),
          Text('Set as default vehicle', style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.text1)),
        ]),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _valid ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent, disabledBackgroundColor: const Color(0xFFA8D8E3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Save Vehicle', style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}
