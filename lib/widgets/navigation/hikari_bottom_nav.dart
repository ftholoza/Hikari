import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class HikariBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HikariBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(
        label: 'ACCUEIL',
        icon: Icons.home_outlined,
      ),
      _NavItemData(
        label: 'ENTRAÎNEMENT',
        icon: Icons.directions_run,
      ),
      _NavItemData(
        label: 'RÉÉDUCATION',
        icon: Icons.medical_services_outlined,
      ),
      _NavItemData(
        label: 'HISTORIQUE',
        icon: Icons.history,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        items.length,
        (index) {
          final item = items[index];
          final selected = index == currentIndex;

          return Expanded(
            child: Center(
              child: _BottomNavButton(
                label: item.label,
                icon: item.icon,
                selected: selected,
                onTap: () => onTap(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? AppColors.primary : Colors.white;
    final fgColor = selected ? Colors.white : const Color(0xFF7A7A7A);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 56,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: fgColor),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 6.8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({
    required this.label,
    required this.icon,
  });
}