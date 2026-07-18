/// Raw models mirror what the ČHS pages actually say, before any
/// normalization. Keeping them separate from the catalog format means new
/// sources can be added later without touching the app contract.
library;

/// One `_ano` (enabled) icon flag from a page, e.g. `sportovni` with the
/// human title `Sportovní lezení`.
typedef IconFlags = Map<String, String>;

class RawChsBreadcrumb {
  const RawChsBreadcrumb({
    this.regionId,
    this.regionName,
    this.oblastId,
    this.oblastName,
    this.sektorId,
    this.sektorName,
  });

  final int? regionId;
  final String? regionName;
  final int? oblastId;
  final String? oblastName;
  final int? sektorId;
  final String? sektorName;
}

/// A ČHS "sektor" page (e.g. Bohuňovské skály) — maps to a Crux CZ *area*.
class RawChsSektor {
  RawChsSektor({
    required this.id,
    required this.name,
    required this.sourceUrl,
    required this.fetchedAt,
    required this.breadcrumb,
    this.descriptionParagraphs = const [],
    this.accessText,
    this.rockText,
    this.heightText,
    this.gradeSystemLabel,
    this.iconFlags = const {},
    this.latitude,
    this.longitude,
    this.skalaIds = const [],
  });

  final int id;
  final String name;
  final String sourceUrl;
  final DateTime fetchedAt;
  final RawChsBreadcrumb breadcrumb;
  final List<String> descriptionParagraphs;
  final String? accessText;
  final String? rockText;
  final String? heightText;

  /// From the grade histogram tooltip, e.g. `UIAA` or `Pískovec Sasko`.
  final String? gradeSystemLabel;

  final IconFlags iconFlags;
  double? latitude;
  double? longitude;
  final List<int> skalaIds;
}

/// A ČHS "skála" page (one rock/wall) — maps to a Crux CZ *sector*.
class RawChsSkala {
  const RawChsSkala({
    required this.id,
    required this.name,
    required this.sourceUrl,
    required this.fetchedAt,
    required this.breadcrumb,
    this.description,
    this.gradeSystemLabel,
    this.routes = const [],
  });

  final int id;
  final String name;
  final String sourceUrl;
  final DateTime fetchedAt;
  final RawChsBreadcrumb breadcrumb;
  final String? description;
  final String? gradeSystemLabel;
  final List<RawChsCesta> routes;
}

/// One route row from a skála page list.
class RawChsCesta {
  const RawChsCesta({
    required this.id,
    required this.name,
    this.gradeText,
    this.lengthMeters,
    this.iconFlags = const {},
    this.description,
    this.firstAscent,
  });

  final int id;
  final String name;

  /// The grade exactly as listed, e.g. `V`, `VIIc`, `6b+`.
  final String? gradeText;

  /// Route length when the list row carries a trailing `<n>m` token.
  final int? lengthMeters;

  final IconFlags iconFlags;
  final String? description;
  final String? firstAscent;
}
