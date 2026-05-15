import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume_model.dart';

List<pw.Widget> buildExecutiveTemplate(
  ResumeModel resume, {
  pw.MemoryImage? profileImage,
}) {
  return [
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#0B2242'),
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.fullName.isEmpty ? 'Your Name' : resume.fullName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (resume.displayRole.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    resume.displayRole,
                    style: pw.TextStyle(
                      fontSize: 11.5,
                      color: PdfColor.fromHex('#93C5FD'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
                if (resume.contactLine.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    resume.contactLine,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                  ),
                ],
                if (resume.linksLine.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    resume.linksLine,
                    style: const pw.TextStyle(fontSize: 9.6, color: PdfColors.white),
                  ),
                ],
              ],
            ),
          ),
          if (profileImage != null) ...[
            pw.SizedBox(width: 16),
            pw.Container(
              width: 76,
              height: 92,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(16),
                image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    ),
    pw.SizedBox(height: 18),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _title('Skills'),
                if (resume.skills.isEmpty)
                  pw.Text('Add role-focused skills.')
                else
                  ...resume.skills.map(
                    (skill) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text('- $skill', style: const pw.TextStyle(fontSize: 10.2)),
                    ),
                  ),
                if (resume.focusKeywords.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  _title('Keywords'),
                  ...resume.focusKeywords.map(
                    (keyword) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text(
                        keyword,
                        style: const pw.TextStyle(fontSize: 10.2),
                      ),
                    ),
                  ),
                ],
                if (resume.education.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  _title('Education'),
                  ...resume.education.map(
                    (entry) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            entry.degree,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10.8,
                            ),
                          ),
                          if (entry.institution.isNotEmpty)
                            pw.Text(
                              entry.institution,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          if (entry.year.isNotEmpty)
                            pw.Text(entry.year, style: const pw.TextStyle(fontSize: 9.8)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (resume.certifications.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  _title('Certifications'),
                  ...resume.certifications.map(
                    (entry) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Text(
                        '${entry.name}${entry.year.isEmpty ? '' : ' (${entry.year})'}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _title('Profile'),
              pw.Text(
                resume.summary.isEmpty
                    ? 'Add a leadership-oriented summary, outcomes, and strengths.'
                    : resume.summary,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
              ),
              pw.SizedBox(height: 14),
              _title('Experience'),
              if (resume.experience.isEmpty)
                pw.Text('Add work history with quantified outcomes.')
              else
                ...resume.experience.map(
                  (entry) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                '${entry.role}${entry.company.isEmpty ? '' : ' | ${entry.company}'}',
                                style: pw.TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            if (entry.duration.isNotEmpty)
                              pw.Text(
                                entry.duration,
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        ...entry.highlights.map(
                          (item) => pw.Bullet(
                            text: item,
                            style: const pw.TextStyle(fontSize: 10.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (resume.projects.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                _title('Projects'),
                ...resume.projects.map(
                  (entry) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          entry.name,
                          style: pw.TextStyle(
                            fontSize: 11.2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (entry.role.isNotEmpty || entry.tools.isNotEmpty)
                          pw.Text(
                            [
                              if (entry.role.isNotEmpty) entry.role,
                              if (entry.tools.isNotEmpty) entry.tools,
                            ].join(' | '),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        if (entry.url.isNotEmpty)
                          pw.Text(
                            entry.url,
                            style: pw.TextStyle(
                              fontSize: 9.8,
                              color: PdfColor.fromHex('#0E7490'),
                            ),
                          ),
                        pw.SizedBox(height: 3),
                        ...entry.highlights.map(
                          (item) => pw.Bullet(
                            text: item,
                            style: const pw.TextStyle(fontSize: 10.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  ];
}

pw.Widget _title(String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      value.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 1.1,
        color: PdfColor.fromHex('#0B2242'),
      ),
    ),
  );
}
