class TrainingSessionResult {
  final DateTime date;
  final int durationSeconds;
  final int repetitions;
  final double maxAngle;
  final double averageAngle;
  final double maxSpeed;
  final int samplesCount;
  final String status;

  TrainingSessionResult({
    required this.date,
    required this.durationSeconds,
    required this.repetitions,
    required this.maxAngle,
    required this.averageAngle,
    required this.maxSpeed,
    required this.samplesCount,
    required this.status,
  });
}