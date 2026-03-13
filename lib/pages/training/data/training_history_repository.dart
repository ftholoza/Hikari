import '../models/training_session_result.dart';

class TrainingHistoryRepository {
  static final List<TrainingSessionResult> _results = [];

  static List<TrainingSessionResult> get results =>
      List.unmodifiable(_results.reversed);

  static void addResult(TrainingSessionResult result) {
    _results.add(result);
  }

  static void clear() {
    _results.clear();
  }
}