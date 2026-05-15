class ResumeModel {
  ResumeModel({
    required this.id,
    required this.title,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    required this.skills,
    required this.education,
    required this.experience,
    required this.templateId,
    required this.updatedAt,
  });

  factory ResumeModel.empty(String id) {
    return ResumeModel(
      id: id,
      title: 'Untitled Resume',
      fullName: '',
      email: '',
      phone: '',
      address: '',
      summary: '',
      skills: const [],
      education: const [],
      experience: const [],
      templateId: 'ats',
      updatedAt: DateTime.now(),
    );
  }

  factory ResumeModel.fromMap(Map<dynamic, dynamic> map) {
    return ResumeModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Resume',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      skills: List<String>.from(map['skills'] as List? ?? const []),
      education: (map['education'] as List? ?? const [])
          .map((item) => EducationEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      experience: (map['experience'] as List? ?? const [])
          .map((item) => ExperienceEntry.fromMap(item as Map<dynamic, dynamic>))
          .toList(),
      templateId: map['templateId'] as String? ?? 'ats',
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String summary;
  final List<String> skills;
  final List<EducationEntry> education;
  final List<ExperienceEntry> experience;
  final String templateId;
  final DateTime updatedAt;

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      summary.trim().isNotEmpty &&
      skills.isNotEmpty;

  int get completionScore {
    var score = 0;
    if (fullName.trim().isNotEmpty) score += 15;
    if (email.trim().isNotEmpty) score += 10;
    if (phone.trim().isNotEmpty) score += 10;
    if (address.trim().isNotEmpty) score += 10;
    if (summary.trim().isNotEmpty) score += 20;
    if (skills.isNotEmpty) score += 15;
    if (education.isNotEmpty) score += 10;
    if (experience.isNotEmpty) score += 10;
    return score;
  }

  ResumeModel copyWith({
    String? id,
    String? title,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? summary,
    List<String>? skills,
    List<EducationEntry>? education,
    List<ExperienceEntry>? experience,
    String? templateId,
    DateTime? updatedAt,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      templateId: templateId ?? this.templateId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'summary': summary,
      'skills': skills,
      'education': education.map((item) => item.toMap()).toList(),
      'experience': experience.map((item) => item.toMap()).toList(),
      'templateId': templateId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
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
