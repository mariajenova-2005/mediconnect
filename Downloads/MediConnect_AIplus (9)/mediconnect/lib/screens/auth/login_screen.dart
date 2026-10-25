import 'package:flutter/material.dart';
import '../../widgets/fx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/auth_service.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.patient;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final ok = await AuthService.instance.login(email: _email.text, password: _password.text, role: _role);
    setState(() => _loading = false);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.instance.lastError ?? 'Could not sign in')));
      return;
    }
    Widget target = switch (_role) {
      UserRole.patient => const PatientDashboard(),
      UserRole.doctor => const DoctorDashboard(),
      UserRole.admin => const AdminDashboardScreen(),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: DnaHelix(width: 70, height: 90)),
              const SizedBox(height: 8),
              const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const Text('Sign in to MediConnect AI+', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.card3d),
                child: Row(
                  children: UserRole.values.map((r) {
                    final selected = r == _role;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(gradient: selected ? AppColors.heroGradient : null, borderRadius: BorderRadius.circular(12)),
                          child: Text(r.name[0].toUpperCase() + r.name.substring(1), textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
              TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 14),
              TextField(controller: _password, obscureText: true, decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded))),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text("Don't have an account? Register"),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
