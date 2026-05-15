import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume_model.dart';

List<pw.Widget> buildAtsTemplate(ResumeModel resume) {
  return [
    pw.Text(
      resume.fullName.isEmpty ? 'Your Name' : resume.fullName,
      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      [
        if (resume.email.isNotEmpty) resume.email,
        if (resume.phone.isNotEmpty) resume.phone,
        if (resume.address.isNotEmpty) resume.address,
      ].join('  |  '),
      style: const pw.TextStyle(fontSize: 10),
    ),
    pw.SizedBox(height: 18),
    _sectionTitle('Professional Summary'),
    pw.Text(
      resume.summary.isEmpty
          ? 'Add a focused summary to highlight your strengths.'
          : resume.summary,
      style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
    ),
    pw.SizedBox(height: 14),
    _sectionTitle('Skills'),
    pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: resume.skills.isEmpty
          ? [pw.Text('Add your core skills here.', style: const pw.TextStyle(fontSize: 11))]
          : resume.skills
              .map(
                (skill) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(skill, style: const pw.TextStyle(fontSize: 10)),
                ),
              )
              .toList(),
    ),
    pw.SizedBox(height: 14),
    _sectionTitle('Experience'),
    if (resume.experience.isEmpty)
      pw.Text('Add experience entries to showcase your impact.')
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
                  pw.Text(
                    entry.role,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.Text(entry.duration, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text(entry.company, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 4),
              ...entry.highlights.map(
                (highlight) => pw.Bullet(
                  text: highlight,
                  style: const pw.TextStyle(fontSize: 10.5),
                ),
              ),
            ],
          ),
        ),
      ),
    pw.SizedBox(height: 14),
    _sectionTitle('Education'),
    if (resume.education.isEmpty)
      pw.Text('Add education details to complete your profile.')
    else
      ...resume.education.map(
        (entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    entry.degree,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.Text(entry.year, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text(entry.institution, style: const pw.TextStyle(fontSize: 11)),
              if (entry.details.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(entry.details, style: const pw.TextStyle(fontSize: 10.5)),
                ),
            ],
          ),
        ),
      ),
  ];
}

pw.Widget _sectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, letterSpacing: 1.1),
    ),
  );
}
