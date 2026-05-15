import 'package:hive/hive.dart';

import '../models/resume_model.dart';

class StorageService {
  static const _boxName = 'resume_box';
  static late Box<Map> _resumeBox;

  static Future<void> init() async {
    _resumeBox = await Hive.openBox<Map>(_boxName);
  }

  Future<List<ResumeModel>> fetchResumes() async {
    return _resumeBox.values
        .map((item) => ResumeModel.fromMap(item))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveResume(ResumeModel resume) async {
    await _resumeBox.put(resume.id, resume.toMap());
  }

  Future<void> deleteResume(String resumeId) async {
    await _resumeBox.delete(resumeId);
  }
}
