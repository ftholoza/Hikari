import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/cards/app_card.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  Timer? _simTimer;
  int _tMs = 0;
  String _status = "Idle";
  String _raw = "";
  Map<String, dynamic>? _json;

  final _rng = Random();

  void _startSimulation() {
    _simTimer?.cancel();
    setState(() {
      _status = "Simulation ✅ (10 Hz) — 2 capteurs";
      _tMs = 0;
    });

    _simTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _tMs += 100;
      final phase = _tMs / 1000.0;

      final thighAx = 0.15 * sin(phase * 2 * pi * 0.7);
      final thighAy = 0.10 * cos(phase * 2 * pi * 0.5);
      final thighAz = 9.81 + 0.05 * sin(phase * 2 * pi * 1.0);

      final thighGx =
          0.03 * sin(phase * 2 * pi * 0.9) + (_rng.nextDouble() - 0.5) * 0.008;
      final thighGy =
          0.02 * cos(phase * 2 * pi * 0.6) + (_rng.nextDouble() - 0.5) * 0.008;
      final thighGz =
          0.02 * sin(phase * 2 * pi * 1.1) + (_rng.nextDouble() - 0.5) * 0.008;

      final thighDeg = 8 + 8 * sin(phase * 2 * pi * 0.35);

      final shinAx = 0.35 * sin(phase * 2 * pi * 0.9);
      final shinAy = 0.18 * cos(phase * 2 * pi * 0.7);
      final shinAz = 9.81 + 0.12 * sin(phase * 2 * pi * 1.2);

      final shinGx =
          0.07 * sin(phase * 2 * pi * 0.9) + (_rng.nextDouble() - 0.5) * 0.01;
      final shinGy =
          0.05 * cos(phase * 2 * pi * 0.6) + (_rng.nextDouble() - 0.5) * 0.01;
      final shinGz =
          0.04 * sin(phase * 2 * pi * 1.1) + (_rng.nextDouble() - 0.5) * 0.01;

      final shinDeg = 35 + 35 * sin(phase * 2 * pi * 0.6);
      final kneeDeg = (shinDeg - thighDeg).clamp(0.0, 120.0);

      final s = jsonEncode({
        "t": _tMs,
        "thigh": {
          "ax": double.parse(thighAx.toStringAsFixed(3)),
          "ay": double.parse(thighAy.toStringAsFixed(3)),
          "az": double.parse(thighAz.toStringAsFixed(3)),
          "gx": double.parse(thighGx.toStringAsFixed(3)),
          "gy": double.parse(thighGy.toStringAsFixed(3)),
          "gz": double.parse(thighGz.toStringAsFixed(3)),
          "deg": double.parse(thighDeg.toStringAsFixed(1)),
        },
        "shin": {
          "ax": double.parse(shinAx.toStringAsFixed(3)),
          "ay": double.parse(shinAy.toStringAsFixed(3)),
          "az": double.parse(shinAz.toStringAsFixed(3)),
          "gx": double.parse(shinGx.toStringAsFixed(3)),
          "gy": double.parse(shinGy.toStringAsFixed(3)),
          "gz": double.parse(shinGz.toStringAsFixed(3)),
          "deg": double.parse(shinDeg.toStringAsFixed(1)),
        },
        "kneeDeg": double.parse(kneeDeg.toStringAsFixed(1)),
      });

      setState(() {
        _raw = s;
        _json = jsonDecode(s) as Map<String, dynamic>;
      });
    });
  }

  void _stop() {
    _simTimer?.cancel();
    _simTimer = null;
    setState(() => _status = "Stopped");
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF4F69E0);
    String v2(String sensor, String k) {
      if (_json == null) return "-";
      final m = _json![sensor];
      if (m is Map<String, dynamic> && m.containsKey(k)) return "${m[k]}";
      return "-";
    }

    String v(String k) => _json == null ? "-" : "${_json![k]}";

    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 92,
            width: double.infinity,
            color: brand,
            alignment: Alignment.center,
            child: const Text(
              'HIKARI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SESSION",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _startSimulation,
                          child: const Text(
                            "Simuler",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _stop,
                          child: const Text(
                            "Stop",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    title: "Thigh (cuisse) — Acc (m/s²)",
                    content:
                        "ax: ${v2("thigh", "ax")}   ay: ${v2("thigh", "ay")}   az: ${v2("thigh", "az")}",
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    title: "Thigh (cuisse) — Gyro (rad/s)",
                    content:
                        "gx: ${v2("thigh", "gx")}   gy: ${v2("thigh", "gy")}   gz: ${v2("thigh", "gz")}",
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    title: "Shin (tibia) — Acc (m/s²)",
                    content:
                        "ax: ${v2("shin", "ax")}   ay: ${v2("shin", "ay")}   az: ${v2("shin", "az")}",
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    title: "Shin (tibia) — Gyro (rad/s)",
                    content:
                        "gx: ${v2("shin", "gx")}   gy: ${v2("shin", "gy")}   gz: ${v2("shin", "gz")}",
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    title: "Angles",
                    content:
                        "thigh: ${v2("thigh", "deg")}°   shin: ${v2("shin", "deg")}°   knee: ${v("kneeDeg")}°",
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    title: "Raw JSON",
                    content: _raw.isEmpty ? "-" : _raw,
                    mono: true,
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