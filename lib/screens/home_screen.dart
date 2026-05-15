import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/resume_provider.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final resumes = provider.resumes;
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<ResumeProvider>().startNewResume();
          context.go('/editor');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('Resume Builder'),
            actions: [
              IconButton(
                tooltip: 'Choose template',
                onPressed: () {
                  if (provider.currentResume == null) {
                    provider.startNewResume();
                  }
                  context.go('/templates');
                },
                icon: const Icon(Icons.dashboard_customize_outlined),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F766E),
                          Color(0xFF155E75),
                          Color(0xFF164E63),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Design polished resumes, save multiple drafts, and export PDF files in minutes.',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricChip(label: 'Drafts', value: resumes.length.toString()),
                            _MetricChip(label: 'Ready', value: provider.completedCount.toString()),
                            const _MetricChip(label: 'Templates', value: '2'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    title: 'Quick Start',
                    subtitle: 'Pick up where you left off or launch a fresh draft.',
                    child: Column(
                      children: [
                        _QuickActionTile(
                          icon: Icons.edit_note_rounded,
                          title: 'Create a new resume',
                          subtitle: 'Start with a blank draft and fill in your profile.',
                          onTap: () {
                            context.read<ResumeProvider>().startNewResume();
                            context.go('/editor');
                          },
                        ),
                        const SizedBox(height: 12),
                        _QuickActionTile(
                          icon: Icons.style_outlined,
                          title: 'Choose a template',
                          subtitle: 'Switch between ATS and fresher-friendly layouts.',
                          onTap: () {
                            if (provider.currentResume == null) {
                              provider.startNewResume();
                            }
                            context.go('/templates');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    title: 'Saved Resumes',
                    subtitle: resumes.isEmpty
                        ? 'No drafts yet. Your first resume can start from the button below.'
                        : 'Tap any draft to continue editing or preview the final PDF.',
                    child: resumes.isEmpty
                        ? const _EmptyState()
                        : Column(
                            children: resumes
                                .map(
                                  (resume) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ResumeTile(resumeId: resume.id),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDBEAFE),
          child: Icon(icon, color: const Color(0xFF155E75)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.description_outlined, size: 44, color: Color(0xFF155E75)),
          const SizedBox(height: 12),
          Text('No saved resumes yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Create your first draft and it will appear here for quick editing.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({required this.resumeId});

  final String resumeId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    final resume = provider.resumes.firstWhere((item) => item.id == resumeId);

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: CircleAvatar(
          backgroundColor:
              resume.isComplete ? const Color(0xFFD1FAE5) : const Color(0xFFE0F2FE),
          child: Icon(
            resume.isComplete ? Icons.check_rounded : Icons.edit_document,
            color: const Color(0xFF155E75),
          ),
        ),
        title: Text(resume.title),
        subtitle: Text(
          '${resume.fullName.isEmpty ? 'Unnamed candidate' : resume.fullName} • ${DateFormat('dd MMM, hh:mm a').format(resume.updatedAt)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                context.read<ResumeProvider>().selectResume(resume.id);
                if (context.mounted) context.go('/editor');
              case 'preview':
                context.read<ResumeProvider>().selectResume(resume.id);
                if (context.mounted) context.go('/preview');
              case 'duplicate':
                await context.read<ResumeProvider>().duplicateResume(resume.id);
              case 'delete':
                await context.read<ResumeProvider>().deleteResume(resume.id);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'preview', child: Text('Preview PDF')),
            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
