class ResumeModel {
  ResumeModel({
    required this.id,
    required this.title,
    required this.fullName,
    required this.headline,
    required this.targetRole,
    required this.email,
    required this.phone,
    required this.address,
    required this.profilePhotoPath,
    required this.linkedinUrl,
    required this.portfolioUrl,
    required this.summary,
    required this.skills,
    required this.focusKeywords,
    required this.education,
    required this.experience,
    required this.projects,
    required this.certifications,
    required this.templateId,
    required this.updatedAt,
  });

  factory ResumeModel.empty(String id) {
    return ResumeModel(
      id: id,
      title: 'Untitled Resume',
      fullName: '',
      headline: '',
      targetRole: '',
      email: '',
      phone: '',
      address: '',
      profilePhotoPath: '',
      linkedinUrl: '',
      portfolioUrl: '',
      summary: '',
      skills: const [],
      focusKeywords: const [],
      education: const [],
      experience: const [],
      projects: const [],
      certifications: const [],
      templateId: 'ats',
      updatedAt: DateTime.now(),
    );
  }

  factory ResumeModel.fromMap(Map<dynamic, dynamic> map) {
    return ResumeModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Resume',
      fullName: map['fullName'] as String? ?? '',
      headline: map['headline'] as String? ?? '',
      targetRole: map['targetRole'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      profilePhotoPath: map['profilePhotoPath'] as String? ?? '',
      linkedinUrl: map['linkedinUrl'] as String? ?? '',
      portfolioUrl: map['portfolioUrl'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      skills: List<String>.from(map['skills'] as List? ?? const []),
      focusKeywords: List<String>.from(map['focusKeywords'] as List? ?? const []),
      education: (map['education'] as List? ?? const [])
          .map((item) => EducationEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      experience: (map['experience'] as List? ?? const [])
          .map((item) => ExperienceEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      projects: (map['projects'] as List? ?? const [])
          .map((item) => ProjectEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      certifications: (map['certifications'] as List? ?? const [])
          .map((item) => CertificationEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      templateId: map['templateId'] as String? ?? 'ats',
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String fullName;
  final String headline;
  final String targetRole;
  final String email;
  final String phone;
  final String address;
  final String profilePhotoPath;
  final String linkedinUrl;
  final String portfolioUrl;
  final String summary;
  final List<String> skills;
  final List<String> focusKeywords;
  final List<EducationEntry> education;
  final List<ExperienceEntry> experience;
  final List<ProjectEntry> projects;
  final List<CertificationEntry> certifications;
  final String templateId;
  final DateTime updatedAt;

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      summary.trim().isNotEmpty &&
      skills.isNotEmpty &&
      (experience.isNotEmpty || projects.isNotEmpty);

  bool get hasOnlinePresence =>
      linkedinUrl.trim().isNotEmpty || portfolioUrl.trim().isNotEmpty;

  bool get hasProfilePhoto => profilePhotoPath.trim().isNotEmpty;

  bool get hasQuantifiedImpact {
    final numberMatcher = RegExp(r'\d');
    final experienceHighlights = experience.expand((entry) => entry.highlights);
    final projectHighlights = projects.expand((entry) => entry.highlights);
    return [...experienceHighlights, ...projectHighlights]
        .any(numberMatcher.hasMatch);
  }

  String get contactLine => [
        if (email.trim().isNotEmpty) email.trim(),
        if (phone.trim().isNotEmpty) phone.trim(),
        if (address.trim().isNotEmpty) address.trim(),
      ].join(' | ');

  String get linksLine => [
        if (linkedinUrl.trim().isNotEmpty) linkedinUrl.trim(),
        if (portfolioUrl.trim().isNotEmpty) portfolioUrl.trim(),
      ].join(' | ');

  String get displayRole {
    if (headline.trim().isNotEmpty) return headline.trim();
    if (targetRole.trim().isNotEmpty) return targetRole.trim();
    return '';
  }

  String get templateName => switch (templateId) {
        'fresher' => 'Fresher Spotlight',
        'executive' => 'Executive Edge',
        _ => 'ATS Professional',
      };

  String get _searchableContent {
    final parts = <String>[
      fullName,
      headline,
      targetRole,
      summary,
      ...skills,
      ...education.expand((entry) => [entry.degree, entry.institution, entry.details]),
      ...experience.expand((entry) => [
            entry.role,
            entry.company,
            entry.duration,
            ...entry.highlights,
          ]),
      ...projects.expand((entry) => [
            entry.name,
            entry.role,
            entry.tools,
            entry.url,
            ...entry.highlights,
          ]),
      ...certifications.expand((entry) => [entry.name, entry.issuer, entry.year]),
    ];

    return parts.join(' ').toLowerCase();
  }

  List<String> get matchedKeywords {
    final content = _searchableContent;
    return focusKeywords
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .where((item) => content.contains(item.toLowerCase()))
        .toList();
  }

  List<ResumeInsight> get atsInsights {
    final trimmedKeywords =
        focusKeywords.map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    final insights = <ResumeInsight>[
      ResumeInsight(
        title: 'Core contact info',
        detail: 'Recruiters need visible name, email, and phone details at a glance.',
        isPassing: fullName.trim().isNotEmpty &&
            email.trim().isNotEmpty &&
            phone.trim().isNotEmpty,
        weight: 15,
      ),
      ResumeInsight(
        title: 'Targeted role',
        detail: 'A headline or target role helps tailor the resume for a specific opening.',
        isPassing: displayRole.isNotEmpty,
        weight: 10,
      ),
      ResumeInsight(
        title: 'Strong summary',
        detail: 'Professional summaries work better when they explain value and direction quickly.',
        isPassing: summary.trim().length >= 80,
        weight: 15,
      ),
      ResumeInsight(
        title: 'Relevant skills',
        detail: 'A focused skill list helps ATS keyword matching and recruiter skim speed.',
        isPassing: skills.length >= 6,
        weight: 10,
      ),
      ResumeInsight(
        title: 'Proof of impact',
        detail: 'Numbers in bullet points signal measurable results and stronger achievements.',
        isPassing: hasQuantifiedImpact,
        weight: 15,
      ),
      ResumeInsight(
        title: 'Experience depth',
        detail: 'Modern builders usually support both work history and project-based proof.',
        isPassing: experience.isNotEmpty || projects.isNotEmpty,
        weight: 15,
      ),
      ResumeInsight(
        title: 'Supporting sections',
        detail: 'Projects, certifications, and education help round out a professional resume.',
        isPassing:
            education.isNotEmpty && (projects.isNotEmpty || certifications.isNotEmpty),
        weight: 10,
      ),
      ResumeInsight(
        title: 'Online presence',
        detail: 'LinkedIn or portfolio links are common in current resume builders.',
        isPassing: hasOnlinePresence,
        weight: 10,
      ),
    ];

    if (trimmedKeywords.isNotEmpty) {
      final requiredMatches =
          trimmedKeywords.length <= 3 ? 2 : (trimmedKeywords.length / 2).ceil();
      insights.add(
        ResumeInsight(
          title: 'Keyword alignment',
          detail:
              'Match key terms from the job target so ATS scanners can connect you to the role.',
          isPassing: matchedKeywords.length >= requiredMatches,
          weight: 10,
        ),
      );
    }

    return insights;
  }

  int get atsScore {
    final insights = atsInsights;
    final totalWeight = insights.fold<int>(0, (sum, item) => sum + item.weight);
    final passingWeight = insights
        .where((item) => item.isPassing)
        .fold<int>(0, (sum, item) => sum + item.weight);
    if (totalWeight == 0) return 0;
    return ((passingWeight / totalWeight) * 100).round();
  }

  int get completionScore {
    var score = 0;
    if (fullName.trim().isNotEmpty) score += 10;
    if (headline.trim().isNotEmpty || targetRole.trim().isNotEmpty) score += 10;
    if (email.trim().isNotEmpty) score += 8;
    if (phone.trim().isNotEmpty) score += 8;
    if (address.trim().isNotEmpty) score += 6;
    if (summary.trim().isNotEmpty) score += 14;
    if (skills.isNotEmpty) score += 12;
    if (education.isNotEmpty) score += 10;
    if (experience.isNotEmpty) score += 12;
    if (projects.isNotEmpty) score += 5;
    if (certifications.isNotEmpty) score += 5;
    return score;
  }

  ResumeModel copyWith({
    String? id,
    String? title,
    String? fullName,
    String? headline,
    String? targetRole,
    String? email,
    String? phone,
    String? address,
    String? profilePhotoPath,
    String? linkedinUrl,
    String? portfolioUrl,
    String? summary,
    List<String>? skills,
    List<String>? focusKeywords,
    List<EducationEntry>? education,
    List<ExperienceEntry>? experience,
    List<ProjectEntry>? projects,
    List<CertificationEntry>? certifications,
    String? templateId,
    DateTime? updatedAt,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      targetRole: targetRole ?? this.targetRole,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      focusKeywords: focusKeywords ?? this.focusKeywords,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      templateId: templateId ?? this.templateId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'headline': headline,
      'targetRole': targetRole,
      'email': email,
      'phone': phone,
      'address': address,
      'profilePhotoPath': profilePhotoPath,
      'linkedinUrl': linkedinUrl,
      'portfolioUrl': portfolioUrl,
      'summary': summary,
      'skills': skills,
      'focusKeywords': focusKeywords,
      'education': education.map((item) => item.toMap()).toList(),
      'experience': experience.map((item) => item.toMap()).toList(),
      'projects': projects.map((item) => item.toMap()).toList(),
      'certifications': certifications.map((item) => item.toMap()).toList(),
      'templateId': templateId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ResumeInsight {
  const ResumeInsight({
    required this.title,
    required this.detail,
    required this.isPassing,
    required this.weight,
  });

  final String title;
  final String detail;
  final bool isPassing;
  final int weight;
}

class EducationEntry {
  const EducationEntry({
    required this.degree,
    required this.institution,
    required this.year,
    required this.details,
  });

  factory EducationEntry.fromMap(Map<dynamic, dynamic> map) {
    return EducationEntry(
      degree: map['degree'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      year: map['year'] as String? ?? '',
      details: map['details'] as String? ?? '',
    );
  }

  final String degree;
  final String institution;
  final String year;
  final String details;

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'institution': institution,
      'year': year,
      'details': details,
    };
  }
}

class ExperienceEntry {
  const ExperienceEntry({
    required this.role,
    required this.company,
    required this.duration,
    required this.highlights,
  });

  factory ExperienceEntry.fromMap(Map<dynamic, dynamic> map) {
    return ExperienceEntry(
      role: map['role'] as String? ?? '',
      company: map['company'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      highlights: List<String>.from(map['highlights'] as List? ?? const []),
    );
  }

  final String role;
  final String company;
  final String duration;
  final List<String> highlights;

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'highlights': highlights,
    };
  }
}

class ProjectEntry {
  const ProjectEntry({
    required this.name,
    required this.role,
    required this.tools,
    required this.url,
    required this.highlights,
  });

  factory ProjectEntry.fromMap(Map<dynamic, dynamic> map) {
    return ProjectEntry(
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      tools: map['tools'] as String? ?? '',
      url: map['url'] as String? ?? '',
      highlights: List<String>.from(map['highlights'] as List? ?? const []),
    );
  }

  final String name;
  final String role;
  final String tools;
  final String url;
  final List<String> highlights;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'tools': tools,
      'url': url,
      'highlights': highlights,
    };
  }
}

class CertificationEntry {
  const CertificationEntry({
    required this.name,
    required this.issuer,
    required this.year,
  });

  factory CertificationEntry.fromMap(Map<dynamic, dynamic> map) {
    return CertificationEntry(
      name: map['name'] as String? ?? '',
      issuer: map['issuer'] as String? ?? '',
      year: map['year'] as String? ?? '',
    );
  }

  final String name;
  final String issuer;
  final String year;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'issuer': issuer,
      'year': year,
    };
  }
}
