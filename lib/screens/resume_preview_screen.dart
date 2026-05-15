import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/resume_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/section_card.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  bool _working = false;

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _working = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().currentResume;

    if (resume == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview & Export'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.go('/editor'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SectionCard(
              title: resume.title,
              subtitle:
                  'Template: ${resume.templateId == 'fresher' ? 'Fresher Spotlight' : 'ATS Professional'} • Completion ${resume.completionScore}%',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resume.fullName.isEmpty ? 'Add your name in the editor.' : resume.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resume.summary.isEmpty
                        ? 'Your summary will appear here after you add it in the form.'
                        : resume.summary,
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: _working
                            ? null
                            : () => _runAction(() => PdfService.shareResumePdf(resume)),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share PDF'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _working
                            ? null
                            : () => _runAction(() => PdfService.openSavedPdf(resume)),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open File'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PdfPreview(
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName: '${resume.title}.pdf',
                  build: (format) => PdfService.buildResumePdf(resume),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
