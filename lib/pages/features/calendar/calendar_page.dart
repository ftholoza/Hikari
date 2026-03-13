import 'package:flutter/material.dart';
import '../../../widgets/layout/hikari_header.dart';
import 'models/reeducation_entry.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_header.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({super.key});

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  DateTime currentMonth = DateTime(2026, 2);
  DateTime? selectedDate;

  final List<ReeducationEntry> entries = [
    ReeducationEntry(
      date: DateTime(2026, 2, 1),
      type: ReeducationType.marche,
      title: 'Marche légère',
    ),
    ReeducationEntry(
      date: DateTime(2026, 2, 3),
      type: ReeducationType.renforcement,
      title: 'Renforcement quadriceps',
    ),
    ReeducationEntry(
      date: DateTime(2026, 2, 3),
      type: ReeducationType.mobilite,
      title: 'Mobilité genou',
    ),
    ReeducationEntry(
      date: DateTime(2026, 2, 7),
      type: ReeducationType.marche,
      title: 'Marche assistée',
    ),
    ReeducationEntry(
      date: DateTime(2026, 2, 15),
      type: ReeducationType.etirement,
      title: 'Étirements',
    ),
  ];

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      selectedDate = date;
    });

    _showDayEntries(date);
  }

  void _showDayEntries(DateTime date) {
    final dayEntries = entries.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF353535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rééducations du ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (dayEntries.isEmpty)
                const Text(
                  'Aucune rééducation prévue.',
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...dayEntries.map(
                  (e) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F6BEE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      e.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddReeducationSheet(date);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F6BEE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ajouter une rééducation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReeducationSheet(DateTime date) {
    ReeducationType selectedType = ReeducationType.marche;
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF353535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajouter une rééducation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ex: Renforcement quadriceps',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2F2F2F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<ReeducationType>(
                    value: selectedType,
                    dropdownColor: const Color(0xFF2F2F2F),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2F2F2F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ReeducationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          _labelForType(type),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;

                        setState(() {
                          entries.add(
                            ReeducationEntry(
                              date: date,
                              type: selectedType,
                              title: titleController.text.trim(),
                            ),
                          );
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F6BEE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Valider'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _labelForType(ReeducationType type) {
    switch (type) {
      case ReeducationType.marche:
        return 'Marche';
      case ReeducationType.renforcement:
        return 'Renforcement';
      case ReeducationType.mobilite:
        return 'Mobilité';
      case ReeducationType.etirement:
        return 'Étirement';
      case ReeducationType.proprioception:
        return 'Proprioception';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2F2F2F);
    const lightText = Color(0xFFBEBEBE);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const HikariHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.undo_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'MON PLANNING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 38),
                      child: Text(
                        'Ajoutez et consultez vos rééducations',
                        style: TextStyle(
                          color: lightText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CalendarHeader(
                      currentMonth: currentMonth,
                      onPrevious: _previousMonth,
                      onNext: _nextMonth,
                    ),
                    const SizedBox(height: 18),
                    CalendarGrid(
                      month: currentMonth,
                      entries: entries,
                      selectedDate: selectedDate,
                      onDayTap: _onDayTapped,
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}