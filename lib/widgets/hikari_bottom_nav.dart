import 'package:flutter/material.dart';

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
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(.25), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(0, Icons.home_rounded, "ACCUEIL"),
            _item(1, Icons.directions_run_rounded, "ENTRAINEMENT"),
            _item(2, Icons.add_box_rounded, "RÉÉDUCATION"),
            _item(3, Icons.schedule_rounded, "HISTORIQUE"),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    const brand = Color(0xFF7ED8D1);
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : brand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected ? brand : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}