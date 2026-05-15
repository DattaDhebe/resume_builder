import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/resume_model.dart';
import '../templates/ats_template.dart';
import '../templates/fresher_spotlight_template.dart';

class PdfService {
  static Future<Uint8List> buildResumePdf(ResumeModel resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
        ),
        build: (context) => switch (resume.templateId) {
          'fresher' => buildFresherTemplate(resume),
          _ => buildAtsTemplate(resume),
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> shareResumePdf(ResumeModel resume) async {
    final bytes = await buildResumePdf(resume);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _fileNameFor(resume),
    );
  }

  static Future<File> savePdfToFile(ResumeModel resume) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_fileNameFor(resume)}');
    final bytes = await buildResumePdf(resume);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> openSavedPdf(ResumeModel resume) async {
    final file = await savePdfToFile(resume);
    await OpenFilex.open(file.path);
  }

  static String _fileNameFor(ResumeModel resume) {
    final slug = resume.fullName.trim().isEmpty
        ? 'resume'
        : resume.fullName.trim().toLowerCase().replaceAll(' ', '_');
    final date = DateFormat('yyyyMMdd_HHmm').format(resume.updatedAt);
    return '${slug}_$date.pdf';
  }
}
