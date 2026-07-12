import 'package:flutter/foundation.dart';

/// Grading systems the model can represent. The original system of a route
/// is always preserved; conversion between systems is a future concern.
enum GradingSystem {
  uiaa,
  french,
  czechSandstone,
  fontainebleau,
  vScale,
  yds,
  british,
}

/// A grade exactly as published for the route, e.g. `VIIb` (Saxon),
/// `6b+` (French) or `V5` (V-scale).
@immutable
class RouteGrade implements Comparable<RouteGrade> {
  const RouteGrade({required this.system, required this.value});

  final GradingSystem system;
  final String value;

  /// Rough difficulty ordinal used only for sorting route lists within one
  /// screen. Grades from different systems are first grouped by system, so
  /// this never pretends to convert between systems.
  double get sortOrdinal {
    switch (system) {
      case GradingSystem.uiaa:
      case GradingSystem.czechSandstone:
        return _romanOrdinal(value);
      case GradingSystem.french:
      case GradingSystem.fontainebleau:
        return _numberLetterOrdinal(value);
      case GradingSystem.vScale:
        return double.tryParse(
              value.replaceFirst(RegExp('^V', caseSensitive: false), ''),
            ) ??
            0;
      case GradingSystem.yds:
        return _numberLetterOrdinal(value.replaceFirst('5.', ''));
      case GradingSystem.british:
        return _numberLetterOrdinal(
          value.replaceFirst(RegExp(r'^[A-Za-z]+\s*'), ''),
        );
    }
  }

  /// Parses grades like `VIIb`, `IXa+`, `VII-`.
  static double _romanOrdinal(String raw) {
    final match = RegExp(
      r'^([IVXivx]+)\s*([a-c])?\s*([+-])?',
    ).firstMatch(raw.trim());
    if (match == null) return 0;
    const romans = {'i': 1, 'v': 5, 'x': 10};
    var base = 0.0;
    final roman = match.group(1)!.toLowerCase();
    for (var i = 0; i < roman.length; i++) {
      final current = romans[roman[i]]!;
      final next = i + 1 < roman.length ? romans[roman[i + 1]]! : 0;
      base += current < next ? -current : current.toDouble();
    }
    final letter = match.group(2);
    if (letter != null) {
      base += (letter.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1) * 0.2;
    }
    final sign = match.group(3);
    if (sign == '+') base += 0.1;
    if (sign == '-') base -= 0.1;
    return base;
  }

  /// Parses grades like `6b+`, `7A`, `4+`, `11a`.
  static double _numberLetterOrdinal(String raw) {
    final match = RegExp(
      r'^(\d+)\s*([a-dA-D])?\s*([+-])?',
    ).firstMatch(raw.trim());
    if (match == null) return 0;
    var base = double.parse(match.group(1)!);
    final letter = match.group(2);
    if (letter != null) {
      base +=
          (letter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0) + 1) * 0.2;
    }
    final sign = match.group(3);
    if (sign == '+') base += 0.1;
    if (sign == '-') base -= 0.1;
    return base;
  }

  @override
  int compareTo(RouteGrade other) {
    if (system != other.system) {
      return system.index.compareTo(other.system.index);
    }
    return sortOrdinal.compareTo(other.sortOrdinal);
  }

  @override
  bool operator ==(Object other) =>
      other is RouteGrade && other.system == system && other.value == value;

  @override
  int get hashCode => Object.hash(system, value);

  @override
  String toString() => '$value (${system.name})';
}
