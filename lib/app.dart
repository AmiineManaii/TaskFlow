import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'core/theme/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

class TaskFlowApp extends ConsumerWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(languageControllerProvider);

    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt_rounded, size: 64, color: Color(0xFF2563EB)),
              SizedBox(height: 16),
              Text('TaskFlow',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB))),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
