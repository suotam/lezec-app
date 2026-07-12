import '../../core/localization/l10n.dart';
import '../../features/climbing_areas/domain/climbing_restriction.dart';
import '../../features/climbing_areas/domain/rock_type.dart';
import '../../features/climbing_routes/domain/climbing_type.dart';
import '../../features/climbing_routes/domain/route_grade.dart';
import '../../features/diary/domain/ascent.dart';

/// Localized display names for domain enums. Kept as extensions so the
/// domain layer stays free of any Flutter/localization dependency.
extension ClimbingTypeLabel on ClimbingType {
  String label(AppLocalizations l10n) => switch (this) {
    ClimbingType.sport => l10n.climbingTypeSport,
    ClimbingType.trad => l10n.climbingTypeTrad,
    ClimbingType.boulder => l10n.climbingTypeBoulder,
  };
}

extension RockTypeLabel on RockType {
  String label(AppLocalizations l10n) => switch (this) {
    RockType.sandstone => l10n.rockTypeSandstone,
    RockType.limestone => l10n.rockTypeLimestone,
    RockType.granite => l10n.rockTypeGranite,
    RockType.gneiss => l10n.rockTypeGneiss,
    RockType.basalt => l10n.rockTypeBasalt,
    RockType.other => l10n.rockTypeOther,
  };
}

extension GradingSystemLabel on GradingSystem {
  String label(AppLocalizations l10n) => switch (this) {
    GradingSystem.uiaa => l10n.gradingSystemUiaa,
    GradingSystem.french => l10n.gradingSystemFrench,
    GradingSystem.czechSandstone => l10n.gradingSystemCzechSandstone,
    GradingSystem.fontainebleau => l10n.gradingSystemFontainebleau,
    GradingSystem.vScale => l10n.gradingSystemVScale,
    GradingSystem.yds => l10n.gradingSystemYds,
    GradingSystem.british => l10n.gradingSystemBritish,
  };
}

extension AscentStyleLabel on AscentStyle {
  String label(AppLocalizations l10n) => switch (this) {
    AscentStyle.onsight => l10n.ascentStyleOnsight,
    AscentStyle.flash => l10n.ascentStyleFlash,
    AscentStyle.redpoint => l10n.ascentStyleRedpoint,
    AscentStyle.pinkpoint => l10n.ascentStylePinkpoint,
    AscentStyle.allFree => l10n.ascentStyleAllFree,
    AscentStyle.topRope => l10n.ascentStyleTopRope,
    AscentStyle.solo => l10n.ascentStyleSolo,
    AscentStyle.attempt => l10n.ascentStyleAttempt,
  };
}

extension RestrictionSeverityLabel on RestrictionSeverity {
  String label(AppLocalizations l10n) => switch (this) {
    RestrictionSeverity.info => l10n.severityInfo,
    RestrictionSeverity.warning => l10n.severityWarning,
    RestrictionSeverity.closure => l10n.severityClosure,
  };
}
