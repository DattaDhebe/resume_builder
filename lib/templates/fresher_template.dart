import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume_model.dart';

List<pw.Widget> buildFresherTemplate(ResumeModel resume) {
  return [
    pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E6F4F8'),
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            resume.fullName.isEmpty ? 'Your Name' : resume.fullName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F4C5C'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            resume.summary.isEmpty
                ? 'A crisp introduction helps recruiters quickly understand your goals.'
                : resume.summary,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            [
              if (resume.email.isNotEmpty) resume.email,
              if (resume.phone.isNotEmpty) resume.phone,
              if (resume.address.isNotEmpty) resume.address,
            ].join('  |  '),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    ),
    pw.SizedBox(height: 18),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _title('Education'),
              if (resume.education.isEmpty)
                pw.Text('Show your degree, college, and achievements.')
              else
                ...resume.education.map(
                  (entry) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          entry.degree,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11.5),
                        ),
                        pw.Text('${entry.institution} | ${entry.year}'),
                        if (entry.details.isNotEmpty) pw.Text(entry.details),
                      ],
                    ),
                  ),
                ),
              pw.SizedBox(height: 14),
              _title('Projects / Experience'),
              if (resume.experience.isEmpty)
                pw.Text('Add internships, projects, or volunteer work.')
              else
                ...resume.experience.map(
                  (entry) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${entry.role} - ${entry.company}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11.5),
                        ),
                        pw.Text(entry.duration),
                        pw.SizedBox(height: 2),
                        ...entry.highlights.map(
                          (item) => pw.Bullet(text: item, style: const pw.TextStyle(fontSize: 10.2)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        pw.SizedBox(width: 18),
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _title('Skills'),
                if (resume.skills.isEmpty)
                  pw.Text('List tools, technologies, and strengths.')
                else
                  ...resume.skills.map(
                    (skill) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text('• $skill'),
                    ),
                  ),
              ],
            ),
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
      value,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#0F4C5C'),
      ),
    ),
  );
}
