import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/resume_provider.dart';
import '../services/resume_import_service.dart';
import '../widgets/section_card.dart';

class ResumeImportScreen extends StatefulWidget {
  const ResumeImportScreen({super.key});

  @override
  State<ResumeImportScreen> createState() => _ResumeImportScreenState();
}

class _ResumeImportScreenState extends State<ResumeImportScreen> {
  final _textController = TextEditingController();
  bool _working = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _importResume() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _working = true);
    try {
      final provider = context.read<ResumeProvider>();
      provider.startNewResume();
      final seed = provider.currentResume!;
      final imported = ResumeImportService.importFromText(
        rawText: text,
        seed: seed,
      );
      provider.updateCurrentResume(imported);
      await provider.saveCurrentResume();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume imported into a new draft.')),
      );
      context.go('/editor');
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Existing Resume')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Paste Resume Text',
            subtitle:
                'Copy text from a PDF, Word document, LinkedIn export, or old resume and DResume will map the sections into a new draft.',
            icon: Icons.upload_file_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Best results: keep headings like Summary, Skills, Experience, Education, Projects, and Certifications in the text you paste.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF48627D),
                          height: 1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 16,
                  maxLines: 22,
                  decoration: const InputDecoration(
                    labelText: 'Resume Text',
                    alignLabelWithHint: true,
                    hintText:
                        'Paste your existing resume text here. DResume will extract contact info, skills, experience, education, projects, and certifications.',
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _working ? null : _importResume,
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: Text(_working ? 'Importing...' : 'Import to New Draft'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _working ? null : () => context.go('/'),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
