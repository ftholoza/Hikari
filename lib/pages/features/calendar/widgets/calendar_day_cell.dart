import 'package:flutter/material.dart';
import '../models/reeducation_entry.dart';

class CalendarDayCell extends StatelessWidget {
  final int? dayNumber;
  final bool isSelected;
  final List<ReeducationEntry> entries;
  final VoidCallback? onTap;
  final bool isEmpty;

  const CalendarDayCell({
    super.key,
    required this.dayNumber,
    required this.isSelected,
    required this.entries,
    required this.onTap,
  }) : isEmpty = false;

  const CalendarDayCell.empty({super.key})
      : dayNumber = null,
        isSelected = false,
        entries = const [],
        onTap = null,
        isEmpty = true;

  IconData _iconForType(ReeducationType type) {
    switch (type) {
      case ReeducationType.marche:
        return Icons.directions_walk;
      case ReeducationType.renforcement:
        return Icons.add;
      case ReeducationType.mobilite:
        return Icons.accessibility_new;
      case ReeducationType.etirement:
        return Icons.self_improvement;
      case ReeducationType.proprioception:
        return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    final hasEntries = entries.isNotEmpty;
    final firstIcon = hasEntries ? _iconForType(entries.first.type) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected || hasEntries
              ? Colors.white
              : Colors.transparent,
          border: Border.all(
            color: isSelected || hasEntries ? Colors.transparent : Colors.white70,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 7,
              left: 10,
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF5A73F2)
                      : hasEntries
                          ? const Color(0xFF5A73F2)
                          : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (hasEntries)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(firstIcon, size: 22, color: Colors.black87),
                    if (entries.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+${entries.length - 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}