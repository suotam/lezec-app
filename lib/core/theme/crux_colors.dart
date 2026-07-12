import 'package:flutter/material.dart';

/// Brand palette: graphite slate + signal orange, inspired by rope markings
/// and chalk on dark rock. Referenced only from theme construction; widgets
/// should read colors through [Theme] / [CruxColors].
abstract final class CruxPalette {
  static const signalOrange = Color(0xFFE8571F);
  static const graphite = Color(0xFF20262E);
  static const sandstone = Color(0xFFF6F1EA);
}

/// Semantic colors that Material's [ColorScheme] does not cover, mainly the
/// three restriction severities used on badges and warning cards.
@immutable
class CruxColors extends ThemeExtension<CruxColors> {
  const CruxColors({
    required this.info,
    required this.onInfo,
    required this.warning,
    required this.onWarning,
    required this.closure,
    required this.onClosure,
    required this.favorite,
    required this.project,
  });

  final Color info;
  final Color onInfo;
  final Color warning;
  final Color onWarning;
  final Color closure;
  final Color onClosure;
  final Color favorite;
  final Color project;

  static const light = CruxColors(
    info: Color(0xFFD8E6F2),
    onInfo: Color(0xFF16405E),
    warning: Color(0xFFFCE8C5),
    onWarning: Color(0xFF6B4600),
    closure: Color(0xFFF9DAD5),
    onClosure: Color(0xFF8C1D0E),
    favorite: Color(0xFFC62842),
    project: Color(0xFF1C6E8C),
  );

  static const dark = CruxColors(
    info: Color(0xFF1E3A50),
    onInfo: Color(0xFFB5D3EC),
    warning: Color(0xFF4C3A11),
    onWarning: Color(0xFFF3CE8C),
    closure: Color(0xFF5C1F16),
    onClosure: Color(0xFFF3B6AC),
    favorite: Color(0xFFEF7A90),
    project: Color(0xFF7BBCD6),
  );

  @override
  CruxColors copyWith({
    Color? info,
    Color? onInfo,
    Color? warning,
    Color? onWarning,
    Color? closure,
    Color? onClosure,
    Color? favorite,
    Color? project,
  }) {
    return CruxColors(
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      closure: closure ?? this.closure,
      onClosure: onClosure ?? this.onClosure,
      favorite: favorite ?? this.favorite,
      project: project ?? this.project,
    );
  }

  @override
  CruxColors lerp(CruxColors? other, double t) {
    if (other == null) return this;
    return CruxColors(
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      closure: Color.lerp(closure, other.closure, t)!,
      onClosure: Color.lerp(onClosure, other.onClosure, t)!,
      favorite: Color.lerp(favorite, other.favorite, t)!,
      project: Color.lerp(project, other.project, t)!,
    );
  }
}

extension CruxColorsX on ThemeData {
  CruxColors get cruxColors => extension<CruxColors>()!;
}
