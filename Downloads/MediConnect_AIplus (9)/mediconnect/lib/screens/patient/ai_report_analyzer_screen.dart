import 'package:flutter/material.dart';
import '../../widgets/art3d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/extra_models.dart';
import '../../services/ai_service.dart';

/// Upload flow is a demo trigger here (no real file picker wired yet).
/// To go live: `flutter pub add file_picker`, let the user pick a PDF,
/// upload it to your backend, extract text server-side, and pass that text
/// into AIService.analyzeReport (see backend/routes/aiRoutes.js for the
/// pdf-parsing + Groq call).
class AIReportAnalyzerScreen extends StatefulWidget {
  const AIReportAnalyzerScreen({super.key});
  @override
  State<AIReportAnalyzerScreen> createState() => _AIReportAnalyzerScreenState();
}

class _AIReportAnalyzerScreenState extends State<AIReportAnalyzerScreen> {
  bool _loading = false;
  ReportAnalysis? _result;
  String? _fileName;

  Future<void> _upload() async {
    setState(() {
      _fileName = 'Blood_Test_Report.pdf';
      _loading = true;
    });
    final r = await AIService.instance.analyzeReport(fileName: _fileName!);
    setState(() {
      _loading = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Report Analyzer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HeroBanner(title: 'Report Analyzer', subtitle: 'Upload a lab report and get a plain-language summary', icon: Icons.description_rounded, colors: [AppColors.accentGreen, AppColors.primaryBlue]),
          const SizedBox(height: 16),
          InkWell(
            onTap: _loading ? null : _upload,
            borderRadius: BorderRadius.circular(20),
            child: DottedBorderBox(
              child: Column(
                children: [
                  Icon(Icons.upload_file_rounded, size: 40, color: AppColors.primaryBlue.withOpacity(0.7)),
                  const SizedBox(height: 10),
                  Text(_fileName ?? 'Tap to upload PDF / Lab Report', style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          if (_loading) const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: CircularProgressIndicator())),
          if (_result != null) ...[
            const SizedBox(height: 22),
            _ResultBlock(title: 'Summary', icon: Icons.summarize_rounded, color: AppColors.primaryBlue, lines: [_result!.summary]),
            _ResultBlock(title: 'Abnormal Findings', icon: Icons.warning_amber_rounded, color: AppColors.moderate, lines: _result!.abnormalFindings),
            _ResultBlock(title: 'Recommendations', icon: Icons.check_circle_outline_rounded, color: AppColors.accentGreen, lines: _result!.recommendations),
          ],
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
      ),
      child: child,
    );
  }
}

class _ResultBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;
  const _ResultBlock({required this.title, required this.icon, required this.color, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.card3d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 8),
          ...lines.map((l) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('• $l', style: const TextStyle(color: AppColors.textMuted)))),
        ],
      ),
    ).animate().fadeIn();
  }
}
