import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/fx.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, a, __) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const DnaHelix(width: 110, height: 170).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack, duration: 900.ms),
            const SizedBox(height: 6),
            const Text('MediConnect', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 1))
                .animate().fadeIn(delay: 500.ms).moveY(begin: 16, end: 0),
            const SizedBox(height: 6),
            const Text('AI+ · Care, connected instantly', style: TextStyle(color: Colors.white70)).animate().fadeIn(delay: 900.ms),
          ]),
        ),
      ),
    );
  }
}
