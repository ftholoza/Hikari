import 'package:flutter/material.dart';

enum ReeducationType {
  marche,
  mobilite,
  renforcement,
  etirements,
  repos,
}

extension ReeducationTypeX on ReeducationType {
  String get label {
    switch (this) {
      case ReeducationType.marche:
        return 'Marche';
      case ReeducationType.mobilite:
        return 'Mobilité';
      case ReeducationType.renforcement:
        return 'Renforcement';
      case ReeducationType.etirements:
        return 'Étirements';
      case ReeducationType.repos:
        return 'Repos';
    }
  }

  Color get color {
    switch (this) {
      case ReeducationType.marche:
        return const Color(0xFF5A73F2);
      case ReeducationType.mobilite:
        return const Color(0xFF8B5CF6);
      case ReeducationType.renforcement:
        return const Color(0xFFF59E0B);
      case ReeducationType.etirements:
        return const Color(0xFF10B981);
      case ReeducationType.repos:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData get icon {
    switch (this) {
      case ReeducationType.marche:
        return Icons.directions_walk;
      case ReeducationType.mobilite:
        return Icons.accessibility_new;
      case ReeducationType.renforcement:
        return Icons.fitness_center;
      case ReeducationType.etirements:
        return Icons.self_improvement;
      case ReeducationType.repos:
        return Icons.hotel;
    }
  }
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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type.name,
      'title': title,
      'note': note,
    };
  }

  factory ReeducationEntry.fromJson(Map<String, dynamic> json) {
    return ReeducationEntry(
      date: DateTime.parse(json['date'] as String),
      type: ReeducationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'] as String,
      note: json['note'] as String?,
    );
  }
}