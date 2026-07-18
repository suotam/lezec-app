// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crux CZ';

  @override
  String get appTagline => 'Guide to Czech rock climbing';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navAreas => 'Areas';

  @override
  String get navDiary => 'Diary';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get commonDataLoadError =>
      'The data could not be loaded. Please try again.';

  @override
  String get commonClearFilters => 'Clear filters';

  @override
  String get discoverSearchHint => 'Search areas, regions or rocks…';

  @override
  String get discoverFeaturedTitle => 'Featured areas';

  @override
  String get discoverRecentTitle => 'Recently viewed';

  @override
  String get discoverMyClimbingTitle => 'My climbing';

  @override
  String get discoverProjects => 'Projects';

  @override
  String get discoverFavorites => 'Favorite routes';

  @override
  String get discoverBrowseAllAreas => 'Browse all areas';

  @override
  String get discoverDataSourceTitle => 'Data source';

  @override
  String get discoverDataSourceBody =>
      'The data comes from the ČHS rock database (horosvaz.cz). It is an offline copy taken during development — always verify current conditions, restrictions and climbing rules directly in the ČHS database.';

  @override
  String get discoverRestrictionsTitle => 'Current restrictions';

  @override
  String get areasTitle => 'Areas';

  @override
  String get areasSearchHint => 'Search by name, region or description';

  @override
  String areasResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String get areasEmptyTitle => 'Nothing found';

  @override
  String get areasEmptyBody =>
      'Try adjusting your search or clearing the filters.';

  @override
  String get filterClimbingType => 'Climbing type';

  @override
  String get filterRockType => 'Rock type';

  @override
  String get filterRegion => 'Region';

  @override
  String get areasSortRouteCount => 'Route count';

  @override
  String get areasSortDistance => 'Nearest';

  @override
  String get locationUnavailable =>
      'Could not determine your location. Check location permissions and services.';

  @override
  String sectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sectors',
      one: '1 sector',
    );
    return '$_temp0';
  }

  @override
  String routesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes',
      one: '1 route',
    );
    return '$_temp0';
  }

  @override
  String get climbingTypeSport => 'Sport';

  @override
  String get climbingTypeTrad => 'Trad';

  @override
  String get climbingTypeBoulder => 'Bouldering';

  @override
  String get rockTypeSandstone => 'Sandstone';

  @override
  String get rockTypeLimestone => 'Limestone';

  @override
  String get rockTypeGranite => 'Granite';

  @override
  String get rockTypeGneiss => 'Gneiss';

  @override
  String get rockTypeBasalt => 'Basalt';

  @override
  String get rockTypeOther => 'Other rock';

  @override
  String get gradingSystemUiaa => 'UIAA';

  @override
  String get gradingSystemFrench => 'French';

  @override
  String get gradingSystemCzechSandstone => 'Saxon (sandstone)';

  @override
  String get gradingSystemFontainebleau => 'Fontainebleau';

  @override
  String get gradingSystemVScale => 'V-scale';

  @override
  String get gradingSystemYds => 'YDS';

  @override
  String get gradingSystemBritish => 'British';

  @override
  String get severityInfo => 'Information';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severityClosure => 'Climbing ban';

  @override
  String get areaDetailAboutTitle => 'About the area';

  @override
  String get areaDetailAccessTitle => 'Access';

  @override
  String areaDetailApproachTime(int minutes) {
    return '$minutes min walk';
  }

  @override
  String get areaDetailParkingTitle => 'Parking';

  @override
  String get areaDetailRestrictionsTitle => 'Restrictions and warnings';

  @override
  String get areaDetailSectorsTitle => 'Sectors';

  @override
  String get navigateAction => 'Navigate';

  @override
  String get navigationFailed => 'Could not open a maps application.';

  @override
  String get sectorRoutesTitle => 'Routes';

  @override
  String get sectorIndependentRoutesTitle => 'Independent routes';

  @override
  String get sectorAccessTitle => 'Sector access';

  @override
  String get sortGuidebook => 'Guidebook';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByGrade => 'Grade';

  @override
  String get routeTypeLabel => 'Type';

  @override
  String get routeLengthLabel => 'Length';

  @override
  String routeLengthMeters(int meters) {
    return '$meters m';
  }

  @override
  String get routeGradeLabel => 'Grade';

  @override
  String get routeDescriptionTitle => 'Description';

  @override
  String get routeProtectionTitle => 'Protection';

  @override
  String get routeFirstAscentTitle => 'First ascent';

  @override
  String get routeWarningsTitle => 'Warnings';

  @override
  String get routeLocationTitle => 'Location';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get projectAdd => 'Add to projects';

  @override
  String get projectRemove => 'Remove from projects';

  @override
  String get favoriteLabel => 'Favorite';

  @override
  String get projectLabel => 'Project';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get diaryEmptyTitle => 'No ascents yet';

  @override
  String get diaryEmptyBody => 'Open a route detail and log your first ascent.';

  @override
  String diaryAscentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ascents',
      one: '1 ascent',
    );
    return '$_temp0';
  }

  @override
  String get logAscentAction => 'Log ascent';

  @override
  String get logAscentTitle => 'Log an ascent';

  @override
  String get ascentStyleLabel => 'Ascent style';

  @override
  String get ascentDateLabel => 'Date';

  @override
  String get ascentNoteLabel => 'Note';

  @override
  String get ascentNoteHint => 'How it went, conditions, partners…';

  @override
  String get ascentSaveAction => 'Save ascent';

  @override
  String get ascentLoggedMessage => 'The ascent was saved to your diary.';

  @override
  String get ascentDeleteAction => 'Delete entry';

  @override
  String get ascentDeletedMessage => 'The entry was deleted.';

  @override
  String get ascentEditAction => 'Edit entry';

  @override
  String get editAscentTitle => 'Edit ascent';

  @override
  String get ascentUpdatedMessage => 'The entry was updated.';

  @override
  String get diaryAllAreas => 'All areas';

  @override
  String areaDistanceKm(int km) {
    return '$km km';
  }

  @override
  String get routeMyAscentsTitle => 'My ascents';

  @override
  String get routeClimbedLabel => 'Climbed';

  @override
  String get diaryStatsTotalLabel => 'Total';

  @override
  String get diaryStatsThisYearLabel => 'This year';

  @override
  String get diaryStatsRoutesLabel => 'Distinct routes';

  @override
  String get diaryFilterEmptyTitle => 'Nothing matches the filter';

  @override
  String get diaryFilterEmptyBody =>
      'No ascent has the selected style. Clear the filter to see your entries again.';

  @override
  String get ascentStyleOnsight => 'OS';

  @override
  String get ascentStyleFlash => 'Flash';

  @override
  String get ascentStyleRedpoint => 'RP';

  @override
  String get ascentStylePinkpoint => 'PP';

  @override
  String get ascentStyleAllFree => 'AF';

  @override
  String get ascentStyleTopRope => 'TR';

  @override
  String get ascentStyleSolo => 'Solo';

  @override
  String get ascentStyleAttempt => 'Attempt';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody =>
      'This part of the app will be available in a future development stage.';

  @override
  String get diaryDescription =>
      'Ascent logs, statistics and an overview of your projects in one place.';

  @override
  String get communityDescription =>
      'Comments, crag news and sharing with other climbers.';

  @override
  String get profileDescription =>
      'Your climbing profile, settings and cross-device sync.';

  @override
  String get notFoundTitle => 'Not found';

  @override
  String get areaNotFound => 'The area could not be found.';

  @override
  String get sectorNotFound => 'The sector could not be found.';

  @override
  String get routeNotFound => 'The route could not be found.';
}
