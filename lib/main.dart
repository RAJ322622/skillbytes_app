
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/program_listing_screen.dart';

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
      home: const ProgramListingScreen(),
    );
  }
}
