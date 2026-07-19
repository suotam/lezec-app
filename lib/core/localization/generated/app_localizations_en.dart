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
  String get discoverSearchHint => 'Search areas, sectors, rocks and routes…';

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
  String get areasSearchHint => 'Search areas, sectors, rocks and routes';

  @override
  String get areasShowMapTooltip => 'Show map';

  @override
  String get areasShowListTooltip => 'Show list';

  @override
  String get areaDetailMapTitle => 'Map';

  @override
  String get searchSectorsTitle => 'Sectors';

  @override
  String get searchRocksTitle => 'Rocks and towers';

  @override
  String get searchRoutesTitle => 'Routes';

  @override
  String searchMoreResultsHint(int count) {
    return 'Showing the first $count results, refine your search.';
  }

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
  String get diaryGradeChartTitle => 'Ascents by grade';

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
  String get profileAccountTitle => 'Account & sync';

  @override
  String get authInfoBody =>
      'An account only backs up and syncs your diary, favorites and projects across devices. The app is fully functional without one.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authConfirmEmail =>
      'Account created. Confirm the registration in your email, then sign in.';

  @override
  String authFailed(String message) {
    return 'Failed: $message';
  }

  @override
  String get profileSyncNow => 'Sync now';

  @override
  String profileSyncedAt(String time) {
    return 'Synced at $time';
  }

  @override
  String get profileSyncNever => 'Not synced yet';

  @override
  String get profileSyncFailed => 'Sync failed — check your connection.';

  @override
  String get profileVersionLabel => 'Version';

  @override
  String get profileDataTitle => 'Catalog data';

  @override
  String get profileCatalogVersionLabel => 'Catalog version';

  @override
  String get profileCatalogImportedLabel => 'Imported';

  @override
  String get profileMapCacheTitle => 'Map cache';

  @override
  String get profileMapCacheBody =>
      'Viewed map areas are stored for use without a signal.';

  @override
  String get profileMapCacheClear => 'Clear';

  @override
  String get profileMapCacheCleared => 'Map cache cleared.';

  @override
  String get profileSourcesTitle => 'Data sources';

  @override
  String get profileSourcesBody =>
      'The rock and route database comes from the public Czech Mountaineering Federation database (horosvaz.cz). It is an offline copy — always verify current conditions and restrictions at the source before climbing. Map data is provided by OpenStreetMap or Mapy.com (Seznam.cz).';

  @override
  String get notFoundTitle => 'Not found';

  @override
  String get areaNotFound => 'The area could not be found.';

  @override
  String get sectorNotFound => 'The sector could not be found.';

  @override
  String get routeNotFound => 'The route could not be found.';
}
