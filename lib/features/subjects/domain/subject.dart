import 'package:flutter/material.dart';

/// Пән (Entity №2). Байланыс: Subject 1 — N Task.
class Subject {
  final String id;
  final String name;
  final int backgroundValue; // Color.value
  final int foregroundValue;
  final DateTime createdAt;

  const Subject({
    required this.id,
    required this.name,
    required this.backgroundValue,
    required this.foregroundValue,
    required this.createdAt,
  });

  Color get background => Color(backgroundValue);
  Color get foreground => Color(foregroundValue);

  Subject copyWith({String? name}) => Subject(
        id: id,
        name: name ?? this.name,
        backgroundValue: backgroundValue,
        foregroundValue: foregroundValue,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'bg': backgroundValue,
        'fg': foregroundValue,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Subject.fromMap(Map<dynamic, dynamic> m) => Subject(
        id: m['id'] as String,
        name: m['name'] as String,
        backgroundValue: m['bg'] as int,
        foregroundValue: m['fg'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );
}
