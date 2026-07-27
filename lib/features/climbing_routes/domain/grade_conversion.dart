/// Approximate conversion between grading systems, based on the commonly
/// published comparison tables. Route systems (French, UIAA, Saxon, YDS,
/// British) convert among themselves; boulder systems (Fontainebleau,
/// V-scale) likewise. Cross-category conversion is refused — a font 7A
/// has no honest UIAA equivalent.
///
/// Conversions are always approximate; the UI must present them with a
/// `≈` and keep the original grade primary.
library;

import 'route_grade.dart';

const _routeSystems = [
  GradingSystem.french,
  GradingSystem.uiaa,
  GradingSystem.czechSandstone,
  GradingSystem.yds,
  GradingSystem.british,
];

const _boulderSystems = [GradingSystem.fontainebleau, GradingSystem.vScale];

/// One comparison-table row: aligned grades per system. Order matches
/// [_routeSystems].
const _routeTable = [
  ['2', 'II', 'II', '5.2', 'D 2b'],
  ['3', 'III', 'III', '5.3', 'VD 3a'],
  ['4a', 'IV', 'IV', '5.4', 'S 3c'],
  ['4b', 'IV+', 'V', '5.5', 'S 4a'],
  ['4c', 'V-', 'VI', '5.6', 'HS 4b'],
  ['5a', 'V', 'VI', '5.7', 'HS 4c'],
  ['5b', 'V+', 'VIIa', '5.8', 'VS 4c'],
  ['5c', 'VI-', 'VIIb', '5.9', 'HVS 5a'],
  ['6a', 'VI', 'VIIc', '5.10a', 'E1 5a'],
  ['6a+', 'VI+', 'VIIIa', '5.10b', 'E1 5b'],
  ['6b', 'VII-', 'VIIIb', '5.10c', 'E2 5b'],
  ['6b+', 'VII', 'VIIIc', '5.10d', 'E2 5c'],
  ['6c', 'VII+', 'IXa', '5.11a', 'E3 5c'],
  ['6c+', 'VIII-', 'IXa', '5.11b', 'E3 6a'],
  ['7a', 'VIII', 'IXb', '5.11c', 'E4 6a'],
  ['7a+', 'VIII+', 'IXc', '5.11d', 'E4 6b'],
  ['7b', 'VIII+', 'Xa', '5.12a', 'E5 6b'],
  ['7b+', 'IX-', 'Xa', '5.12b', 'E5 6b'],
  ['7c', 'IX', 'Xb', '5.12c', 'E5 6c'],
  ['7c+', 'IX+', 'Xc', '5.12d', 'E6 6c'],
  ['8a', 'X-', 'XIa', '5.13a', 'E6 6c'],
  ['8a+', 'X', 'XIb', '5.13b', 'E7 7a'],
  ['8b', 'X+', 'XIc', '5.13c', 'E7 7a'],
  ['8b+', 'XI-', 'XIIa', '5.13d', 'E8 7a'],
  ['8c', 'XI', 'XIIb', '5.14a', 'E8 7b'],
  ['8c+', 'XI+', 'XIIc', '5.14b', 'E9 7b'],
  ['9a', 'XII-', 'XIIc', '5.14c', 'E9 7b'],
  ['9a+', 'XII', 'XIIc', '5.14d', 'E10 7c'],
  ['9b', 'XII+', 'XIIc', '5.15a', 'E10 7c'],
];

/// Order matches [_boulderSystems].
const _boulderTable = [
  ['3', 'VB'],
  ['4', 'V0'],
  ['5', 'V1'],
  ['5+', 'V2'],
  ['6A', 'V3'],
  ['6A+', 'V3'],
  ['6B', 'V4'],
  ['6B+', 'V4'],
  ['6C', 'V5'],
  ['6C+', 'V5'],
  ['7A', 'V6'],
  ['7A+', 'V7'],
  ['7B', 'V8'],
  ['7B+', 'V8'],
  ['7C', 'V9'],
  ['7C+', 'V10'],
  ['8A', 'V11'],
  ['8A+', 'V12'],
  ['8B', 'V13'],
  ['8B+', 'V14'],
  ['8C', 'V15'],
];

(List<GradingSystem>, List<List<String>>)? _tableFor(GradingSystem system) {
  if (_routeSystems.contains(system)) return (_routeSystems, _routeTable);
  if (_boulderSystems.contains(system)) return (_boulderSystems, _boulderTable);
  return null;
}

/// The comparison-table row [grade] sits in — a system-independent
/// difficulty band on its category's scale (route table or boulder
/// table). Null when the grade's system is unknown or the value cannot
/// be placed. Two grades in the same category are comparable by band.
int? _rowIndexFor(RouteGrade grade) {
  final table = _tableFor(grade.system);
  if (table == null) return null;
  final (systems, rows) = table;
  final column = systems.indexOf(grade.system);

  final wanted = grade.value.trim().toLowerCase();
  // Exact match first; otherwise the nearest row by the source system's
  // sort ordinal (covers values between table anchors, e.g. `VII-` UIAA).
  var rowIndex = rows.indexWhere((row) => row[column].toLowerCase() == wanted);
  if (rowIndex >= 0) return rowIndex;

  final ordinal = grade.sortOrdinal;
  var bestDistance = double.infinity;
  for (final (i, row) in rows.indexed) {
    final rowOrdinal = RouteGrade(
      system: grade.system,
      value: row[column],
    ).sortOrdinal;
    final distance = (rowOrdinal - ordinal).abs();
    if (distance < bestDistance) {
      bestDistance = distance;
      rowIndex = i;
    }
  }
  // An unparseable value keeps distance infinite for every row; treat a
  // huge distance as "unknown grade" rather than guessing wildly.
  if (rowIndex < 0 || bestDistance > 1.5) return null;
  return rowIndex;
}

/// Route-scale difficulty band of [grade] (index into [routeGradeBandLabels]),
/// or null when it is not a route-system grade the table knows.
int? routeGradeBand(RouteGrade grade) =>
    _routeSystems.contains(grade.system) ? _rowIndexFor(grade) : null;

/// Boulder-scale difficulty band of [grade] (index into
/// [boulderGradeBandLabels]), or null when it is not a boulder grade.
int? boulderGradeBand(RouteGrade grade) =>
    _boulderSystems.contains(grade.system) ? _rowIndexFor(grade) : null;

/// Human labels per route band, French with UIAA in parentheses.
final List<String> routeGradeBandLabels = [
  for (final row in _routeTable) '${row[0]} (${row[1]})',
];

/// Human labels per boulder band, Fontainebleau with V-scale.
final List<String> boulderGradeBandLabels = [
  for (final row in _boulderTable) '${row[0]} (${row[1]})',
];

/// Converts [grade] into [target], or null when the systems are the same,
/// incompatible (route vs boulder) or the value is unknown to the table.
String? convertGrade(RouteGrade grade, GradingSystem target) {
  if (grade.system == target) return null;
  final table = _tableFor(grade.system);
  if (table == null || !table.$1.contains(target)) return null;
  final rowIndex = _rowIndexFor(grade);
  if (rowIndex == null) return null;
  return table.$2[rowIndex][table.$1.indexOf(target)];
}
