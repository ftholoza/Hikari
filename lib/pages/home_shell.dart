import 'package:flutter/material.dart';
import '../widgets/hikari_bottom_nav.dart';
import 'accueil_page.dart';
import 'entrainement_page.dart';
import 'reeducation_page.dart';
import 'historique_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    AccueilPage(),
    EntrainementPage(),
    ReeducationPage(),
    HistoriquePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: HikariBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}