import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/local_backend.dart';
import 'widgets/fx.dart';

// For a live backend, initialize Firebase here before runApp():
// import 'package:firebase_core/firebase_core.dart';
// WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalBackend.instance.init();
  runApp(const MediConnectApp());
}

class MediConnectApp extends StatelessWidget {
  const MediConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Stack(fit: StackFit.expand, children: [const LightBackdrop(), if (child != null) child]),
      home: const SplashScreen(),
    );
  }
}
