import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/navigation/hikari_bottom_nav.dart';
import 'accueil_page.dart';
import '../training/entrainement_page.dart';
import '../rehab/reeducation_page.dart';
import '../history/historique_page.dart';
import '../mKneeHurts/m_knee_hurts.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<Widget> _pages = const [
    AccueilPage(),
    EntrainementPage(),
    ReeducationPage(),
    HistoriquePage(),
    KneePainPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _index,
                children: _pages,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFBDBDBD),
                    width: 0.8,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: HikariBottomNav(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}