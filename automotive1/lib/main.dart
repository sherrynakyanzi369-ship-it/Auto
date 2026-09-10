import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AutoAssistApp());
}

class AutoAssistApp extends StatelessWidget {
  const AutoAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}