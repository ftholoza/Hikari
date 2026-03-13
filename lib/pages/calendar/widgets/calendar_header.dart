import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  String get monthLabel {
    const months = [
      '',
      'JANVIER',
      'FÉVRIER',
      'MARS',
      'AVRIL',
      'MAI',
      'JUIN',
      'JUILLET',
      'AOÛT',
      'SEPTEMBRE',
      'OCTOBRE',
      'NOVEMBRE',
      'DÉCEMBRE',
    ];

    return '${months[currentMonth.month]} ${currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            monthLabel,
            style: const TextStyle(
              color: Color(0xFF5A73F2),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            splashRadius: 22,
            onPressed: onNext,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}