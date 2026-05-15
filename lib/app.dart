import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/resume_form_screen.dart';
import 'screens/resume_preview_screen.dart';
import 'screens/template_selection_screen.dart';

class ResumeBuilderApp extends StatefulWidget {
  const ResumeBuilderApp({super.key});

  @override
  State<ResumeBuilderApp> createState() => _ResumeBuilderAppState();
}

class _ResumeBuilderAppState extends State<ResumeBuilderApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/editor', builder: (context, state) => const ResumeFormScreen()),
      GoRoute(path: '/templates', builder: (context, state) => const TemplateSelectionScreen()),
      GoRoute(path: '/preview', builder: (context, state) => const ResumePreviewScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E7490);

    return MaterialApp.router(
      title: 'Dhebe Resume Builder',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF3F7F9),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Color(0xFF0B2242),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.blueGrey.shade50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: seed, width: 1.2),
          ),
        ),
      ),
    );
  }
}
