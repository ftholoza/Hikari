import 'package:flutter/material.dart';

import '../../widgets/layout/hikari_header.dart';
import '../training/data/training_history_repository.dart';
import '../training/models/training_session_result.dart';

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2F2F2F);
    const card = Color(0xFF353535);
    const lightText = Color(0xFFBEBEBE);

    final List<TrainingSessionResult> sessions =
        TrainingHistoryRepository.results;

    return Container(
      color: bg,
      child: Column(
        children: [
          const HikariHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HISTORIQUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sessions.isEmpty
                        ? 'Aucun entraînement enregistré'
                        : '${sessions.length} entraînement(s) enregistré(s)',
                    style: const TextStyle(
                      color: lightText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: sessions.isEmpty
                        ? const _EmptyHistoryState()
                        : ListView.separated(
                            itemCount: sessions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final session = sessions[index];

                              return _TrainingHistoryCard(
                                sessionNumber: sessions.length - index,
                                dateText: _formatDate(session.date),
                                durationText:
                                    _formatDuration(session.durationSeconds),
                                repetitionsText:
                                    session.repetitions.toString(),
                                maxAngleText:
                                    '${session.maxAngle.toStringAsFixed(1)}°',
                                averageAngleText:
                                    '${session.averageAngle.toStringAsFixed(1)}°',
                                maxSpeedText:
                                    session.maxSpeed.toStringAsFixed(1),
                                samplesText:
                                    session.samplesCount.toString(),
                                statusText: session.status,
                                cardColor: card,
                              );
                            },
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

class _TrainingHistoryCard extends StatelessWidget {
  final int sessionNumber;
  final String dateText;
  final String durationText;
  final String repetitionsText;
  final String maxAngleText;
  final String averageAngleText;
  final String maxSpeedText;
  final String samplesText;
  final String statusText;
  final Color cardColor;

  const _TrainingHistoryCard({
    required this.sessionNumber,
    required this.dateText,
    required this.durationText,
    required this.repetitionsText,
    required this.maxAngleText,
    required this.averageAngleText,
    required this.maxSpeedText,
    required this.samplesText,
    required this.statusText,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFFBEBEBE),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    const valueStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTRAÎNEMENT $sessionNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateText,
            style: const TextStyle(
              color: Color(0xFFBEBEBE),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            runSpacing: 14,
            spacing: 24,
            children: [
              _HistoryInfoItem(
                label: 'Durée',
                value: durationText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              _HistoryInfoItem(
                label: 'Répétitions',
                value: repetitionsText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              _HistoryInfoItem(
                label: 'Angle max',
                value: maxAngleText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              _HistoryInfoItem(
                label: 'Angle moyen',
                value: averageAngleText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              _HistoryInfoItem(
                label: 'Vitesse max',
                value: maxSpeedText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              _HistoryInfoItem(
                label: 'Mesures',
                value: samplesText,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _HistoryInfoItem({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: labelStyle),
          const SizedBox(height: 4),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF353535),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              'Aucun entraînement pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les résultats de tes séances apparaîtront ici après un entraînement terminé.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFBEBEBE),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}