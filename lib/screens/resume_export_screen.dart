import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/resume_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/insight_tile.dart';
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
                  'Template: ${resume.templateName} | Completion ${resume.completionScore}% | ATS ${resume.atsScore}%',
              icon: Icons.analytics_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resume.hasProfilePhoto) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(resume.profilePhotoPath),
                        width: 88,
                        height: 104,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 88,
                            height: 104,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.account_box_outlined),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    resume.fullName.isEmpty ? 'Add your name in the editor.' : resume.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (resume.displayRole.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      resume.displayRole,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0E7490),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    resume.summary.isEmpty
                        ? 'Your summary will appear here after you add it in the form.'
                        : resume.summary,
                  ),
                  if (resume.contactLine.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      resume.contactLine,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF48627D),
                          ),
                    ),
                  ],
                  if (resume.linksLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      resume.linksLine,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF0E7490),
                          ),
                    ),
                  ],
                  if (resume.focusKeywords.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: resume.focusKeywords
                          .map(
                            (keyword) => Chip(
                              label: Text(keyword),
                              backgroundColor: resume.matchedKeywords.contains(keyword)
                                  ? const Color(0xFFDFF7F0)
                                  : const Color(0xFFF4F7FB),
                              side: BorderSide(
                                color: resume.matchedKeywords.contains(keyword)
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFD6E0EA),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SectionCard(
              title: 'ATS Insights',
              subtitle:
                  'Rule-based quality checks inspired by the current ATS-friendly resume workflow.',
              icon: Icons.fact_check_outlined,
              child: Column(
                children: resume.atsInsights
                    .map(
                      (insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InsightTile(
                          title: insight.title,
                          detail: insight.detail,
                          isPassing: insight.isPassing,
                        ),
                      ),
                    )
                    .toList(),
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
