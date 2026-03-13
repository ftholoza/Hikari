import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/layout/hikari_header.dart';
import '../bluetooth/bluetooth_test_page.dart';
import '../calendar/calendar_page.dart';
import '../calendar/data/planning_repository.dart';
import '../calendar/models/reeducation_entry.dart';
import '../mKneeHurts/m_knee_hurts.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int selectedDayIndex = 1;

  final List<String> days = const [
    'LUN',
    'MAR',
    'MER',
    'JEU',
    'VEN',
    'SAM',
    'DIM',
  ];

  List<ReeducationEntry> get entries => PlanningRepository.entries;

  DateTime _dateForIndex(int index) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return DateTime(
      monday.year,
      monday.month,
      monday.day + index,
    );
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<ReeducationEntry> _entriesForSelectedDay() {
    final selectedDate = _dateForIndex(selectedDayIndex);

    return entries.where((entry) {
      return _sameDate(entry.date, selectedDate);
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntries = _entriesForSelectedDay();
    final selectedDate = _dateForIndex(selectedDayIndex);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          const HikariHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCUEIL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Text(
                        'BONJOUR CIRCÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('👋🏻', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.bluetooth_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aucune orthèse connectée',
                                style: TextStyle(
                                  color: Color(0xFF222222),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Connecte ton appareil pour démarrer une séance et suivre son état.',
                          style: TextStyle(
                            color: Color(0xFF5A5A5A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BluetoothTestPage(),
                                ),
                              ).then((_) {
                                if (mounted) setState(() {});
                              });
                            },
                            icon: const Icon(Icons.bluetooth_searching_rounded),
                            label: const Text(
                              'Connecter mon orthèse',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        'MA SEMAINE :',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalendrierPage(
                                initialDate: selectedDate,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: const Row(
                          children: [
                            Text(
                              'VOIR MON PLANNING',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      days.length,
                      (index) => _DayChip(
                        label: days[index],
                        active: index == selectedDayIndex,
                        hasEntries: entries.any(
                          (entry) => _sameDate(entry.date, _dateForIndex(index)),
                        ),
                        onTap: () {
                          setState(() {
                            selectedDayIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SelectedDayCard(
                    dayLabel: days[selectedDayIndex],
                    formattedDate: _formatDate(selectedDate),
                    entries: selectedEntries,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KneePainPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "J'AI MAL AU GENOU",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool hasEntries;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.active,
    required this.hasEntries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasEntries ? AppColors.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.primary : borderColor,
            width: hasEntries && !active ? 2 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final String dayLabel;
  final String formattedDate;
  final List<ReeducationEntry> entries;

  const _SelectedDayCard({
    required this.dayLabel,
    required this.formattedDate,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries.take(3).toList();
    final extraCount = entries.length - visibleEntries.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Planning du $dayLabel',
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '• $formattedDate',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const Text(
              'Aucune rééducation prévue.',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          else ...[
            ...visibleEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        entry.type.icon,
                        size: 14,
                        color: entry.type.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (extraCount > 0)
              Text(
                '+$extraCount autre${extraCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ],
      ),
    );
  }
}