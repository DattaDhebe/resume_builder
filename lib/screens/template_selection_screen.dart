import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/resume_provider.dart';
import '../widgets/section_card.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final resume = provider.currentResume;

    if (resume == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Templates')),
        body: const Center(child: Text('Start a resume first to pick a template.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Template')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Template Gallery',
            subtitle: 'Choose an ATS-safe structure or a fresher-forward visual layout.',
            icon: Icons.view_quilt_outlined,
            child: Column(
              children: [
                _TemplateOption(
                  title: 'ATS Professional',
                  description: 'A clean one-column layout with strong readability for scanners and recruiters.',
                  selected: resume.templateId == 'ats',
                  accent: const Color(0xFF155E75),
                  onTap: () {
                    provider.updateCurrentResume(resume.copyWith(templateId: 'ats'));
                  },
                ),
                const SizedBox(height: 14),
                _TemplateOption(
                  title: 'Fresher Spotlight',
                  description: 'A softer visual layout that gives more weight to education, skills, and projects.',
                  selected: resume.templateId == 'fresher',
                  accent: const Color(0xFF0F766E),
                  onTap: () {
                    provider.updateCurrentResume(resume.copyWith(templateId: 'fresher'));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/preview'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Preview Resume'),
          ),
        ],
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  const _TemplateOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? accent : Colors.transparent, width: 1.4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.65)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}
