import 'package:flutter/material.dart';
import 'pages/splash_intro_page.dart';

class HikariApp extends StatelessWidget {
  const HikariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HIKARI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF3A3A3A),
        useMaterial3: true,
      ),
      home: const SplashIntroPage(),
    );
  }
}