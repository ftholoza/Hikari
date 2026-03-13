enum ReeducationType {
  marche,
  renforcement,
  mobilite,
  etirement,
  proprioception,
}

class ReeducationEntry {
  final DateTime date;
  final ReeducationType type;
  final String title;
  final String? note;

  const ReeducationEntry({
    required this.date,
    required this.type,
    required this.title,
    this.note,
  });
}