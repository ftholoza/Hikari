import 'package:flutter/material.dart';
import '../models/reeducation_entry.dart';
import 'calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<ReeducationEntry> entries;
  final DateTime? selectedDate;
  final Function(DateTime) onDayTap;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.entries,
    required this.selectedDate,
    required this.onDayTap,
  });

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final weekdayOffset = firstDayOfMonth.weekday - 1;
    final totalDays = lastDayOfMonth.day;

    final List<Widget> cells = [];

    const weekLabels = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];

    for (final label in weekLabels) {
      cells.add(
        Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF5A73F2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < weekdayOffset; i++) {
      cells.add(const CalendarDayCell.empty());
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(month.year, month.month, day);
      final dayEntries = entries.where((e) => _sameDate(e.date, date)).toList();

      cells.add(
        CalendarDayCell(
          dayNumber: day,
          isSelected: selectedDate != null && _sameDate(selectedDate!, date),
          entries: dayEntries,
          onTap: () => onDayTap(date),
        ),
      );
    }

    while ((cells.length - 7) % 7 != 0) {
      cells.add(const CalendarDayCell.empty());
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 8,
      childAspectRatio: 0.86,
      children: cells,
    );
  }
}