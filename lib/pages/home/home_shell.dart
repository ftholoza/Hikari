import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/navigation/hikari_bottom_nav.dart';
import 'accueil_page.dart';
import '../training/entrainement_page.dart';
import '../rehab/reeducation_page.dart';
import '../history/historique_page.dart';
import '../mKneeHurts/m_knee_hurts.dart';
import '../bluetooth/bluetooth_test_page.dart';
import '../calendar/calendar_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

Widget _buildPage() {
  switch (_index) {
    case 0:
      return const AccueilPage();
    case 1:
      return const EntrainementPage();
    case 2:
      return const ReeducationPage();
    case 3:
      return const HistoriquePage();
    case 4:
      return const BluetoothTestPage();
    case 5:
      return const KneePainPage();
    case 6:
      return const CalendrierPage(); // 👈 ajouté
    default:
      return const AccueilPage();
  }
}

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeShell build - index: $_index');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _buildPage(),
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
                onTap: (i) {
                  debugPrint('Bottom nav tap: $i');
                  setState(() => _index = i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}