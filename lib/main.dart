import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/resume_provider.dart';
import 'services/ad_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.init();
  await AdService.initialize();

  final provider = ResumeProvider(storageService: StorageService());
  await provider.loadResumes();

  runApp(
    ChangeNotifierProvider<ResumeProvider>.value(
      value: provider,
      child: const ResumeBuilderApp(),
    ),
  );
}
