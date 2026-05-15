import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../widgets/insight_tile.dart';
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
  final _headlineController = TextEditingController();
  final _targetRoleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillController = TextEditingController();
  final _keywordController = TextEditingController();

  List<String> _skills = [];
  List<String> _focusKeywords = [];
  List<EducationEntry> _education = [];
  List<ExperienceEntry> _experience = [];
  List<ProjectEntry> _projects = [];
  List<CertificationEntry> _certifications = [];
  String _resumeId = '';
  String _templateId = 'ats';
  bool _initialized = false;

  List<TextEditingController> get _trackedControllers => [
        _titleController,
        _nameController,
        _headlineController,
        _targetRoleController,
        _emailController,
        _phoneController,
        _addressController,
        _linkedinController,
        _portfolioController,
        _summaryController,
      ];

  @override
  void initState() {
    super.initState();
    for (final controller in _trackedControllers) {
      controller.addListener(_handleFieldChange);
    }
  }

  @override
  void dispose() {
    for (final controller in _trackedControllers) {
      controller.removeListener(_handleFieldChange);
      controller.dispose();
    }
    _skillController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _handleFieldChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final provider = context.read<ResumeProvider>();
    if (provider.currentResume == null) {
      provider.startNewResume();
    }

    final current = provider.currentResume!;
    _resumeId = current.id;
    _templateId = current.templateId;
    _titleController.text = current.title;
    _nameController.text = current.fullName;
    _headlineController.text = current.headline;
    _targetRoleController.text = current.targetRole;
    _emailController.text = current.email;
    _phoneController.text = current.phone;
    _addressController.text = current.address;
    _linkedinController.text = current.linkedinUrl;
    _portfolioController.text = current.portfolioUrl;
    _summaryController.text = current.summary;
    _skills = [...current.skills];
    _focusKeywords = [...current.focusKeywords];
    _education = [...current.education];
    _experience = [...current.experience];
    _projects = [...current.projects];
    _certifications = [...current.certifications];
    _initialized = true;
  }

  ResumeModel _buildResume() {
    _templateId = context.read<ResumeProvider>().currentResume?.templateId ?? _templateId;
    return ResumeModel(
      id: _resumeId,
      title: _titleController.text.trim().isEmpty
          ? 'Untitled Resume'
          : _titleController.text.trim(),
      fullName: _nameController.text.trim(),
      headline: _headlineController.text.trim(),
      targetRole: _targetRoleController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      linkedinUrl: _linkedinController.text.trim(),
      portfolioUrl: _portfolioController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: _skills,
      focusKeywords: _focusKeywords,
      education: _education,
      experience: _experience,
      projects: _projects,
      certifications: _certifications,
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

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty || _skills.contains(value)) return;

    setState(() {
      _skills = [..._skills, value];
      _skillController.clear();
    });
  }

  void _addKeyword() {
    final value = _keywordController.text.trim();
    if (value.isEmpty || _focusKeywords.contains(value)) return;

    setState(() {
      _focusKeywords = [..._focusKeywords, value];
      _keywordController.clear();
    });
  }

  List<String> _suggestedKeywords(String role) {
    final normalized = role.toLowerCase();
    if (normalized.contains('developer') || normalized.contains('flutter')) {
      return [
        'Flutter',
        'Dart',
        'REST APIs',
        'Firebase',
        'State Management',
        'Performance Optimization',
      ];
    }
    if (normalized.contains('designer')) {
      return [
        'Figma',
        'Wireframing',
        'Design Systems',
        'Prototyping',
        'User Research',
        'Accessibility',
      ];
    }
    if (normalized.contains('manager')) {
      return [
        'Stakeholder Management',
        'Roadmapping',
        'Budgeting',
        'Risk Management',
        'Cross-functional Leadership',
        'Reporting',
      ];
    }
    return [
      'Communication',
      'Problem Solving',
      'Leadership',
      'Project Management',
      'Collaboration',
      'Data Analysis',
    ];
  }

  Future<void> _showEducationDialog({EducationEntry? existing, int? index}) async {
    final degreeController = TextEditingController(text: existing?.degree ?? '');
    final institutionController =
        TextEditingController(text: existing?.institution ?? '');
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
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(labelText: 'Degree'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: institutionController,
                  decoration: const InputDecoration(labelText: 'Institution'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
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
    final durationController =
        TextEditingController(text: existing?.duration ?? '');
    final highlightsController =
        TextEditingController(text: existing?.highlights.join('\n') ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Experience' : 'Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyController,
                  decoration:
                      const InputDecoration(labelText: 'Company / Organization'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: highlightsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Highlights',
                    hintText: 'One bullet per line',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
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

  Future<void> _showProjectDialog({ProjectEntry? existing, int? index}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final roleController = TextEditingController(text: existing?.role ?? '');
    final toolsController = TextEditingController(text: existing?.tools ?? '');
    final urlController = TextEditingController(text: existing?.url ?? '');
    final highlightsController =
        TextEditingController(text: existing?.highlights.join('\n') ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Project' : 'Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Your Role'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: toolsController,
                  decoration: const InputDecoration(labelText: 'Tools / Stack'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Project URL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: highlightsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Highlights',
                    hintText: 'One bullet per line',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final entry = ProjectEntry(
                  name: nameController.text.trim(),
                  role: roleController.text.trim(),
                  tools: toolsController.text.trim(),
                  url: urlController.text.trim(),
                  highlights: highlightsController.text
                      .split('\n')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                );

                setState(() {
                  if (index == null) {
                    _projects = [..._projects, entry];
                  } else {
                    final items = [..._projects];
                    items[index] = entry;
                    _projects = items;
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

    nameController.dispose();
    roleController.dispose();
    toolsController.dispose();
    urlController.dispose();
    highlightsController.dispose();
  }

  Future<void> _showCertificationDialog({
    CertificationEntry? existing,
    int? index,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final issuerController = TextEditingController(text: existing?.issuer ?? '');
    final yearController = TextEditingController(text: existing?.year ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null ? 'Add Certification' : 'Edit Certification',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Certification'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: issuerController,
                  decoration: const InputDecoration(labelText: 'Issuer'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final entry = CertificationEntry(
                  name: nameController.text.trim(),
                  issuer: issuerController.text.trim(),
                  year: yearController.text.trim(),
                );

                setState(() {
                  if (index == null) {
                    _certifications = [..._certifications, entry];
                  } else {
                    final items = [..._certifications];
                    items[index] = entry;
                    _certifications = items;
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

    nameController.dispose();
    issuerController.dispose();
    yearController.dispose();
  }

  Widget _buildProfileBasicsSection() {
    return SectionCard(
      title: 'Profile Basics',
      subtitle: 'Core identity, contact details, and the resume title itself.',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Resume Title'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter your email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter your phone' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTargetingSection(List<String> keywordSuggestions) {
    return SectionCard(
      title: 'Role Targeting',
      subtitle:
          'Target role, links, and keywords make the resume easier to tailor job by job.',
      icon: Icons.track_changes_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: _headlineController,
            decoration: const InputDecoration(
              labelText: 'Professional Headline',
              hintText: 'Flutter Developer | Mobile Product Engineer',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _targetRoleController,
            decoration: const InputDecoration(
              labelText: 'Target Role',
              hintText: 'Senior Flutter Developer',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _linkedinController,
            decoration: const InputDecoration(labelText: 'LinkedIn URL'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _portfolioController,
            decoration: const InputDecoration(labelText: 'Portfolio / Website URL'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: const InputDecoration(
                    labelText: 'Add Focus Keyword',
                    hintText: 'ATS, REST API, Leadership',
                  ),
                  onSubmitted: (_) => _addKeyword(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _addKeyword,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _focusKeywords
                  .map(
                    (keyword) => InputChip(
                      label: Text(keyword),
                      onDeleted: () {
                        setState(() {
                          _focusKeywords =
                              _focusKeywords.where((item) => item != keyword).toList();
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Suggested keywords', style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywordSuggestions
                  .where((item) => !_focusKeywords.contains(item))
                  .map(
                    (keyword) => ActionChip(
                      label: Text(keyword),
                      onPressed: () {
                        setState(() {
                          _focusKeywords = [..._focusKeywords, keyword];
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return SectionCard(
      title: 'Summary',
      subtitle: 'Keep it concise, specific, and oriented around outcomes.',
      icon: Icons.subject_outlined,
      child: TextFormField(
        controller: _summaryController,
        minLines: 5,
        maxLines: 7,
        decoration: const InputDecoration(
          labelText: 'Professional Summary',
          alignLabelWithHint: true,
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Add a short summary' : null,
      ),
    );
  }

  Widget _buildSkillsSection() {
    return SectionCard(
      title: 'Skills',
      subtitle: 'Use role-relevant skills that recruiters and ATS tools expect to see.',
      icon: Icons.psychology_alt_outlined,
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
              FilledButton(
                onPressed: _addSkill,
                child: const Text('Add'),
              ),
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
    );
  }

  Widget _buildTemplateSection() {
    return SectionCard(
      title: 'Template',
      subtitle: _templateId == 'fresher'
          ? 'Fresher Spotlight is active.'
          : 'ATS Professional is active.',
      icon: Icons.dashboard_customize_outlined,
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
    );
  }

  Widget _buildEducationSection() {
    return SectionCard(
      title: 'Education',
      subtitle: 'Capture degree, college, year, and standout academic proof.',
      icon: Icons.school_outlined,
      action: FilledButton.tonalIcon(
        onPressed: () => _showEducationDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
      ),
      child: Column(
        children: _education.isEmpty
            ? const [_EmptySection(message: 'Add at least one education entry.')]
            : _education
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoTile(
                      title: entry.value.degree,
                      subtitle: '${entry.value.institution} | ${entry.value.year}',
                      details: entry.value.details,
                      onEdit: () => _showEducationDialog(
                        existing: entry.value,
                        index: entry.key,
                      ),
                      onDelete: () {
                        setState(() {
                          _education = [..._education]..removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return SectionCard(
      title: 'Experience',
      subtitle: 'Use action-led bullet points and quantify results where possible.',
      icon: Icons.work_outline_rounded,
      action: FilledButton.tonalIcon(
        onPressed: () => _showExperienceDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
      ),
      child: Column(
        children: _experience.isEmpty
            ? const [_EmptySection(message: 'Add work, internship, or volunteer experience.')]
            : _experience
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoTile(
                      title: entry.value.role,
                      subtitle: '${entry.value.company} | ${entry.value.duration}',
                      details: entry.value.highlights.join('\n'),
                      onEdit: () => _showExperienceDialog(
                        existing: entry.value,
                        index: entry.key,
                      ),
                      onDelete: () {
                        setState(() {
                          _experience = [..._experience]..removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return SectionCard(
      title: 'Projects',
      subtitle:
          'Project sections are especially common for tech, student, and transition resumes.',
      icon: Icons.rocket_launch_outlined,
      action: FilledButton.tonalIcon(
        onPressed: () => _showProjectDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
      ),
      child: Column(
        children: _projects.isEmpty
            ? const [_EmptySection(message: 'Add portfolio or practical projects.')]
            : _projects
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoTile(
                      title: entry.value.name,
                      subtitle: [
                        if (entry.value.role.isNotEmpty) entry.value.role,
                        if (entry.value.tools.isNotEmpty) entry.value.tools,
                      ].join(' | '),
                      details: [
                        if (entry.value.url.isNotEmpty) entry.value.url,
                        ...entry.value.highlights,
                      ].join('\n'),
                      onEdit: () => _showProjectDialog(
                        existing: entry.value,
                        index: entry.key,
                      ),
                      onDelete: () {
                        setState(() {
                          _projects = [..._projects]..removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return SectionCard(
      title: 'Certifications',
      subtitle: 'Certifications and training help validate specialized or recent skills.',
      icon: Icons.verified_outlined,
      action: FilledButton.tonalIcon(
        onPressed: () => _showCertificationDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
      ),
      child: Column(
        children: _certifications.isEmpty
            ? const [_EmptySection(message: 'Add certifications, courses, or licenses.')]
            : _certifications
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoTile(
                      title: entry.value.name,
                      subtitle: '${entry.value.issuer} | ${entry.value.year}',
                      details: '',
                      onEdit: () => _showCertificationDialog(
                        existing: entry.value,
                        index: entry.key,
                      ),
                      onDelete: () {
                        setState(() {
                          _certifications = [..._certifications]..removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _buildResume();
    final insights = draft.atsInsights;
    final keywordSuggestions = _suggestedKeywords(_targetRoleController.text.trim());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Studio'),
        actions: [
          TextButton(
            onPressed: () => _saveAndGo('/preview'),
            child: const Text('Preview'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
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
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    draft.displayRole.isEmpty
                        ? 'Shape this resume for a specific role and strengthen it section by section.'
                        : 'Targeting ${draft.displayRole}. Build a tighter, more ATS-ready resume as you go.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ScoreCard(
                        label: 'Completion',
                        value: '${draft.completionScore}%',
                        detail: 'Profile completeness',
                      ),
                      _ScoreCard(
                        label: 'ATS Readiness',
                        value: '${draft.atsScore}%',
                        detail: 'Rule-based scan',
                      ),
                      _ScoreCard(
                        label: 'Keyword Match',
                        value: draft.focusKeywords.isEmpty
                            ? '--'
                            : '${draft.matchedKeywords.length}/${draft.focusKeywords.length}',
                        detail: 'Target keyword coverage',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'ATS Readiness',
              subtitle:
                  'Review the resume the way modern builders often surface ATS and quality checks.',
              icon: Icons.fact_check_outlined,
              accentColor: const Color(0xFF0E7490),
              child: Column(
                children: insights
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
            const SizedBox(height: 16),
            _buildProfileBasicsSection(),
            const SizedBox(height: 16),
            _buildRoleTargetingSection(keywordSuggestions),
            const SizedBox(height: 16),
            _buildSummarySection(),
            const SizedBox(height: 16),
            _buildSkillsSection(),
            const SizedBox(height: 16),
            _buildEducationSection(),
            const SizedBox(height: 16),
            _buildExperienceSection(),
            const SizedBox(height: 16),
            _buildProjectsSection(),
            const SizedBox(height: 16),
            _buildCertificationsSection(),
            const SizedBox(height: 16),
            _buildTemplateSection(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveAndGo('/'),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _saveAndGo('/preview'),
                    child: const Text('Preview PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF48627D),
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
