import 'package:flutter/material.dart';
import '../../widgets/layout/hikari_header.dart';

class KneePainPage extends StatefulWidget {
  const KneePainPage({super.key});

  @override
  State<KneePainPage> createState() => _KneePainPageState();
}

class _KneePainPageState extends State<KneePainPage> {
  double intensity = 5;

  String selectedLocation = 'Intérieur';
  String selectedMoment = 'Pendant';

  final Map<String, bool> symptoms = {
    'Gonflement': false,
    'Blocage': false,
    'Genou qui lâche': true,
    'Douleur après choc': false,
  };

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2F2F2F);
    const card = Color(0xFF353535);
    const blue = Color(0xFF5A73F2);
    const textWhite = Colors.white;
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
                            'VOUS AVEZ MAL AU GENOU ?',
                            style: TextStyle(
                              color: textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 88),
                      child: Text(
                        'Répondez à quelques questions pour que l’on vous guide',
                        style: TextStyle(
                          color: lightText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('INTENSITÉ :'),
                          const SizedBox(height: 14),

                          Column(
                            children: [
                              SizedBox(
                                height: 28,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4E73FF),
                                            Color(0xFF8C6BFF),
                                            Color(0xFFE07A1A),
                                            Color(0xFFD00000),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 10,
                                        activeTrackColor: Colors.transparent,
                                        inactiveTrackColor: Colors.transparent,
                                        thumbColor: Colors.white,
                                        overlayColor: Colors.white24,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 9,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 16,
                                        ),
                                      ),
                                      child: Slider(
                                        min: 1,
                                        max: 10,
                                        divisions: 9,
                                        value: intensity,
                                        onChanged: (value) {
                                          setState(() => intensity = value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    10,
                                    (index) => Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const _SectionTitle('LOCALISATION :'),
                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: SizedBox(
                                  width: 78,
                                  height: 110,
                                  child: Image.asset(
                                    'assets/images/knee.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ChoiceButton(
                                            label: 'Avant',
                                            selected:
                                                selectedLocation == 'Avant',
                                            onTap: () => setState(
                                              () => selectedLocation = 'Avant',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _ChoiceButton(
                                            label: 'Arrière',
                                            selected:
                                                selectedLocation == 'Arrière',
                                            onTap: () => setState(
                                              () =>
                                                  selectedLocation = 'Arrière',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _ChoiceButton(
                                            label: 'Intérieur',
                                            selected:
                                                selectedLocation == 'Intérieur',
                                            onTap: () => setState(
                                              () => selectedLocation =
                                                  'Intérieur',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          child: _ChoiceButton(
                                            label: 'Extérieur',
                                            selected:
                                                selectedLocation == 'Extérieur',
                                            onTap: () => setState(
                                              () => selectedLocation =
                                                  'Extérieur',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 110,
                                          child: _ChoiceButton(
                                            label: 'Je ne sais pas',
                                            selected: selectedLocation ==
                                                'Je ne sais pas',
                                            onTap: () => setState(
                                              () => selectedLocation =
                                                  'Je ne sais pas',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const _SectionTitle('MOMENT :'),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _ChoiceButton(
                                  label: "Avant l'entrainement",
                                  selected:
                                      selectedMoment == "Avant l'entrainement",
                                  onTap: () => setState(
                                    () => selectedMoment =
                                        "Avant l'entrainement",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ChoiceButton(
                                  label: 'Pendant',
                                  selected: selectedMoment == 'Pendant',
                                  onTap: () => setState(
                                    () => selectedMoment = 'Pendant',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ChoiceButton(
                                  label: "Après l'entrainement",
                                  selected:
                                      selectedMoment == "Après l'entrainement",
                                  onTap: () => setState(
                                    () => selectedMoment =
                                        "Après l'entrainement",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                child: _ChoiceButton(
                                  label: 'Au repos',
                                  selected: selectedMoment == 'Au repos',
                                  onTap: () => setState(
                                    () => selectedMoment = 'Au repos',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 150,
                                child: _ChoiceButton(
                                  label: 'La nuit',
                                  selected: selectedMoment == 'La nuit',
                                  onTap: () => setState(
                                    () => selectedMoment = 'La nuit',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),
                          const _SectionTitle('SIGNES IMPORTANTS :'),
                          const SizedBox(height: 8),
                          const Text(
                            "Ne cochez rien si vous n'avez aucun de ces symptômes",
                            style: TextStyle(
                              color: lightText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _CheckboxRow(
                                      label: 'Gonflement',
                                      value: symptoms['Gonflement']!,
                                      onChanged: (v) => setState(
                                        () => symptoms['Gonflement'] = v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _CheckboxRow(
                                      label: 'Genou qui lâche',
                                      value: symptoms['Genou qui lâche']!,
                                      onChanged: (v) => setState(
                                        () =>
                                            symptoms['Genou qui lâche'] = v,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    _CheckboxRow(
                                      label: 'Blocage',
                                      value: symptoms['Blocage']!,
                                      onChanged: (v) => setState(
                                        () => symptoms['Blocage'] = v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _CheckboxRow(
                                      label: 'Douleur après choc',
                                      value: symptoms['Douleur après choc']!,
                                      onChanged: (v) => setState(
                                        () => symptoms['Douleur après choc'] = v,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              width: 350,
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: lancer l’analyse
                                },
                                child: const Text(
                                  'ANALYSER MA DOULEUR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF5A73F2);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white70,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
