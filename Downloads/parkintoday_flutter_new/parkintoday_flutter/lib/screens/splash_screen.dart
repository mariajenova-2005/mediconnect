import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

// Exact colors matching the reference logo/splash design.
const Color _kCyan = AppTheme.accent; // #00B4D8
const Color _kSlate = Color(0xFF222A30);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Phase 1: the actual logo image drops/bounces in (0.0s - ~0.9s)
  late final AnimationController _introCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoTranslateY;
  late final Animation<double> _logoOpacity;

  // Phase 2: brand text reveals below the logo
  late final AnimationController _textCtrl;
  late final Animation<double> _textTranslateY;
  late final Animation<double> _textOpacity;

  // Phase 2: loading dots pulse once
  late final AnimationController _dotCtrl;
  late final Animation<double> _dotScale;
  late final Animation<double> _dotOpacity;

  // Phase 3: exit transition (extended hold + fade/scale out)
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.elasticOut),
    );
    _logoTranslateY = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textTranslateY = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textCtrl);

    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _dotOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dotCtrl, curve: const Interval(0.0, 0.38, curve: Curves.linear)),
    );
    _dotScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 250),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 200),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 200),
    ]).animate(_dotCtrl);

    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeOutCubic),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeOutCubic),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: logo bounces in
    _introCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Phase 2: brand text + loading dots reveal
    _textCtrl.forward();
    _dotCtrl.forward();

    // Hold, extended by +0.5s so the animation isn't rushed
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Phase 3: exit transition
    await _exitCtrl.forward().orCancel;
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _textCtrl.dispose();
    _dotCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Widget _dash(double w) => Opacity(
        opacity: _dotOpacity.value,
        child: Transform.scale(
          scale: _dotScale.value,
          child: Container(
            width: w,
            height: 3,
            decoration: BoxDecoration(color: _kCyan, borderRadius: BorderRadius.circular(1.5)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSlate,
      body: AnimatedBuilder(
        animation: Listenable.merge([_introCtrl, _textCtrl, _dotCtrl, _exitCtrl]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Center(
                child: SizedBox(
                  width: 250,
                  height: 210,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // The actual logo image, bouncing/dropping in
                      Positioned(
                        top: 0,
                        child: Transform.translate(
                          offset: Offset(0, _logoTranslateY.value),
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/logo.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Loading dashes underneath the logo
                      Positioned(
                        top: 158,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _dash(8),
                            const SizedBox(width: 4),
                            _dash(6),
                            const SizedBox(width: 4),
                            _dash(6),
                          ],
                        ),
                      ),

                      // Brand text reveal, positioned below the logo
                      Positioned(
                        top: 170,
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _textTranslateY.value),
                            child: SizedBox(
                              width: 250,
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: 'ParkIn',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Today',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: _kCyan,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ]),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
