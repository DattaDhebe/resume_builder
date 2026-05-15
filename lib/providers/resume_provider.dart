import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/resume_model.dart';
import '../services/storage_service.dart';

class ResumeProvider extends ChangeNotifier {
  ResumeProvider({required this.storageService});

  final StorageService storageService;
  final Uuid _uuid = const Uuid();

  List<ResumeModel> _resumes = const [];
  ResumeModel? _currentResume;
  bool _isLoaded = false;

  List<ResumeModel> get resumes => _resumes;
  ResumeModel? get currentResume => _currentResume;
  bool get isLoaded => _isLoaded;
  int get completedCount => _resumes.where((item) => item.isComplete).length;
  int get averageAtsScore {
    if (_resumes.isEmpty) return 0;
    final total = _resumes.fold<int>(0, (sum, item) => sum + item.atsScore);
    return (total / _resumes.length).round();
  }

  Future<void> loadResumes() async {
    _resumes = await storageService.fetchResumes();
    _isLoaded = true;
    notifyListeners();
  }

  void startNewResume() {
    _currentResume = ResumeModel.empty(_uuid.v4());
    notifyListeners();
  }

  void selectResume(String resumeId) {
    _currentResume = _resumes.firstWhere((item) => item.id == resumeId);
    notifyListeners();
  }

  void updateCurrentResume(ResumeModel resume) {
    _currentResume = resume.copyWith(updatedAt: DateTime.now());
    notifyListeners();
  }

  Future<void> saveCurrentResume() async {
    final resume = _currentResume;
    if (resume == null) return;

    await storageService.saveResume(resume);

    final index = _resumes.indexWhere((item) => item.id == resume.id);
    if (index == -1) {
      _resumes = [resume, ..._resumes];
    } else {
      final updated = [..._resumes];
      updated[index] = resume;
      updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _resumes = updated;
    }

    notifyListeners();
  }

  Future<void> deleteResume(String resumeId) async {
    await storageService.deleteResume(resumeId);
    _resumes = _resumes.where((item) => item.id != resumeId).toList();
    if (_currentResume?.id == resumeId) {
      _currentResume = null;
    }
    notifyListeners();
  }

  Future<void> duplicateResume(String resumeId) async {
    final source = _resumes.firstWhere((item) => item.id == resumeId);
    final copy = source.copyWith(
      id: _uuid.v4(),
      title: '${source.title} Copy',
      updatedAt: DateTime.now(),
    );
    await storageService.saveResume(copy);
    _resumes = [copy, ..._resumes];
    notifyListeners();
  }
}
