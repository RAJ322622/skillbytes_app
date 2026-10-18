import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/program_details_screen.dart';

void main() {
  runApp(const SkillBytesApp());
}

class SkillBytesApp extends StatelessWidget {
  const SkillBytesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBytes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';

        // /course/:id
        if (name.startsWith('/course/')) {
          final id = name.substring('/course/'.length);
          return MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: id),
          );
        }

        switch (name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const MainShell(initialIndex: 0),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
        }
      },
    );
  }
}