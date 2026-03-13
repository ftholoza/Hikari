import 'dart:async';
import 'package:flutter/material.dart';

import '../../bluetooth/ble_service.dart';
import '../../bluetooth/models/orthese_data.dart';
import '../../widgets/layout/hikari_header.dart';
import 'data/training_history_repository.dart';
import 'models/training_session_result.dart';

class EntrainementPage extends StatefulWidget {
  const EntrainementPage({super.key});

  @override
  State<EntrainementPage> createState() => _EntrainementPageState();
}

class _EntrainementPageState extends State<EntrainementPage> {
  final BleService _bleService = BleService();

  StreamSubscription<OrtheseData>? _dataSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  Timer? _sessionTimer;

  bool _isTraining = false;
  bool _isConnected = false;

  int _elapsedSeconds = 0;
  int _repetitions = 0;

  double _currentAngle = 0;
  double _maxAngle = 0;
  double _currentSpeed = 0;
  double _maxSpeed = 0;
  double _sumAngles = 0;
  int _receivedSamplesCount = 0;

  String _status = 'Prêt';

  bool _wasAboveThreshold = false;

  final List<OrtheseData> _sessionSamples = [];

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _listenToLiveData();
  }

  void _listenToLiveData() {
    _connectionSubscription = _bleService.connectionStream.listen((connected) {
      if (!mounted) return;

      setState(() {
        _isConnected = connected;

        if (!connected && _isTraining) {
          _status = 'Connexion perdue';
        }
      });
    });

    _dataSubscription = _bleService.dataStream.listen(_onDataReceived);
  }

  void _onDataReceived(OrtheseData data) {
    if (!_isTraining) return;

    final angle = data.angle.clamp(0.0, 180.0);
    final speed = data.vitesse.abs();

    setState(() {
      _currentAngle = angle;
      _currentSpeed = speed;

      if (angle > _maxAngle) {
        _maxAngle = angle;
      }

      if (speed > _maxSpeed) {
        _maxSpeed = speed;
      }

      _sumAngles += angle;
      _receivedSamplesCount++;

      _status = _buildMovementStatus(angle, speed);
    });

    _detectRepetition(angle);
    _sessionSamples.add(data);
  }

  String _buildMovementStatus(double angle, double speed) {
    if (!_isTraining) return 'Prêt';
    if (speed > 8) return 'Mouvement rapide';
    if (angle < 15) return 'Mouvement faible';
    if (angle < 45) return 'Échauffement';
    if (angle < 80) return 'Bonne flexion';
    return 'Flexion élevée';
  }

  void _detectRepetition(double angle) {
    const upThreshold = 55.0;
    const downThreshold = 20.0;

    if (!_wasAboveThreshold && angle >= upThreshold) {
      _wasAboveThreshold = true;
    }

    if (_wasAboveThreshold && angle <= downThreshold) {
      _wasAboveThreshold = false;
      setState(() {
        _repetitions++;
      });
    }
  }

  void _startTraining() {
    if (!_isConnected) {
      setState(() {
        _status = 'Prothèse non connectée';
      });
      return;
    }

    _sessionTimer?.cancel();

    setState(() {
      _isTraining = true;
      _elapsedSeconds = 0;
      _repetitions = 0;
      _currentAngle = 0;
      _maxAngle = 0;
      _currentSpeed = 0;
      _maxSpeed = 0;
      _sumAngles = 0;
      _receivedSamplesCount = 0;
      _status = 'Séance en cours';
      _wasAboveThreshold = false;
      _sessionSamples.clear();
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isTraining) return;

      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTraining() {
    _sessionTimer?.cancel();

    final averageAngle = _receivedSamplesCount == 0
        ? 0.0
        : _sumAngles / _receivedSamplesCount;

    final result = TrainingSessionResult(
      date: DateTime.now(),
      durationSeconds: _elapsedSeconds,
      repetitions: _repetitions,
      maxAngle: _maxAngle,
      averageAngle: averageAngle,
      maxSpeed: _maxSpeed,
      samplesCount: _receivedSamplesCount,
      status: 'Séance terminée',
    );

    TrainingHistoryRepository.addResult(result);

    setState(() {
      _isTraining = false;
      _status = 'Séance terminée';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Résultats de la séance sauvegardés'),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2F2F2F);
    const card = Color(0xFF353535);
    const brand = Color(0xFF5A73F2);
    const lightText = Color(0xFFBEBEBE);

    final averageAngle = _receivedSamplesCount == 0
        ? 0.0
        : _sumAngles / _receivedSamplesCount;

    return Container(
      color: bg,
      child: Column(
        children: [
          const HikariHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENTRAINEMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isConnected
                        ? 'Prothèse connectée'
                        : 'Prothèse non connectée',
                    style: const TextStyle(
                      color: lightText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: SizedBox(
                      width: 500,
                      height: 104,
                      child: ElevatedButton(
                        onPressed: _isTraining ? _stopTraining : _startTraining,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  _isTraining ? 'ARRÊTER' : 'DÉMARRER',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              _isTraining
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _InfoCard(
                    title: 'Temps',
                    value: _formatDuration(_elapsedSeconds),
                    subtitle: 'Durée de la séance',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Angle actuel',
                    value: '${_currentAngle.toStringAsFixed(1)}°',
                    subtitle: 'Angle du genou en direct',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Amplitude max',
                    value: '${_maxAngle.toStringAsFixed(1)}°',
                    subtitle: 'Meilleure flexion atteinte',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Angle moyen',
                    value: '${averageAngle.toStringAsFixed(1)}°',
                    subtitle: 'Moyenne sur la séance',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Vitesse actuelle',
                    value: '${_currentSpeed.toStringAsFixed(1)}',
                    subtitle: 'Vitesse instantanée du mouvement',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Vitesse max',
                    value: '${_maxSpeed.toStringAsFixed(1)}',
                    subtitle: 'Vitesse maximale atteinte',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Répétitions',
                    value: '$_repetitions',
                    subtitle: 'Nombre de flexions détectées',
                    color: card,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Statut',
                    value: _status,
                    subtitle: _isTraining
                        ? 'Analyse en cours du mouvement'
                        : 'Aucune séance en cours',
                    color: card,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFBEBEBE),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFBEBEBE),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}