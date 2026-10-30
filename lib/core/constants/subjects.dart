import 'package:flutter/material.dart';

/// Пән және оның белгісінің түсі.
class SubjectInfo {
  final String name;
  final Color background;
  final Color foreground;

  const SubjectInfo(this.name, this.background, this.foreground);
}

class AppSubjects {
  AppSubjects._();

  static const List<SubjectInfo> all = [
    SubjectInfo('Мобильді', Color(0xFFEFEBE9), Color(0xFF4E342E)),
    SubjectInfo('Дерекқор', Color(0xFFE8EDDC), Color(0xFF4F5D2F)),
    SubjectInfo('Тестілеу', Color(0xFFF9E3D8), Color(0xFF8A3B1E)),
    SubjectInfo('Қазақ тілі', Color(0xFFF6EBD0), Color(0xFF6B4E0A)),
  ];

  static List<String> get names => all.map((s) => s.name).toList();

  static SubjectInfo of(String name) {
    for (final s in all) {
      if (s.name == name) return s;
    }
    return const SubjectInfo('', Color(0xFFEFEBE9), Color(0xFF4E342E));
  }
}
