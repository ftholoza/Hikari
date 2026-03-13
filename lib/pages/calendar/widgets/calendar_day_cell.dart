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
    final visibleEntries = entries.take(3).toList();
    final extraCount = entries.length - visibleEntries.length;
    final highlighted = isSelected || hasEntries;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
        decoration: BoxDecoration(
          color: highlighted ? Colors.white : Colors.transparent,
          border: Border.all(
            color: highlighted ? Colors.transparent : Colors.white70,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFF5A73F2)
                    : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (hasEntries)
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  ...visibleEntries.map(
                    (entry) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: entry.type.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (extraCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '+$extraCount',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}