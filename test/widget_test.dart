import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:resume_builder/app.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:resume_builder/providers/resume_provider.dart';
import 'package:resume_builder/services/storage_service.dart';

class FakeStorageService extends StorageService {
  final List<ResumeModel> _items = [];

  @override
  Future<List<ResumeModel>> fetchResumes() async => _items;

  @override
  Future<void> saveResume(ResumeModel resume) async {
    final index = _items.indexWhere((item) => item.id == resume.id);
    if (index == -1) {
      _items.add(resume);
    } else {
      _items[index] = resume;
    }
  }

  @override
  Future<void> deleteResume(String resumeId) async {
    _items.removeWhere((item) => item.id == resumeId);
  }
}

void main() {
  testWidgets('home screen renders primary actions', (tester) async {
    final provider = ResumeProvider(storageService: FakeStorageService());
    await provider.loadResumes();

    await tester.pumpWidget(
      ChangeNotifierProvider<ResumeProvider>.value(
        value: provider,
        child: const ResumeBuilderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume Builder'), findsWidgets);
    expect(find.text('New Resume'), findsOneWidget);
    expect(find.text('Create a new resume'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
  });
}
