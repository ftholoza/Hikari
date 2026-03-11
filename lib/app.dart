import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'pages/splash/splash_intro_page.dart';

class HikariApp extends StatelessWidget {
  const HikariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HIKARI',
      theme: AppTheme.dark,
      home: const SplashIntroPage(),
    );
  }
}