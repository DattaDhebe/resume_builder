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
    final activeResume = provider.currentResume;
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
            title: const Text('DResume'),
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
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0B2242),
                          Color(0xFF12396B),
                          Color(0xFF0E7490),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x220B2242),
                          blurRadius: 30,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Image.asset(
                                'assets/images/dresume_icon.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.description_rounded,
                                    size: 36,
                                    color: Color(0xFF155E75),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Professional resumes, faster.',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Build ATS-ready drafts, add project and certification proof, and export polished PDFs from one focused studio.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricChip(label: 'Drafts', value: resumes.length.toString()),
                            _MetricChip(label: 'Ready', value: provider.completedCount.toString()),
                            _MetricChip(label: 'Avg ATS', value: '${provider.averageAtsScore}%'),
                            const _MetricChip(label: 'Templates', value: '3'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: () {
                                context.read<ResumeProvider>().startNewResume();
                                context.go('/editor');
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Start New'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/import'),
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Import Resume'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (activeResume != null) ...[
                    SectionCard(
                      title: 'Current Focus',
                      subtitle:
                          activeResume.displayRole.isEmpty ? 'No target role yet.' : activeResume.displayRole,
                      icon: Icons.my_location_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activeResume.atsScore}% ATS readiness',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF0B2242),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeResume.summary.isEmpty
                                ? 'Open the editor to add a focused summary, keywords, projects, and certifications.'
                                : activeResume.summary,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF48627D),
                                  height: 1.45,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: () => context.go('/editor'),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Continue Editing'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/preview'),
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: const Text('Preview PDF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SectionCard(
                    title: 'Feature Highlights',
                    subtitle: 'These are the higher-value resume features now built into DResume.',
                    icon: Icons.auto_awesome_outlined,
                    child: Column(
                      children: const [
                        _FeatureTile(
                          title: 'ATS readiness scan',
                          detail: 'See rule-based guidance for contact info, summary strength, quantified impact, links, and keyword alignment.',
                        ),
                        SizedBox(height: 12),
                        _FeatureTile(
                          title: 'Role-targeted resumes',
                          detail: 'Add target roles, focus keywords, LinkedIn, portfolio links, and tailor the resume for each application.',
                        ),
                        SizedBox(height: 12),
                        _FeatureTile(
                          title: 'Projects and certifications',
                          detail: 'Show practical proof beyond work history, especially useful for students, developers, and career changers.',
                        ),
                        SizedBox(height: 12),
                        _FeatureTile(
                          title: 'Photo and import ready',
                          detail: 'Add a profile photo for visual templates or paste an existing resume to generate a new editable draft quickly.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    title: 'Saved Resumes',
                    subtitle: resumes.isEmpty
                        ? 'No drafts yet. Create your first resume to start building your library.'
                        : 'Open a draft to continue editing, review ATS readiness, or export PDF.',
                    icon: Icons.folder_copy_outlined,
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
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
          '${resume.displayRole.isEmpty ? (resume.fullName.isEmpty ? 'Untitled candidate' : resume.fullName) : resume.displayRole} | ${DateFormat('dd MMM, hh:mm a').format(resume.updatedAt)} | ATS ${resume.atsScore}%',
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
