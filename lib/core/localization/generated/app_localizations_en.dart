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
  String get mapMyLocationTooltip => 'My location';

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
  String get smartSearchAction => 'Find a suitable area';

  @override
  String get smartSearchTitle => 'Find an area';

  @override
  String get smartSearchIntro =>
      'Pick a discipline, grade and where it should be close to.';

  @override
  String get smartDisciplineRoutes => 'Routes';

  @override
  String get smartDisciplineBoulders => 'Boulders';

  @override
  String get smartGradeLabel => 'Grade';

  @override
  String get smartGradeAny => 'any';

  @override
  String smartGradeRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get smartOriginLabel => 'Origin';

  @override
  String get smartOriginMyLocation => 'My location';

  @override
  String get smartOriginPickTown => 'Pick a town';

  @override
  String get smartOriginNone => 'No distance limit';

  @override
  String get smartRadiusLabel => 'Within distance (as the crow flies)';

  @override
  String smartRadiusValue(int km) {
    return '$km km';
  }

  @override
  String get smartResultsTitle => 'Results';

  @override
  String get smartEmptyTitle => 'Nothing matches';

  @override
  String get smartEmptyBody =>
      'Try widening the grade range or increasing the distance.';

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
  String get authDeleteAccount => 'Delete account';

  @override
  String get authDeleteConfirmTitle => 'Delete account?';

  @override
  String get authDeleteConfirmBody =>
      'The account and all synced data (diary, favorites, comments, photos) will be permanently deleted from the server and this device. This cannot be undone.';

  @override
  String get authDeleteConfirmAction => 'Delete permanently';

  @override
  String get authDeletedMessage => 'The account was deleted.';

  @override
  String get tripLogTitle => 'Trip log';

  @override
  String get tripSaveAction => 'Save';

  @override
  String get tripLogAction => 'Log a trip';

  @override
  String get tripPickArea => 'Pick an area';

  @override
  String get tripPickAreaFirst => 'Pick an area first, then tick the routes.';

  @override
  String get tripNoteLabel => 'Trip notes';

  @override
  String get tripPhotosTitle => 'Photos';

  @override
  String get tripPhotosOffline => 'Photos require an internet connection.';

  @override
  String get tripRoutesTitle => 'Routes climbed';

  @override
  String get tripRouteFilterHint => 'Filter routes by name';

  @override
  String tripSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trip saved — $count ascents logged.',
      one: 'Trip saved — 1 ascent logged.',
    );
    return '$_temp0';
  }

  @override
  String tripPhotosFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trip saved, but $count photos failed to upload.',
      one: 'Trip saved, but 1 photo failed to upload.',
    );
    return '$_temp0';
  }

  @override
  String get tripDeleteAction => 'Delete trip';

  @override
  String get tripDeleted => 'The trip and its ascents were deleted.';

  @override
  String get offlineDownloadAction => 'Download offline';

  @override
  String get offlineDownloadedLabel => 'Downloaded';

  @override
  String offlineDownloadProgress(int percent) {
    return 'Downloading… $percent %';
  }

  @override
  String get offlineDownloadDone =>
      'Area downloaded — map and topos work without a signal.';

  @override
  String offlineDownloadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files failed to download — try again.',
      one: '1 file failed to download — try again.',
    );
    return '$_temp0';
  }

  @override
  String get weatherAction => 'Weather';

  @override
  String get weatherTitle => 'Weather';

  @override
  String get weatherLoadFailed =>
      'The forecast could not be loaded — are you online?';

  @override
  String get topoSectionTitle => 'Sector topo & photos';

  @override
  String get topoAddTooltip => 'Add photo';

  @override
  String get topoUploadFailed =>
      'The photo failed to upload — please try again.';

  @override
  String get topoDeleteConfirmTitle => 'Delete this photo?';

  @override
  String get topoDeleteAction => 'Delete';

  @override
  String get topoEmptyManagerHint =>
      'As the area manager you can upload a sector topo with the routes here.';

  @override
  String get ratingCommunityLabel => 'Community rating';

  @override
  String get ratingNone => 'Not rated yet';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ratings',
      one: '1 rating',
    );
    return '$_temp0';
  }

  @override
  String get ratingYourLabel => 'Your rating';

  @override
  String get ratingSignInHint => 'Sign in on the Profile tab to rate a route.';

  @override
  String get ratingSaveFailed =>
      'The rating could not be saved — please try again.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmpty => 'No comments yet. Be the first!';

  @override
  String get commentsLoadFailed =>
      'Comments could not be loaded — are you online?';

  @override
  String get commentsSendFailed => 'The action failed — please try again.';

  @override
  String get commentsSignInHint =>
      'Sign in on the Profile tab to add a comment.';

  @override
  String get commentsComposerHint => 'Write a comment…';

  @override
  String get commentsSendTooltip => 'Send comment';

  @override
  String get commentsDeleteTooltip => 'Delete comment';

  @override
  String get commentsAnonymous => 'Climber';

  @override
  String get issueReportAction => 'Report an issue';

  @override
  String get issueReportTitle => 'Issue report';

  @override
  String get issueReportHint =>
      'Describe the issue (worn bolt, loose block, access problem…)';

  @override
  String get issueReportSignInHint =>
      'Sign in on the Profile tab to report an issue.';

  @override
  String get issueReportSent => 'Thank you, the issue has been reported.';

  @override
  String get issueReportFailed =>
      'The report could not be sent — please try again.';

  @override
  String get issueReportSubmit => 'Send';

  @override
  String get profileIssuesTitle => 'Issue reports';

  @override
  String get issueStatusOpen => 'Open';

  @override
  String get issueStatusResolved => 'Resolved';

  @override
  String get issueStatusDismissed => 'Dismissed';

  @override
  String get issueMarkResolved => 'Mark as resolved';

  @override
  String get issueMarkDismissed => 'Dismiss';

  @override
  String get profileDisplayNameLabel => 'Display name';

  @override
  String get profileDisplayNameHint => 'Name shown with comments';

  @override
  String get profileDisplayNameSaved => 'Name saved.';

  @override
  String get commonSave => 'Save';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetTitle => 'Password reset';

  @override
  String get authResetSendCode => 'Send code';

  @override
  String get authResetCodeSent =>
      'We sent you an email with a verification code.';

  @override
  String get authResetCodeLabel => 'Code from the email';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authResetConfirm => 'Set password';

  @override
  String get commonCancel => 'Cancel';

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
  String get profileCatalogCheckUpdates => 'Check for data updates';

  @override
  String get profileCatalogUpToDate => 'The rock data is up to date.';

  @override
  String profileCatalogUpdated(int version) {
    return 'Catalog updated (version $version).';
  }

  @override
  String get profileCatalogUpdateFailed =>
      'The update could not be downloaded — try again later.';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferredGradeLabel => 'Preferred grade scale';

  @override
  String get settingsPreferredGradeOriginal => 'Original (no conversion)';

  @override
  String get settingsPreferredGradeHint =>
      'An approximate conversion is shown next to the original grade.';

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
