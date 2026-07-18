/// Standalone validator for the catalog exchange format
/// (docs/CATALOG_FORMAT.md). Mirrors the rules of the app's parser so a
/// catalog that passes here loads in the app.
library;

class ValidationResult {
  ValidationResult({required this.errors, required this.warnings});

  /// Format violations — the catalog must not ship with any.
  final List<String> errors;

  /// Suspicious but importable findings for manual review.
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

const _climbingTypes = {'sport', 'trad', 'boulder'};
const _rockTypes = {
  'sandstone',
  'limestone',
  'granite',
  'gneiss',
  'basalt',
  'other',
};
const _gradingSystems = {
  'uiaa',
  'french',
  'czechSandstone',
  'fontainebleau',
  'vScale',
  'yds',
  'british',
};
const _severities = {'info', 'warning', 'closure'};

ValidationResult validateCatalog(Map<String, Object?> catalog) {
  final errors = <String>[];
  final warnings = <String>[];

  final version = catalog['version'];
  if (version is! int || version < 1) {
    errors.add('root.version must be a positive integer');
  }

  final regionIds = <String>{};
  final regions = catalog['regions'];
  if (regions is! List || regions.isEmpty) {
    errors.add('root.regions must be a non-empty list');
  } else {
    for (final (i, region) in regions.indexed) {
      final context = 'regions[$i]';
      if (region is! Map<String, Object?>) {
        errors.add('$context must be an object');
        continue;
      }
      for (final key in ['id', 'name', 'country']) {
        if (_nonEmptyString(region[key]) == null) {
          errors.add('$context.$key must be a non-empty string');
        }
      }
      if (_nonEmptyString(region['id']) case final id?) {
        if (!regionIds.add(id)) errors.add('duplicate region id "$id"');
      }
    }
  }

  final routeIds = <String>{};
  final areas = catalog['areas'];
  if (areas is! List || areas.isEmpty) {
    errors.add('root.areas must be a non-empty list');
    return ValidationResult(errors: errors, warnings: warnings);
  }

  for (final (i, area) in areas.indexed) {
    final context = 'areas[$i]';
    if (area is! Map<String, Object?>) {
      errors.add('$context must be an object');
      continue;
    }
    for (final key in ['id', 'regionId', 'name', 'summary', 'description']) {
      if (_nonEmptyString(area[key]) == null) {
        errors.add('$context.$key must be a non-empty string');
      }
    }
    if (_nonEmptyString(area['regionId']) case final regionId?) {
      if (!regionIds.contains(regionId)) {
        errors.add('$context references unknown region "$regionId"');
      }
    }
    _checkEnumList(
      area['climbingTypes'],
      _climbingTypes,
      '$context.climbingTypes',
      errors,
    );
    if ((area['climbingTypes'] as List?)?.isEmpty ?? true) {
      warnings.add('$context (${area['name']}): no climbing types');
    }
    if (!_rockTypes.contains(area['rockType'])) {
      errors.add('$context.rockType has unknown value "${area['rockType']}"');
    }
    _checkGeoPoint(area['location'], '$context.location', errors);

    final access = area['access'];
    if (access != null &&
        (access is! Map<String, Object?> ||
            _nonEmptyString(access['description']) == null)) {
      errors.add('$context.access.description must be a non-empty string');
    }

    final restrictions = area['restrictions'];
    if (restrictions is List) {
      for (final (j, restriction) in restrictions.indexed) {
        if (restriction is! Map<String, Object?> ||
            _nonEmptyString(restriction['title']) == null ||
            _nonEmptyString(restriction['description']) == null ||
            !_severities.contains(restriction['severity'])) {
          errors.add('$context.restrictions[$j] is malformed');
        }
      }
    }

    final sectors = area['sectors'];
    if (sectors is! List) {
      errors.add('$context.sectors must be a list');
      continue;
    }
    if (sectors.isEmpty) {
      warnings.add('$context (${area['name']}): area has no sectors');
    }
    for (final (j, sector) in sectors.indexed) {
      final sectorContext = '$context.sectors[$j]';
      if (sector is! Map<String, Object?>) {
        errors.add('$sectorContext must be an object');
        continue;
      }
      if (_nonEmptyString(sector['id']) == null ||
          _nonEmptyString(sector['name']) == null) {
        errors.add('$sectorContext must have id and name');
      }
      final directRoutes = sector['routes'];
      final rocks = sector['rocks'];
      var routeCount = 0;
      if (directRoutes is List) {
        for (final (k, route) in directRoutes.indexed) {
          _checkRoute(route, '$sectorContext.routes[$k]', routeIds, errors);
          routeCount++;
        }
      }
      if (rocks is List) {
        for (final (k, rock) in rocks.indexed) {
          final rockContext = '$sectorContext.rocks[$k]';
          if (rock is! Map<String, Object?>) {
            errors.add('$rockContext must be an object');
            continue;
          }
          final rockRoutes = rock['routes'];
          if (rockRoutes is List) {
            for (final (l, route) in rockRoutes.indexed) {
              _checkRoute(route, '$rockContext.routes[$l]', routeIds, errors);
              routeCount++;
            }
          }
        }
      }
      if (routeCount == 0) {
        warnings.add('$sectorContext (${sector['name']}): no routes');
      }
    }
  }

  return ValidationResult(errors: errors, warnings: warnings);
}

void _checkRoute(
  Object? route,
  String context,
  Set<String> routeIds,
  List<String> errors,
) {
  if (route is! Map<String, Object?>) {
    errors.add('$context must be an object');
    return;
  }
  if (_nonEmptyString(route['id']) case final id?) {
    if (!routeIds.add(id)) errors.add('duplicate route id "$id"');
  } else {
    errors.add('$context.id must be a non-empty string');
  }
  if (_nonEmptyString(route['name']) == null) {
    errors.add('$context.name must be a non-empty string');
  }
  final grade = route['grade'];
  if (grade is! Map<String, Object?> ||
      !_gradingSystems.contains(grade['system']) ||
      _nonEmptyString(grade['value']) == null) {
    errors.add('$context.grade must have a known system and a value');
  }
  if (!_climbingTypes.contains(route['type'])) {
    errors.add('$context.type has unknown value "${route['type']}"');
  }
  final length = route['lengthMeters'];
  if (length != null && length is! int) {
    errors.add('$context.lengthMeters must be an integer');
  }
}

void _checkEnumList(
  Object? value,
  Set<String> allowed,
  String context,
  List<String> errors,
) {
  if (value is! List) {
    errors.add('$context must be a list');
    return;
  }
  for (final entry in value) {
    if (!allowed.contains(entry)) {
      errors.add('$context has unknown value "$entry"');
    }
  }
}

void _checkGeoPoint(Object? value, String context, List<String> errors) {
  if (value is! Map<String, Object?> ||
      value['latitude'] is! num ||
      value['longitude'] is! num) {
    errors.add('$context must contain numeric latitude and longitude');
  }
}

String? _nonEmptyString(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;
