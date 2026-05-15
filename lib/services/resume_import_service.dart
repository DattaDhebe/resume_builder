import '../models/resume_model.dart';

class ResumeImportService {
  static final RegExp _emailPattern = RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );
  static final RegExp _urlPattern = RegExp(r'https?://\S+', caseSensitive: false);
  static final RegExp _phonePattern = RegExp(
    r'(\+?\d[\d\s().-]{7,}\d)',
    caseSensitive: false,
  );
  static final RegExp _yearPattern = RegExp(r'(19|20)\d{2}');
  static final RegExp _durationPattern = RegExp(
    r'(19|20)\d{2}|present|current|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec',
    caseSensitive: false,
  );

  static const Map<String, String> _sectionAliases = {
    'professional summary': 'summary',
    'summary': 'summary',
    'profile': 'summary',
    'career objective': 'summary',
    'objective': 'summary',
    'about': 'summary',
    'about me': 'summary',
    'skills': 'skills',
    'technical skills': 'skills',
    'core skills': 'skills',
    'key skills': 'skills',
    'competencies': 'skills',
    'experience': 'experience',
    'professional experience': 'experience',
    'work experience': 'experience',
    'employment history': 'experience',
    'education': 'education',
    'academic background': 'education',
    'projects': 'projects',
    'project experience': 'projects',
    'certifications': 'certifications',
    'certificates': 'certifications',
    'licenses': 'certifications',
  };

  static ResumeModel importFromText({
    required String rawText,
    required ResumeModel seed,
  }) {
    final normalized = rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    final lines = normalized.split('\n').map((item) => item.trim()).toList();
    final nonEmptyLines = lines.where((item) => item.isNotEmpty).toList();
    final sections = _splitSections(lines);
    final introLines = sections['intro'] ?? const <String>[];
    final urls = _urlPattern.allMatches(normalized).map((item) => item.group(0)!).toList();

    final name = seed.fullName.trim().isNotEmpty
        ? seed.fullName
        : _guessName(nonEmptyLines);
    final headline = seed.headline.trim().isNotEmpty
        ? seed.headline
        : _guessHeadline(nonEmptyLines, name);
    final email = _emailPattern.firstMatch(normalized)?.group(0) ?? seed.email;
    final phone = _phonePattern.firstMatch(normalized)?.group(0)?.trim() ?? seed.phone;
    final linkedinUrl = _firstWhere(
          urls,
          (item) => item.toLowerCase().contains('linkedin.com'),
        ) ??
        seed.linkedinUrl;
    final portfolioUrl = _firstWhere(
          urls,
          (item) => item != linkedinUrl,
        ) ??
        seed.portfolioUrl;

    final summaryLines = _firstNonEmptySection(
      sections,
      const ['summary'],
    );
    final skills = _parseTokenList(
      _firstNonEmptySection(sections, const ['skills']),
    );
    final experience = _parseExperience(
      _firstNonEmptySection(sections, const ['experience']),
    );
    final education = _parseEducation(
      _firstNonEmptySection(sections, const ['education']),
    );
    final projects = _parseProjects(
      _firstNonEmptySection(sections, const ['projects']),
    );
    final certifications = _parseCertifications(
      _firstNonEmptySection(sections, const ['certifications']),
    );
    final summary = summaryLines.isNotEmpty
        ? summaryLines.join(' ')
        : _guessSummary(introLines, name, headline);

    final focusKeywords = [
      ...skills.take(8),
      ..._parseTokenList([headline, seed.targetRole]).take(2),
    ].where((item) => item.trim().isNotEmpty).toSet().toList();

    final title = name.isEmpty ? seed.title : '$name Resume';
    final targetRole = seed.targetRole.trim().isNotEmpty ? seed.targetRole : headline;

    return seed.copyWith(
      title: seed.title == 'Untitled Resume' ? title : seed.title,
      fullName: name,
      headline: headline,
      targetRole: targetRole,
      email: email,
      phone: phone,
      linkedinUrl: linkedinUrl,
      portfolioUrl: portfolioUrl,
      summary: summary,
      skills: skills.isEmpty ? seed.skills : skills,
      focusKeywords: focusKeywords.isEmpty ? seed.focusKeywords : focusKeywords,
      education: education.isEmpty ? seed.education : education,
      experience: experience.isEmpty ? seed.experience : experience,
      projects: projects.isEmpty ? seed.projects : projects,
      certifications:
          certifications.isEmpty ? seed.certifications : certifications,
      updatedAt: DateTime.now(),
    );
  }

  static Map<String, List<String>> _splitSections(List<String> lines) {
    final sections = <String, List<String>>{'intro': []};
    var current = 'intro';

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final normalized = _normalizeHeading(line);
      final alias = _sectionAliases[normalized];
      if (alias != null) {
        current = alias;
        sections.putIfAbsent(current, () => <String>[]);
        continue;
      }

      sections.putIfAbsent(current, () => <String>[]).add(line);
    }

    return sections;
  }

  static List<String> _firstNonEmptySection(
    Map<String, List<String>> sections,
    List<String> keys,
  ) {
    for (final key in keys) {
      final lines = sections[key];
      if (lines != null && lines.isNotEmpty) {
        return lines;
      }
    }
    return const <String>[];
  }

  static String _guessName(List<String> lines) {
    for (final line in lines) {
      if (_looksLikeHeading(line) || _containsContactData(line)) {
        continue;
      }
      final words = line.split(RegExp(r'\s+'));
      if (words.length <= 4) {
        return line;
      }
    }
    return lines.isEmpty ? '' : lines.first;
  }

  static String _guessHeadline(List<String> lines, String name) {
    for (final line in lines) {
      if (line == name || _looksLikeHeading(line) || _containsContactData(line)) {
        continue;
      }
      if (line.split(RegExp(r'\s+')).length <= 10) {
        return line;
      }
      break;
    }
    return '';
  }

  static String _guessSummary(
    List<String> introLines,
    String name,
    String headline,
  ) {
    final lines = introLines
        .where((line) => line != name && line != headline && !_containsContactData(line))
        .take(3)
        .toList();
    return lines.join(' ');
  }

  static List<String> _parseTokenList(List<String> lines) {
    final items = <String>[];
    for (final line in lines) {
      final cleaned = line
          .replaceAll('•', ',')
          .replaceAll('|', ',')
          .replaceAll(';', ',')
          .replaceAll('/', ',');
      for (final token in cleaned.split(',')) {
        final value = token.replaceFirst(RegExp(r'^[-*\u2022]\s*'), '').trim();
        if (value.isNotEmpty && !items.contains(value)) {
          items.add(value);
        }
      }
    }
    return items;
  }

  static List<ExperienceEntry> _parseExperience(List<String> lines) {
    final blocks = _splitIntoBlocks(lines);
    return blocks
        .map((block) {
          final header = block.headers.isEmpty ? '' : block.headers.first;
          final parts = header.split(RegExp(r'\s+\|\s+|\s+-\s+|\s+at\s+', caseSensitive: false));
          final role = parts.isEmpty ? header : parts.first.trim();
          var company = parts.length > 1 ? parts.sublist(1).join(' | ').trim() : '';
          var duration = '';

          for (final line in block.headers.skip(1)) {
            if (duration.isEmpty && _durationPattern.hasMatch(line)) {
              duration = line;
            } else if (company.isEmpty) {
              company = line;
            }
          }

          final highlights = [
            ...block.bullets,
            if (block.bullets.isEmpty) ...block.headers.skip(1).where((line) => line != duration),
          ].where((item) => item.isNotEmpty).toList();

          if (role.isEmpty && company.isEmpty && highlights.isEmpty) {
            return null;
          }

          return ExperienceEntry(
            role: role,
            company: company,
            duration: duration,
            highlights: highlights,
          );
        })
        .whereType<ExperienceEntry>()
        .toList();
  }

  static List<EducationEntry> _parseEducation(List<String> lines) {
    final blocks = _splitIntoBlocks(lines);
    return blocks
        .map((block) {
          final degree = block.headers.isEmpty ? '' : block.headers.first;
          var institution = '';
          var year = '';

          for (final line in block.headers.skip(1)) {
            if (year.isEmpty && _yearPattern.hasMatch(line)) {
              year = _yearPattern.firstMatch(line)?.group(0) ?? '';
            } else if (institution.isEmpty) {
              institution = line;
            }
          }

          final details = block.bullets.join(' ');
          if (degree.isEmpty && institution.isEmpty && details.isEmpty) {
            return null;
          }

          return EducationEntry(
            degree: degree,
            institution: institution,
            year: year,
            details: details,
          );
        })
        .whereType<EducationEntry>()
        .toList();
  }

  static List<ProjectEntry> _parseProjects(List<String> lines) {
    final blocks = _splitIntoBlocks(lines);
    return blocks
        .map((block) {
          final name = block.headers.isEmpty ? '' : block.headers.first;
          var role = '';
          var tools = '';
          var url = '';

          for (final line in block.headers.skip(1)) {
            if (url.isEmpty && _urlPattern.hasMatch(line)) {
              url = _urlPattern.firstMatch(line)?.group(0) ?? '';
            } else if (role.isEmpty) {
              role = line;
            } else if (tools.isEmpty) {
              tools = line;
            }
          }

          final highlights = block.bullets;
          if (name.isEmpty && role.isEmpty && highlights.isEmpty) {
            return null;
          }

          return ProjectEntry(
            name: name,
            role: role,
            tools: tools,
            url: url,
            highlights: highlights,
          );
        })
        .whereType<ProjectEntry>()
        .toList();
  }

  static List<CertificationEntry> _parseCertifications(List<String> lines) {
    return lines
        .map((line) {
          final year = _yearPattern.firstMatch(line)?.group(0) ?? '';
          final cleaned = line.replaceAll(year, '').trim();
          final parts = cleaned.split(RegExp(r'\s+\|\s+|\s+-\s+'));
          final name = parts.isEmpty ? cleaned : parts.first.trim();
          final issuer = parts.length > 1 ? parts.sublist(1).join(' | ').trim() : '';
          if (name.isEmpty) return null;
          return CertificationEntry(name: name, issuer: issuer, year: year);
        })
        .whereType<CertificationEntry>()
        .toList();
  }

  static List<_SectionBlock> _splitIntoBlocks(List<String> lines) {
    final blocks = <_SectionBlock>[];
    var currentHeaders = <String>[];
    var currentBullets = <String>[];

    void flush() {
      if (currentHeaders.isNotEmpty || currentBullets.isNotEmpty) {
        blocks.add(_SectionBlock(currentHeaders, currentBullets));
      }
      currentHeaders = <String>[];
      currentBullets = <String>[];
    }

    for (final line in lines) {
      if (_isBullet(line)) {
        currentBullets.add(_cleanBullet(line));
        continue;
      }

      if (currentHeaders.isNotEmpty && currentBullets.isNotEmpty) {
        flush();
      }

      currentHeaders.add(line);
    }

    flush();
    return blocks;
  }

  static bool _isBullet(String value) {
    return value.startsWith('-') || value.startsWith('*') || value.startsWith('•');
  }

  static String _cleanBullet(String value) {
    return value.replaceFirst(RegExp(r'^[-*\u2022]\s*'), '').trim();
  }

  static String _normalizeHeading(String value) {
    return value.toLowerCase().replaceAll(':', '').trim();
  }

  static bool _looksLikeHeading(String value) {
    return _sectionAliases.containsKey(_normalizeHeading(value));
  }

  static bool _containsContactData(String value) {
    return _emailPattern.hasMatch(value) ||
        _phonePattern.hasMatch(value) ||
        _urlPattern.hasMatch(value);
  }

  static String? _firstWhere(List<String> values, bool Function(String) test) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }
}

class _SectionBlock {
  const _SectionBlock(this.headers, this.bullets);

  final List<String> headers;
  final List<String> bullets;
}
