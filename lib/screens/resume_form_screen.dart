import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../widgets/section_card.dart';

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillController = TextEditingController();

  List<String> _skills = [];
  List<EducationEntry> _education = [];
  List<ExperienceEntry> _experience = [];
  String _resumeId = '';
  String _templateId = 'ats';
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final provider = context.read<ResumeProvider>();
    final resume = provider.currentResume;
    if (resume == null) {
      provider.startNewResume();
    }

    final current = provider.currentResume!;
    _resumeId = current.id;
    _titleController.text = current.title;
    _nameController.text = current.fullName;
    _emailController.text = current.email;
    _phoneController.text = current.phone;
    _addressController.text = current.address;
    _summaryController.text = current.summary;
    _skills = [...current.skills];
    _education = [...current.education];
    _experience = [...current.experience];
    _initialized = true;
  }

  ResumeModel _buildResume() {
    _templateId = context.read<ResumeProvider>().currentResume?.templateId ?? _templateId;
    return ResumeModel(
      id: _resumeId,
      title: _titleController.text.trim().isEmpty ? 'Untitled Resume' : _titleController.text.trim(),
      fullName: _nameController.text.trim(),
      headline: '',
      targetRole: '',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      linkedinUrl: '',
      portfolioUrl: '',
      summary: _summaryController.text.trim(),
      skills: _skills,
      focusKeywords: const [],
      education: _education,
      experience: _experience,
      projects: const [],
      certifications: const [],
      templateId: _templateId,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveAndGo(String route) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ResumeProvider>();
    provider.updateCurrentResume(_buildResume());
    await provider.saveCurrentResume();
    if (mounted) context.go(route);
  }

  Future<void> _showEducationDialog({EducationEntry? existing, int? index}) async {
    final degreeController = TextEditingController(text: existing?.degree ?? '');
    final institutionController = TextEditingController(text: existing?.institution ?? '');
    final yearController = TextEditingController(text: existing?.year ?? '');
    final detailsController = TextEditingController(text: existing?.details ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Education' : 'Edit Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: degreeController, decoration: const InputDecoration(labelText: 'Degree')),
                const SizedBox(height: 12),
                TextField(controller: institutionController, decoration: const InputDecoration(labelText: 'Institution')),
                const SizedBox(height: 12),
                TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Year')),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final entry = EducationEntry(
                  degree: degreeController.text.trim(),
                  institution: institutionController.text.trim(),
                  year: yearController.text.trim(),
                  details: detailsController.text.trim(),
                );

                setState(() {
                  if (index == null) {
                    _education = [..._education, entry];
                  } else {
                    final items = [..._education];
                    items[index] = entry;
                    _education = items;
                  }
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    degreeController.dispose();
    institutionController.dispose();
    yearController.dispose();
    detailsController.dispose();
  }

  Future<void> _showExperienceDialog({ExperienceEntry? existing, int? index}) async {
    final roleController = TextEditingController(text: existing?.role ?? '');
    final companyController = TextEditingController(text: existing?.company ?? '');
    final durationController = TextEditingController(text: existing?.duration ?? '');
    final highlightsController = TextEditingController(text: existing?.highlights.join('\n') ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Experience' : 'Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role / Project')),
                const SizedBox(height: 12),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company / Organization')),
                const SizedBox(height: 12),
                TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration')),
                const SizedBox(height: 12),
                TextField(
                  controller: highlightsController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Highlights', hintText: 'One bullet per line'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final entry = ExperienceEntry(
                  role: roleController.text.trim(),
                  company: companyController.text.trim(),
                  duration: durationController.text.trim(),
                  highlights: highlightsController.text
                      .split('\n')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                );

                setState(() {
                  if (index == null) {
                    _experience = [..._experience, entry];
                  } else {
                    final items = [..._experience];
                    items[index] = entry;
                    _experience = items;
                  }
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    roleController.dispose();
    companyController.dispose();
    durationController.dispose();
    highlightsController.dispose();
  }

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty) return;

    setState(() {
      _skills = [..._skills, value];
      _skillController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Details'),
        actions: [
          TextButton(onPressed: () => _saveAndGo('/preview'), child: const Text('Preview')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SectionCard(
              title: 'Profile Basics',
              subtitle: 'Start with the resume name and your primary contact details.',
              child: Column(
                children: [
                  TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Resume Title')),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter your phone' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Summary',
              subtitle: 'Keep it focused on strengths, goals, and measurable value.',
              child: TextFormField(
                controller: _summaryController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Professional Summary', alignLabelWithHint: true),
                validator: (value) => value == null || value.trim().isEmpty ? 'Add a short summary' : null,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Skills',
              subtitle: 'Add one skill at a time. Examples: Flutter, UI Design, Java.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration: const InputDecoration(labelText: 'Add Skill'),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(onPressed: _addSkill, child: const Text('Add')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map(
                            (skill) => InputChip(
                              label: Text(skill),
                              onDeleted: () {
                                setState(() {
                                  _skills = _skills.where((item) => item != skill).toList();
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Education',
              subtitle: 'Capture degree, college, year, and any standout achievement.',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () => _showEducationDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Education'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._education.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InfoTile(
                        title: entry.value.degree,
                        subtitle: '${entry.value.institution} • ${entry.value.year}',
                        details: entry.value.details,
                        onEdit: () => _showEducationDialog(existing: entry.value, index: entry.key),
                        onDelete: () {
                          setState(() {
                            _education = [..._education]..removeAt(entry.key);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Experience',
              subtitle: 'Add jobs, internships, projects, or volunteer experience.',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () => _showExperienceDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Experience'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._experience.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InfoTile(
                        title: entry.value.role,
                        subtitle: '${entry.value.company} • ${entry.value.duration}',
                        details: entry.value.highlights.join('\n'),
                        onEdit: () => _showExperienceDialog(existing: entry.value, index: entry.key),
                        onDelete: () {
                          setState(() {
                            _experience = [..._experience]..removeAt(entry.key);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Template',
              subtitle: _templateId == 'fresher' ? 'Fresher Spotlight is active.' : 'ATS Professional is active.',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<ResumeProvider>().updateCurrentResume(_buildResume());
                        context.go('/templates');
                      },
                      icon: const Icon(Icons.style_outlined),
                      label: const Text('Change Template'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => _saveAndGo('/'), child: const Text('Save Draft')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: () => _saveAndGo('/preview'), child: const Text('Preview PDF')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final String details;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title.isEmpty ? 'Untitled' : title),
        subtitle: Text(details.isEmpty ? subtitle : '$subtitle\n$details'),
        isThreeLine: details.isNotEmpty,
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
