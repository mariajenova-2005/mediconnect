import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../services/doctor_agent_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/art3d.dart';
import 'alarm_screen.dart';

/// Talk to "Dr. Medi": a large animated face that listens, answers out loud, and updates
/// over-the-counter medicine suggestions live as the conversation goes on.
class DoctorAgentScreen extends StatefulWidget {
  const DoctorAgentScreen({super.key});
  @override
  State<DoctorAgentScreen> createState() => _DoctorAgentScreenState();
}

class _DoctorAgentScreenState extends State<DoctorAgentScreen> {
  final _tts = FlutterTts();
  final _stt = SpeechToText();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _msgs = [];
  final List<Map<String, String>> _history = [];
  List<MedSuggestion> _meds = [];
  bool _sttOk = false, _speaking = false, _listening = false, _thinking = false, _voice = true, _urgent = false;
  String _heard = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _speaking = false);
      });
      await _tts.setSpeechRate(0.45);
    } catch (_) {}
    try {
      _sttOk = await _stt.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) setState(() => _listening = false);
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    } catch (_) {
      _sttOk = false;
    }
    final name = DataService.instance.getCurrentPatient().name.split(' ').first;
    _addDoctor("Hello $name, I'm Dr. Medi, your AI health assistant. I'm not a licensed doctor, but I can listen, give general guidance, and tell you when to see a doctor. What's troubling you today?");
  }

  void _toEnd() => Future.delayed(const Duration(milliseconds: 120), () {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });

  void _addDoctor(String text) {
    if (!mounted) return;
    setState(() => _msgs.add(ChatMessage(text: text, fromUser: false, time: DateTime.now())));
    _history.add({'role': 'assistant', 'content': text});
    _toEnd();
    _speak(text);
  }

  Future<void> _speak(String text) async {
    if (!_voice) return;
    try {
      setState(() => _speaking = true);
      await _tts.speak(text);
    } catch (_) {}
    Future.delayed(Duration(milliseconds: 600 + text.length * 70), () {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;
    _input.clear();
    setState(() {
      _msgs.add(ChatMessage(text: text, fromUser: true, time: DateTime.now()));
      _thinking = true;
      _heard = '';
    });
    _history.add({'role': 'user', 'content': text});
    _toEnd();
    final r = await DoctorAgentService.instance.reply(_history, DataService.instance.getCurrentPatient());
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _meds = r.meds;
      if (r.urgent) _urgent = true;
    });
    _addDoctor(r.reply);
  }

  Future<void> _listen() async {
    if (!_sttOk) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice input unavailable — allow the microphone, or type instead')));
      return;
    }
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    await _tts.stop();
    setState(() {
      _listening = true;
      _speaking = false;
      _heard = '';
    });
    await _stt.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() => _heard = r.recognizedWords);
        if (r.finalResult) {
          setState(() => _listening = false);
          _send(r.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _pharmacy() async {
    final p = await LocationService.instance.current();
    final url = p == null ? 'https://www.google.com/maps/search/pharmacy+near+me' : 'https://www.google.com/maps/search/pharmacy/@${p.latitude},${p.longitude},15z';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom > 0;
    final stageH = mq.size.height * (kb ? 0.22 : 0.45);
    final faceW = math.min(mq.size.width * 0.95, stageH / 1.05);
    final status = _listening ? (_heard.isEmpty ? 'Listening…' : _heard) : _speaking ? 'Dr. Medi is speaking…' : _thinking ? 'Thinking…' : 'Tap the mic and talk';
    final caption = _msgs.lastWhere((m) => !m.fromUser, orElse: () => ChatMessage(text: '', fromUser: false, time: DateTime.now())).text;
    final hasAllergies = DataService.instance.getCurrentPatient().allergies.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Medi · AI Doctor'),
        actions: [
          IconButton(icon: Icon(_voice ? Icons.volume_up_rounded : Icons.volume_off_rounded), onPressed: () {
            setState(() => _voice = !_voice);
            if (!_voice) _tts.stop();
          }),
        ],
      ),
      body: Column(children: [
        // ---------- big face stage ----------
        Container(
          height: stageH,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(colors: [Color(0xFF053A5F), Color(0xFF0B6E99), Color(0xFF17C3A2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: AppShadows.card3d,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(0, -0.2), radius: 0.8, colors: [Colors.white.withOpacity(0.25), Colors.transparent])))),
              DoctorAvatar(size: faceW, speaking: _speaking, listening: _listening),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.circle, size: 9, color: _listening ? AppColors.severe : _speaking ? AppColors.accentGreen : Colors.white54),
                      const SizedBox(width: 6),
                      ConstrainedBox(constraints: BoxConstraints(maxWidth: mq.size.width * 0.6), child: Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ]),
              ),
              if (caption.isNotEmpty && !kb)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(16)),
                    child: Text(caption, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.3)),
                  ),
                ),
            ]),
          ),
        ),
        if (_urgent)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.severe.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.severe)),
            child: Row(children: [
              const Icon(Icons.warning_rounded, color: AppColors.severe),
              const SizedBox(width: 8),
              const Expanded(child: Text('This may be an emergency', style: TextStyle(color: AppColors.severe, fontWeight: FontWeight.w800))),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmScreen())), child: const Text('Alarm')),
              TextButton(onPressed: () => launchUrl(Uri(scheme: 'tel', path: '112')), child: const Text('Call 112')),
            ]),
          ).animate().shake(duration: 500.ms),
        // ---------- live medicine suggestions ----------
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _meds.isEmpty
              ? const SizedBox.shrink()
              : Column(key: ValueKey(_meds.map((m) => m.name).join('|')), crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    child: Row(children: [
                      const Icon(Icons.circle, size: 9, color: AppColors.mild),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Live over-the-counter suggestions${hasAllergies ? ' · checked against your allergies' : ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    ]),
                  ),
                  SizedBox(
                    height: 128,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _meds.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _MedCard(med: _meds[i], onPharmacy: _pharmacy),
                    ),
                  ),
                ]),
        ),
        // ---------- transcript ----------
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            itemCount: _msgs.length + (_thinking ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) return const Padding(padding: EdgeInsets.all(8), child: Text('Dr. Medi is thinking…', style: TextStyle(color: AppColors.textMuted)));
              final m = _msgs[i];
              return Align(
                alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(11),
                  constraints: BoxConstraints(maxWidth: mq.size.width * 0.78),
                  decoration: BoxDecoration(gradient: m.fromUser ? AppColors.heroGradient : null, color: m.fromUser ? null : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.card3d),
                  child: Text(m.text, style: TextStyle(color: m.fromUser ? Colors.white : AppColors.textDark, height: 1.35, fontSize: 13)),
                ),
              ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
            child: Row(children: [
              Expanded(child: TextField(controller: _input, onSubmitted: _send, decoration: const InputDecoration(hintText: 'Type your symptoms…'))),
              IconButton(onPressed: () => _send(_input.text), icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue)),
              GestureDetector(
                onTap: _listen,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: _listening ? AppColors.emergencyGradient : AppColors.heroGradient, boxShadow: [BoxShadow(color: (_listening ? AppColors.severe : AppColors.accentGreen).withOpacity(0.5), blurRadius: 16, spreadRadius: _listening ? 4 : 0)]),
                  child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 28),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MedCard extends StatelessWidget {
  final MedSuggestion med;
  final VoidCallback onPharmacy;
  const _MedCard({required this.med, required this.onPharmacy});
  @override
  Widget build(BuildContext context) => Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon3D(icon: Icons.medication_rounded, color: AppColors.accentGreen, size: 34),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(med.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(med.purpose, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            ])),
          ]),
          const SizedBox(height: 6),
          Expanded(child: Text(med.caution, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.moderate, fontWeight: FontWeight.w600))),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: onPharmacy, icon: const Icon(Icons.local_pharmacy_rounded, size: 16), label: const Text('Nearby pharmacy', style: TextStyle(fontSize: 11.5)), style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24)))),
        ]),
      );
}

/// Large, detailed human-like animated face: shaded skin, hair, brows, eyes with iris & gaze,
/// blinking, nose, lips with lip-sync while speaking, plus a doctor's coat and stethoscope.
class DoctorAvatar extends StatefulWidget {
  final double size; // width; height is size * 1.05
  final bool speaking, listening;
  const DoctorAvatar({super.key, this.size = 140, this.speaking = false, this.listening = false});
  @override
  State<DoctorAvatar> createState() => _DoctorAvatarState();
}

class _DoctorAvatarState extends State<DoctorAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()..setEntry(3, 2, 0.0010)..rotateY(0.10 * math.sin(t))..rotateX(0.03 * math.cos(t * 2))..rotateZ(0.012 * math.sin(t * 2)),
            child: SizedBox(width: widget.size, height: widget.size * 1.05, child: CustomPaint(painter: _FacePainter(_c.value, widget.speaking, widget.listening))),
          );
        },
      );
}

class _FacePainter extends CustomPainter {
  final double t;
  final bool speaking, listening;
  _FacePainter(this.t, this.speaking, this.listening);

  static const skinLight = Color(0xFFF6D5B8), skin = Color(0xFFE8B792), skinDark = Color(0xFFC98E69);
  static const hairDark = Color(0xFF181414);

  MaskFilter _blur(double r) => MaskFilter.blur(BlurStyle.normal, r);

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height, cx = w * .5;
    final cy = h * .40 + math.sin(t * 2 * math.pi * 2) * h * .004;
    final hw = w * .205, hh = w * .265;

    if (listening) {
      for (var i = 0; i < 3; i++) {
        final p = (t * 3 + i / 3) % 1.0;
        c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: hw * 2 * (1.25 + .5 * p), height: hh * 2 * (1.15 + .4 * p)), Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = Colors.white.withOpacity(.55 * (1 - p)));
      }
    }

    // ----- coat, scrubs, stethoscope -----
    final coat = Path()
      ..moveTo(w * .02, h)
      ..quadraticBezierTo(w * .04, h * .80, w * .26, h * .745)
      ..lineTo(cx - w * .10, h * .70)
      ..lineTo(cx + w * .10, h * .70)
      ..lineTo(w * .74, h * .745)
      ..quadraticBezierTo(w * .96, h * .80, w * .98, h)
      ..close();
    c.drawShadow(coat, Colors.black, 10, true);
    c.drawPath(coat, Paint()..shader = const LinearGradient(colors: [Colors.white, Color(0xFFD5E4EE)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, h * .7, w, h * .3)));
    c.drawPath(Path()..moveTo(cx - w * .10, h * .70)..lineTo(cx, h * .87)..lineTo(cx + w * .10, h * .70)..close(), Paint()..color = const Color(0xFF17C3A2));
    final lap = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = const Color(0xFFB0C4CF);
    c.drawLine(Offset(cx - w * .10, h * .70), Offset(cx - w * .035, h * .995), lap);
    c.drawLine(Offset(cx + w * .10, h * .70), Offset(cx + w * .035, h * .995), lap);
    final steth = Path()..moveTo(cx - w * .125, h * .715)..quadraticBezierTo(cx - w * .13, h * .90, cx - w * .02, h * .93)..quadraticBezierTo(cx + w * .1, h * .95, cx + w * .125, h * .715);
    c.drawPath(steth, Paint()..style = PaintingStyle.stroke..strokeWidth = w * .014..strokeCap = StrokeCap.round..color = const Color(0xFF37474F));
    c.drawCircle(Offset(cx - w * .02, h * .935), w * .03, Paint()..shader = const RadialGradient(colors: [Color(0xFFCFD8DC), Color(0xFF607D8B)]).createShader(Rect.fromCircle(center: Offset(cx - w * .02, h * .935), radius: w * .03)));
    final badge = Paint()..color = AppColors.accentGreen;
    c.drawRect(Rect.fromCenter(center: Offset(w * .78, h * .86), width: w * .05, height: w * .014), badge);
    c.drawRect(Rect.fromCenter(center: Offset(w * .78, h * .86), width: w * .014, height: w * .05), badge);

    // ----- neck -----
    final neck = Path()..moveTo(cx - w * .075, cy + hh * .55)..lineTo(cx - w * .088, h * .72)..quadraticBezierTo(cx, h * .765, cx + w * .088, h * .72)..lineTo(cx + w * .075, cy + hh * .55)..close();
    c.drawPath(neck, Paint()..shader = const LinearGradient(colors: [skin, skinDark], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(neck.getBounds()));
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + hh * .98), width: hw * 1.5, height: hh * .34), Paint()..color = Colors.black.withOpacity(.16)..maskFilter = _blur(9));

    // ----- ears -----
    for (final sx in [-1.0, 1.0]) {
      final e = Rect.fromCenter(center: Offset(cx + sx * hw * .99, cy + hh * .06), width: hw * .2, height: hh * .34);
      c.drawOval(e, Paint()..color = skin);
      c.drawOval(e.deflate(hw * .045), Paint()..color = skinDark.withOpacity(.45));
    }

    // ----- head -----
    final headRect = Rect.fromCenter(center: Offset(cx, cy), width: hw * 2, height: hh * 2);
    c.drawOval(headRect, Paint()..shader = const RadialGradient(center: Alignment(-0.35, -0.45), radius: 1.0, colors: [skinLight, skin, skinDark], stops: [0, .65, 1]).createShader(headRect));
    for (final sx in [-1.0, 1.0]) {
      c.drawOval(Rect.fromCenter(center: Offset(cx + sx * hw * .56, cy + hh * .34), width: hw * .5, height: hh * .3), Paint()..color = const Color(0xFFE88F8A).withOpacity(.24)..maskFilter = _blur(11));
    }

    // ----- hair -----
    final hair = Path()
      ..moveTo(cx - hw * 1.03, cy - hh * .02)
      ..quadraticBezierTo(cx - hw * 1.18, cy - hh * 1.08, cx, cy - hh * 1.13)
      ..quadraticBezierTo(cx + hw * 1.18, cy - hh * 1.08, cx + hw * 1.03, cy - hh * .02)
      ..quadraticBezierTo(cx + hw * .96, cy - hh * .56, cx + hw * .45, cy - hh * .64)
      ..quadraticBezierTo(cx, cy - hh * .80, cx - hw * .55, cy - hh * .62)
      ..quadraticBezierTo(cx - hw * .96, cy - hh * .5, cx - hw * 1.03, cy - hh * .02)
      ..close();
    c.drawPath(hair, Paint()..shader = const LinearGradient(colors: [Color(0xFF3B3333), hairDark], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(hair.getBounds()));
    c.drawPath(Path()..moveTo(cx - hw * .55, cy - hh * .99)..quadraticBezierTo(cx, cy - hh * 1.09, cx + hw * .5, cy - hh * .96), Paint()..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..color = Colors.white.withOpacity(.14));

    // ----- eyes & brows -----
    final eyeY = cy - hh * .05, ew = hw * .21, eh = hw * .105;
    final gaze = math.sin(t * 2 * math.pi) * ew * .16;
    final bp = (t * 3) % 1.0;
    final blink = bp < .05 ? (1 - (bp - .025).abs() / .025) : 0.0;
    final lift = (speaking ? math.sin(t * 2 * math.pi * 2).abs() * hh * .014 : 0.0) + (listening ? hh * .022 : 0.0);
    for (final sx in [-1.0, 1.0]) {
      final ec = Offset(cx + sx * hw * .46, eyeY);
      final er = Rect.fromCenter(center: ec, width: ew * 2, height: eh * 2);
      c.drawOval(er.inflate(eh * .55), Paint()..color = skinDark.withOpacity(.20)..maskFilter = _blur(6));
      c.save();
      c.clipPath(Path()..addOval(er));
      c.drawRect(er, Paint()..color = const Color(0xFFFDFBF8));
      final ic = ec.translate(gaze, listening ? -eh * .12 : 0);
      c.drawCircle(ic, eh * .97, Paint()..shader = RadialGradient(colors: const [Color(0xFF9A6A3E), Color(0xFF3E2410)]).createShader(Rect.fromCircle(center: ic, radius: eh * .97)));
      c.drawCircle(ic, eh * .46, Paint()..color = Colors.black);
      c.drawCircle(ic.translate(-eh * .32, -eh * .32), eh * .22, Paint()..color = Colors.white.withOpacity(.92));
      if (blink > 0) c.drawRect(Rect.fromLTRB(er.left, er.top, er.right, er.top + er.height * blink), Paint()..color = skin);
      c.restore();
      c.drawArc(er, math.pi, math.pi, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.6..strokeCap = StrokeCap.round..color = const Color(0xFF2A1A12));
      c.drawArc(er.translate(0, 1), 0, math.pi, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = skinDark.withOpacity(.6));
      final inner = ec.dx - sx * ew * 1.0, outer = ec.dx + sx * ew * 1.12, by = eyeY - hh * .20 - lift;
      c.drawPath(Path()..moveTo(inner, by + hh * .02)..quadraticBezierTo((inner + outer) / 2, by - hh * .045, outer, by + hh * .035), Paint()..style = PaintingStyle.stroke..strokeWidth = hw * .075..strokeCap = StrokeCap.round..color = const Color(0xFF2A2222));
    }

    // ----- nose -----
    final tipY = cy + hh * .30;
    for (final sx in [-1.0, 1.0]) {
      c.drawPath(Path()..moveTo(cx + sx * hw * .07, eyeY + hh * .04)..quadraticBezierTo(cx + sx * hw * .13, cy + hh * .15, cx + sx * hw * .15, tipY), Paint()..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..color = skinDark.withOpacity(.5));
      c.drawOval(Rect.fromCenter(center: Offset(cx + sx * hw * .10, tipY + hh * .02), width: hw * .075, height: hh * .036), Paint()..color = const Color(0xFF7A4A38).withOpacity(.65));
    }
    c.drawOval(Rect.fromCenter(center: Offset(cx, tipY - hh * .02), width: hw * .2, height: hh * .09), Paint()..color = skinLight.withOpacity(.55)..maskFilter = _blur(3));

    // ----- mouth with lip-sync -----
    final my = cy + hh * .58;
    final v = speaking ? (0.5 + 0.5 * math.sin(t * 2 * math.pi * 9)) * (0.55 + 0.45 * math.sin(t * 2 * math.pi * 2.3 + 1)) : 0.0;
    final open = hh * .11 * v;
    final mw = hw * .34 * (speaking ? (0.86 + 0.24 * math.sin(t * 2 * math.pi * 5)) : 1.0);
    c.drawOval(Rect.fromCenter(center: Offset(cx, my + hh * .2), width: hw * .4, height: hh * .06), Paint()..color = skinDark.withOpacity(.22)..maskFilter = _blur(4));
    if (open > hh * .012) {
      final cavity = Path()..addOval(Rect.fromCenter(center: Offset(cx, my + open * .15), width: mw * 1.75, height: open * 2));
      c.drawPath(cavity, Paint()..color = const Color(0xFF45161E));
      c.save();
      c.clipPath(cavity);
      c.drawRect(Rect.fromLTWH(cx - mw, my - open, mw * 2, open * .7), Paint()..color = const Color(0xFFFAFAF5));
      c.drawOval(Rect.fromCenter(center: Offset(cx, my + open * .85), width: mw, height: open * .8), Paint()..color = const Color(0xFFD9707A));
      c.restore();
    }
    final upper = Path()
      ..moveTo(cx - mw, my)
      ..quadraticBezierTo(cx - mw * .5, my - hh * .06 - open * .3, cx, my - hh * .036 - open * .5)
      ..quadraticBezierTo(cx + mw * .5, my - hh * .06 - open * .3, cx + mw, my)
      ..quadraticBezierTo(cx, my - open * .15, cx - mw, my)
      ..close();
    final lower = Path()
      ..moveTo(cx - mw, my)
      ..quadraticBezierTo(cx, my + hh * .10 + open * 1.4, cx + mw, my)
      ..quadraticBezierTo(cx, my + open * .85, cx - mw, my)
      ..close();
    c.drawPath(lower, Paint()..color = const Color(0xFFC9696E));
    c.drawPath(upper, Paint()..color = const Color(0xFFB4545A));
    if (open <= hh * .012) c.drawLine(Offset(cx - mw, my), Offset(cx + mw, my), Paint()..strokeWidth = 1.6..strokeCap = StrokeCap.round..color = const Color(0xFF8E3A42));
    c.drawCircle(Offset(cx - mw * .45, my + hh * .062 + open * .6), hw * .035, Paint()..color = Colors.white.withOpacity(.28));
  }

  @override
  bool shouldRepaint(covariant _FacePainter o) => true;
}
