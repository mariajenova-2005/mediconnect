import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'profile_setup_screen.dart';
import 'main_shell.dart';

enum _AuthMode { login, register }
enum _AuthStep { details, otp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  _AuthMode _mode = _AuthMode.login;
  _AuthStep _step = _AuthStep.details;

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrls  = List.generate(6, (_) => TextEditingController());
  final _otpFocuses= List.generate(6, (_) => FocusNode());

  bool _loading  = false;
  String _otpErr = '';
  int _seconds   = 30;
  bool _timerRunning = false;
  String? _infoMsg;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const String _demoOtp = '123456';

  bool get _isRegister => _mode == _AuthMode.register;
  bool get _detailsValid =>
      _phoneCtrl.text.length == 10 &&
      (!_isRegister || _nameCtrl.text.trim().length > 1);
  bool get _otpComplete => _otpCtrls.every((c) => c.text.length == 1);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocuses) f.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode m) {
    setState(() {
      _mode = m;
      _step = _AuthStep.details;
      _otpErr = '';
      _infoMsg = null;
      for (final c in _otpCtrls) c.clear();
    });
  }

  Future<void> _handleContinue() async {
    final appState = context.read<AppState>();
    final phone = _phoneCtrl.text.trim();

    if (_mode == _AuthMode.login) {
      final isExisting = appState.isExistingUser(phone);
      if (isExisting) {
        // Existing user: direct login, no OTP
        setState(() { _loading = true; });
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        setState(() { _loading = false; });
        appState.login(phone);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        // New number trying to login → tell them to register
        setState(() {
          _infoMsg = 'Number not found. Please register first.';
        });
      }
      return;
    }

    // Register flow → OTP
    setState(() { _loading = true; _infoMsg = null; });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _step = _AuthStep.otp;
      _seconds = 30;
      _otpErr = '';
      for (final c in _otpCtrls) c.clear();
    });
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _otpFocuses[0].requestFocus());
  }

  void _startTimer() {
    if (_timerRunning) return;
    _timerRunning = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_seconds > 0) _seconds--; });
      if (_seconds == 0) { _timerRunning = false; return false; }
      return true;
    });
  }

  Future<void> _handleVerify() async {
    final entered = _otpCtrls.map((c) => c.text).join();
    if (entered != _demoOtp) {
      setState(() { _otpErr = 'Incorrect code. Demo code is $_demoOtp'; });
      return;
    }
    setState(() { _loading = true; _otpErr = ''; });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() { _loading = false; });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          phone: _phoneCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
        ),
      ),
    );
  }

  void _otpChanged(String val, int idx) {
    final digit = val.replaceAll(RegExp(r'[^0-9]'), '');
    _otpCtrls[idx].text = digit.isEmpty ? '' : digit[digit.length - 1];
    _otpCtrls[idx].selection = TextSelection.collapsed(offset: _otpCtrls[idx].text.length);
    if (digit.isNotEmpty && idx < 5) _otpFocuses[idx + 1].requestFocus();
    if (_otpErr.isNotEmpty) setState(() => _otpErr = '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildLogo(),
                const SizedBox(height: 32),
                if (_step == _AuthStep.details) ..._buildDetailsStep(),
                if (_step == _AuthStep.otp)    ..._buildOtpStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() => Row(
    children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(child: Text('P', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white))),
      ),
      const SizedBox(width: 10),
      RichText(
        text: TextSpan(children: [
          TextSpan(text: 'ParkIn', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.text1)),
          TextSpan(text: 'Today', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accent)),
        ]),
      ),
    ],
  );

  List<Widget> _buildDetailsStep() => [
    // Tab switcher
    Container(
      decoration: BoxDecoration(color: const Color(0xFFE5E9EC), borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabBtn(label: 'Log in',   active: _mode == _AuthMode.login,    onTap: () => _switchMode(_AuthMode.login)),
          _TabBtn(label: 'Register', active: _mode == _AuthMode.register, onTap: () => _switchMode(_AuthMode.register)),
        ],
      ),
    ),
    const SizedBox(height: 28),

    Text(
      _isRegister ? 'Create your account' : 'Welcome back',
      style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.text1),
    ),
    const SizedBox(height: 6),
    Text(
      _isRegister
          ? "Enter your details — we'll verify with a one-time code."
          : 'Enter your number. Existing users get instant access.',
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2, height: 1.5),
    ),
    const SizedBox(height: 26),

    if (_isRegister) ...[
      _FieldLabel('Full name'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text1),
        decoration: const InputDecoration(hintText: 'e.g. Arjun Kumar'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
    ],

    _FieldLabel('Mobile number'),
    const SizedBox(height: 6),
    Row(children: [
      Container(
        height: 54, padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card, border: Border.all(color: AppTheme.border, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: Text('+91', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1))),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.text1, letterSpacing: 1.5),
          decoration: const InputDecoration(hintText: '98765 43210'),
          onChanged: (_) => setState(() { _infoMsg = null; }),
        ),
      ),
    ]),

    if (_infoMsg != null) ...[
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
        child: Text(_infoMsg!, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF92400E), fontWeight: FontWeight.w600)),
      ),
    ],

    if (_mode == _AuthMode.login) ...[
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.accentDark, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Existing users are verified instantly — no OTP needed.',
            style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.accentDark, fontWeight: FontWeight.w500),
          )),
        ]),
      ),
    ],

    const SizedBox(height: 32),

    SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _detailsValid && !_loading ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          disabledBackgroundColor: const Color(0xFFA8D8E3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(
                _isRegister ? 'Send OTP' : 'Continue',
                style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
      ),
    ),

    const SizedBox(height: 20),
    Center(
      child: Text(
        'By continuing, you agree to our Terms & Privacy Policy.',
        style: GoogleFonts.dmSans(fontSize: 11.5, color: AppTheme.text3),
        textAlign: TextAlign.center,
      ),
    ),
    const SizedBox(height: 32),
  ];

  List<Widget> _buildOtpStep() => [
    Text('Enter the code', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.text1)),
    const SizedBox(height: 6),
    RichText(
      text: TextSpan(children: [
        TextSpan(text: 'We sent a 6-digit code to  ', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2)),
        TextSpan(text: '+91 ${_phoneCtrl.text}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.text1)),
      ]),
    ),
    const SizedBox(height: 20),

    // Demo banner
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFECFEFF), border: Border.all(color: const Color(0xFFBAE6FD)), borderRadius: BorderRadius.circular(12)),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Demo mode — no SMS sent. Enter ', style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.accentDark)),
          TextSpan(text: _demoOtp, style: GoogleFonts.spaceMono(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accentDark)),
          TextSpan(text: ' to continue.', style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.accentDark)),
        ]),
      ),
    ),
    const SizedBox(height: 26),

    // OTP boxes
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
        controller: _otpCtrls[i],
        focusNode: _otpFocuses[i],
        onChanged: (v) => _otpChanged(v, i),
        onBackspace: () {
          if (_otpCtrls[i].text.isEmpty && i > 0) {
            _otpFocuses[i - 1].requestFocus();
            _otpCtrls[i - 1].clear();
            setState(() {});
          }
        },
      )),
    ),

    if (_otpErr.isNotEmpty) ...[
      const SizedBox(height: 10),
      Text(_otpErr, style: GoogleFonts.dmSans(fontSize: 12.5, color: AppTheme.red, fontWeight: FontWeight.w600)),
    ],

    const SizedBox(height: 22),
    Center(
      child: _seconds > 0
          ? Text('Resend code in 0:${_seconds.toString().padLeft(2, '0')}',
              style: GoogleFonts.dmSans(fontSize: 13.5, color: AppTheme.text2))
          : GestureDetector(
              onTap: () { setState(() => _seconds = 30); _startTimer(); },
              child: Text('Resend code', style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.accent)),
            ),
    ),

    const SizedBox(height: 32),
    SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton(
        onPressed: _otpComplete && !_loading ? _handleVerify : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          disabledBackgroundColor: const Color(0xFFA8D8E3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text('Verify & continue', style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    ),

    const SizedBox(height: 16),
    Center(
      child: TextButton(
        onPressed: () => setState(() { _step = _AuthStep.details; _otpErr = ''; }),
        child: Text('Edit details', style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.text2)),
      ),
    ),
    const SizedBox(height: 32),
  ];
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppTheme.card : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))] : [],
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: active ? AppTheme.text1 : AppTheme.text2)),
        ),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text2),
  );
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged, required this.onBackspace});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46,
    height: 56,
    child: KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (e) {
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace && controller.text.isEmpty) {
          onBackspace();
        }
      },
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.text1),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: controller.text.isEmpty ? AppTheme.border : AppTheme.accent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.accent, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    ),
  );
}
