class OrtheseData {
  final double angle;
  final double vitesse;
  final int temps;

  const OrtheseData({
    required this.angle,
    required this.vitesse,
    required this.temps,
  });

  factory OrtheseData.fromBleString(String raw) {
    final parts = raw.split('|');

    if (parts.length != 3) {
      throw FormatException('Format BLE invalide: $raw');
    }

    return OrtheseData(
      angle: double.tryParse(parts[0]) ?? 0.0,
      vitesse: double.tryParse(parts[1]) ?? 0.0,
      temps: int.tryParse(parts[2]) ?? 0,
    );
  }
}