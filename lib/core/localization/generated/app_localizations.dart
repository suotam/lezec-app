import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In cs, this message translates to:
  /// **'Crux CZ'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In cs, this message translates to:
  /// **'Průvodce českými skalami'**
  String get appTagline;

  /// No description provided for @navDiscover.
  ///
  /// In cs, this message translates to:
  /// **'Objevovat'**
  String get navDiscover;

  /// No description provided for @navAreas.
  ///
  /// In cs, this message translates to:
  /// **'Oblasti'**
  String get navAreas;

  /// No description provided for @navDiary.
  ///
  /// In cs, this message translates to:
  /// **'Deník'**
  String get navDiary;

  /// No description provided for @navCommunity.
  ///
  /// In cs, this message translates to:
  /// **'Komunita'**
  String get navCommunity;

  /// No description provided for @navProfile.
  ///
  /// In cs, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @commonRetry.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get commonRetry;

  /// No description provided for @commonErrorTitle.
  ///
  /// In cs, this message translates to:
  /// **'Něco se pokazilo'**
  String get commonErrorTitle;

  /// No description provided for @commonDataLoadError.
  ///
  /// In cs, this message translates to:
  /// **'Data se nepodařilo načíst. Zkuste to prosím znovu.'**
  String get commonDataLoadError;

  /// No description provided for @commonClearFilters.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit filtry'**
  String get commonClearFilters;

  /// No description provided for @discoverSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat oblast, region nebo skálu…'**
  String get discoverSearchHint;

  /// No description provided for @discoverFeaturedTitle.
  ///
  /// In cs, this message translates to:
  /// **'Doporučené oblasti'**
  String get discoverFeaturedTitle;

  /// No description provided for @discoverRecentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Naposledy zobrazené'**
  String get discoverRecentTitle;

  /// No description provided for @discoverMyClimbingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Moje lezení'**
  String get discoverMyClimbingTitle;

  /// No description provided for @discoverProjects.
  ///
  /// In cs, this message translates to:
  /// **'Projekty'**
  String get discoverProjects;

  /// No description provided for @discoverFavorites.
  ///
  /// In cs, this message translates to:
  /// **'Oblíbené cesty'**
  String get discoverFavorites;

  /// No description provided for @discoverBrowseAllAreas.
  ///
  /// In cs, this message translates to:
  /// **'Procházet všechny oblasti'**
  String get discoverBrowseAllAreas;

  /// No description provided for @discoverDataSourceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zdroj dat'**
  String get discoverDataSourceTitle;

  /// No description provided for @discoverDataSourceBody.
  ///
  /// In cs, this message translates to:
  /// **'Data pocházejí z Databáze skal ČHS (horosvaz.cz). Jde o offline kopii pořízenou při vývoji aplikace — aktuální stav, omezení a podmínky lezení si vždy ověřujte přímo v databázi ČHS.'**
  String get discoverDataSourceBody;

  /// No description provided for @discoverRestrictionsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Aktuální omezení'**
  String get discoverRestrictionsTitle;

  /// No description provided for @areasTitle.
  ///
  /// In cs, this message translates to:
  /// **'Oblasti'**
  String get areasTitle;

  /// No description provided for @areasSearchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat podle názvu, regionu nebo popisu'**
  String get areasSearchHint;

  /// No description provided for @areasResultsCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{1 oblast} few{{count} oblasti} other{{count} oblastí}}'**
  String areasResultsCount(int count);

  /// No description provided for @areasEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nic jsme nenašli'**
  String get areasEmptyTitle;

  /// No description provided for @areasEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Zkuste upravit hledaný výraz nebo zrušit filtry.'**
  String get areasEmptyBody;

  /// No description provided for @filterClimbingType.
  ///
  /// In cs, this message translates to:
  /// **'Typ lezení'**
  String get filterClimbingType;

  /// No description provided for @filterRockType.
  ///
  /// In cs, this message translates to:
  /// **'Typ skály'**
  String get filterRockType;

  /// No description provided for @filterRegion.
  ///
  /// In cs, this message translates to:
  /// **'Region'**
  String get filterRegion;

  /// No description provided for @areasSortRouteCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet cest'**
  String get areasSortRouteCount;

  /// No description provided for @areasSortDistance.
  ///
  /// In cs, this message translates to:
  /// **'Nejbližší'**
  String get areasSortDistance;

  /// No description provided for @locationUnavailable.
  ///
  /// In cs, this message translates to:
  /// **'Polohu se nepodařilo zjistit. Zkontrolujte oprávnění k poloze a zapnuté polohové služby.'**
  String get locationUnavailable;

  /// No description provided for @sectorsCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{1 sektor} few{{count} sektory} other{{count} sektorů}}'**
  String sectorsCount(int count);

  /// No description provided for @routesCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{1 cesta} few{{count} cesty} other{{count} cest}}'**
  String routesCount(int count);

  /// No description provided for @climbingTypeSport.
  ///
  /// In cs, this message translates to:
  /// **'Sportovní'**
  String get climbingTypeSport;

  /// No description provided for @climbingTypeTrad.
  ///
  /// In cs, this message translates to:
  /// **'Tradiční'**
  String get climbingTypeTrad;

  /// No description provided for @climbingTypeBoulder.
  ///
  /// In cs, this message translates to:
  /// **'Bouldering'**
  String get climbingTypeBoulder;

  /// No description provided for @rockTypeSandstone.
  ///
  /// In cs, this message translates to:
  /// **'Pískovec'**
  String get rockTypeSandstone;

  /// No description provided for @rockTypeLimestone.
  ///
  /// In cs, this message translates to:
  /// **'Vápenec'**
  String get rockTypeLimestone;

  /// No description provided for @rockTypeGranite.
  ///
  /// In cs, this message translates to:
  /// **'Žula'**
  String get rockTypeGranite;

  /// No description provided for @rockTypeGneiss.
  ///
  /// In cs, this message translates to:
  /// **'Rula'**
  String get rockTypeGneiss;

  /// No description provided for @rockTypeBasalt.
  ///
  /// In cs, this message translates to:
  /// **'Čedič'**
  String get rockTypeBasalt;

  /// No description provided for @rockTypeOther.
  ///
  /// In cs, this message translates to:
  /// **'Jiná skála'**
  String get rockTypeOther;

  /// No description provided for @gradingSystemUiaa.
  ///
  /// In cs, this message translates to:
  /// **'UIAA'**
  String get gradingSystemUiaa;

  /// No description provided for @gradingSystemFrench.
  ///
  /// In cs, this message translates to:
  /// **'Francouzská'**
  String get gradingSystemFrench;

  /// No description provided for @gradingSystemCzechSandstone.
  ///
  /// In cs, this message translates to:
  /// **'Saská (pískovcová)'**
  String get gradingSystemCzechSandstone;

  /// No description provided for @gradingSystemFontainebleau.
  ///
  /// In cs, this message translates to:
  /// **'Fontainebleau'**
  String get gradingSystemFontainebleau;

  /// No description provided for @gradingSystemVScale.
  ///
  /// In cs, this message translates to:
  /// **'V-škála'**
  String get gradingSystemVScale;

  /// No description provided for @gradingSystemYds.
  ///
  /// In cs, this message translates to:
  /// **'YDS'**
  String get gradingSystemYds;

  /// No description provided for @gradingSystemBritish.
  ///
  /// In cs, this message translates to:
  /// **'Britská'**
  String get gradingSystemBritish;

  /// No description provided for @severityInfo.
  ///
  /// In cs, this message translates to:
  /// **'Informace'**
  String get severityInfo;

  /// No description provided for @severityWarning.
  ///
  /// In cs, this message translates to:
  /// **'Upozornění'**
  String get severityWarning;

  /// No description provided for @severityClosure.
  ///
  /// In cs, this message translates to:
  /// **'Zákaz lezení'**
  String get severityClosure;

  /// No description provided for @areaDetailAboutTitle.
  ///
  /// In cs, this message translates to:
  /// **'O oblasti'**
  String get areaDetailAboutTitle;

  /// No description provided for @areaDetailAccessTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přístup'**
  String get areaDetailAccessTitle;

  /// No description provided for @areaDetailApproachTime.
  ///
  /// In cs, this message translates to:
  /// **'{minutes} min chůze'**
  String areaDetailApproachTime(int minutes);

  /// No description provided for @areaDetailParkingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Parkování'**
  String get areaDetailParkingTitle;

  /// No description provided for @areaDetailRestrictionsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Omezení a upozornění'**
  String get areaDetailRestrictionsTitle;

  /// No description provided for @areaDetailSectorsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sektory'**
  String get areaDetailSectorsTitle;

  /// No description provided for @navigateAction.
  ///
  /// In cs, this message translates to:
  /// **'Navigovat'**
  String get navigateAction;

  /// No description provided for @navigationFailed.
  ///
  /// In cs, this message translates to:
  /// **'Mapovou aplikaci se nepodařilo otevřít.'**
  String get navigationFailed;

  /// No description provided for @sectorRoutesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Cesty'**
  String get sectorRoutesTitle;

  /// No description provided for @sectorIndependentRoutesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Samostatné cesty'**
  String get sectorIndependentRoutesTitle;

  /// No description provided for @sectorAccessTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přístup k sektoru'**
  String get sectorAccessTitle;

  /// No description provided for @sortGuidebook.
  ///
  /// In cs, this message translates to:
  /// **'Průvodce'**
  String get sortGuidebook;

  /// No description provided for @sortByName.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get sortByName;

  /// No description provided for @sortByGrade.
  ///
  /// In cs, this message translates to:
  /// **'Obtížnost'**
  String get sortByGrade;

  /// No description provided for @routeTypeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get routeTypeLabel;

  /// No description provided for @routeLengthLabel.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get routeLengthLabel;

  /// No description provided for @routeLengthMeters.
  ///
  /// In cs, this message translates to:
  /// **'{meters} m'**
  String routeLengthMeters(int meters);

  /// No description provided for @routeGradeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Obtížnost'**
  String get routeGradeLabel;

  /// No description provided for @routeDescriptionTitle.
  ///
  /// In cs, this message translates to:
  /// **'Popis'**
  String get routeDescriptionTitle;

  /// No description provided for @routeProtectionTitle.
  ///
  /// In cs, this message translates to:
  /// **'Jištění'**
  String get routeProtectionTitle;

  /// No description provided for @routeFirstAscentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Prvovýstup'**
  String get routeFirstAscentTitle;

  /// No description provided for @routeWarningsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upozornění'**
  String get routeWarningsTitle;

  /// No description provided for @routeLocationTitle.
  ///
  /// In cs, this message translates to:
  /// **'Umístění'**
  String get routeLocationTitle;

  /// No description provided for @favoriteAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat do oblíbených'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat z oblíbených'**
  String get favoriteRemove;

  /// No description provided for @projectAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat do projektů'**
  String get projectAdd;

  /// No description provided for @projectRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat z projektů'**
  String get projectRemove;

  /// No description provided for @favoriteLabel.
  ///
  /// In cs, this message translates to:
  /// **'Oblíbená'**
  String get favoriteLabel;

  /// No description provided for @projectLabel.
  ///
  /// In cs, this message translates to:
  /// **'Projekt'**
  String get projectLabel;

  /// No description provided for @diaryTitle.
  ///
  /// In cs, this message translates to:
  /// **'Deník'**
  String get diaryTitle;

  /// No description provided for @diaryEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné přelezy'**
  String get diaryEmptyTitle;

  /// No description provided for @diaryEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Otevřete detail cesty a zapište svůj první přelez.'**
  String get diaryEmptyBody;

  /// No description provided for @diaryAscentsCount.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{1 přelez} few{{count} přelezy} other{{count} přelezů}}'**
  String diaryAscentsCount(int count);

  /// No description provided for @logAscentAction.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat přelez'**
  String get logAscentAction;

  /// No description provided for @logAscentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zápis přelezu'**
  String get logAscentTitle;

  /// No description provided for @ascentStyleLabel.
  ///
  /// In cs, this message translates to:
  /// **'Styl přelezu'**
  String get ascentStyleLabel;

  /// No description provided for @ascentDateLabel.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get ascentDateLabel;

  /// No description provided for @ascentNoteLabel.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get ascentNoteLabel;

  /// No description provided for @ascentNoteHint.
  ///
  /// In cs, this message translates to:
  /// **'Jak to šlo, podmínky, spolulezci…'**
  String get ascentNoteHint;

  /// No description provided for @ascentSaveAction.
  ///
  /// In cs, this message translates to:
  /// **'Uložit přelez'**
  String get ascentSaveAction;

  /// No description provided for @ascentLoggedMessage.
  ///
  /// In cs, this message translates to:
  /// **'Přelez byl uložen do deníku.'**
  String get ascentLoggedMessage;

  /// No description provided for @ascentDeleteAction.
  ///
  /// In cs, this message translates to:
  /// **'Smazat záznam'**
  String get ascentDeleteAction;

  /// No description provided for @ascentDeletedMessage.
  ///
  /// In cs, this message translates to:
  /// **'Záznam byl smazán.'**
  String get ascentDeletedMessage;

  /// No description provided for @routeMyAscentsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Moje přelezy'**
  String get routeMyAscentsTitle;

  /// No description provided for @routeClimbedLabel.
  ///
  /// In cs, this message translates to:
  /// **'Přelezeno'**
  String get routeClimbedLabel;

  /// No description provided for @diaryStatsTotalLabel.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get diaryStatsTotalLabel;

  /// No description provided for @diaryStatsThisYearLabel.
  ///
  /// In cs, this message translates to:
  /// **'Letos'**
  String get diaryStatsThisYearLabel;

  /// No description provided for @diaryStatsRoutesLabel.
  ///
  /// In cs, this message translates to:
  /// **'Různých cest'**
  String get diaryStatsRoutesLabel;

  /// No description provided for @diaryFilterEmptyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nic neodpovídá filtru'**
  String get diaryFilterEmptyTitle;

  /// No description provided for @diaryFilterEmptyBody.
  ///
  /// In cs, this message translates to:
  /// **'Žádný přelez nemá vybraný styl. Zrušte filtr a záznamy se znovu zobrazí.'**
  String get diaryFilterEmptyBody;

  /// No description provided for @ascentStyleOnsight.
  ///
  /// In cs, this message translates to:
  /// **'OS'**
  String get ascentStyleOnsight;

  /// No description provided for @ascentStyleFlash.
  ///
  /// In cs, this message translates to:
  /// **'Flash'**
  String get ascentStyleFlash;

  /// No description provided for @ascentStyleRedpoint.
  ///
  /// In cs, this message translates to:
  /// **'RP'**
  String get ascentStyleRedpoint;

  /// No description provided for @ascentStylePinkpoint.
  ///
  /// In cs, this message translates to:
  /// **'PP'**
  String get ascentStylePinkpoint;

  /// No description provided for @ascentStyleAllFree.
  ///
  /// In cs, this message translates to:
  /// **'AF'**
  String get ascentStyleAllFree;

  /// No description provided for @ascentStyleTopRope.
  ///
  /// In cs, this message translates to:
  /// **'TR'**
  String get ascentStyleTopRope;

  /// No description provided for @ascentStyleSolo.
  ///
  /// In cs, this message translates to:
  /// **'Sólo'**
  String get ascentStyleSolo;

  /// No description provided for @ascentStyleAttempt.
  ///
  /// In cs, this message translates to:
  /// **'Pokus'**
  String get ascentStyleAttempt;

  /// No description provided for @comingSoonTitle.
  ///
  /// In cs, this message translates to:
  /// **'Připravujeme'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In cs, this message translates to:
  /// **'Tato část aplikace bude dostupná v některé z dalších fází vývoje.'**
  String get comingSoonBody;

  /// No description provided for @diaryDescription.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy výstupů, statistiky a přehled vašich projektů na jednom místě.'**
  String get diaryDescription;

  /// No description provided for @communityDescription.
  ///
  /// In cs, this message translates to:
  /// **'Komentáře, novinky ze skal a sdílení s ostatními lezci.'**
  String get communityDescription;

  /// No description provided for @profileDescription.
  ///
  /// In cs, this message translates to:
  /// **'Váš lezecký profil, nastavení a synchronizace mezi zařízeními.'**
  String get profileDescription;

  /// No description provided for @notFoundTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nenalezeno'**
  String get notFoundTitle;

  /// No description provided for @areaNotFound.
  ///
  /// In cs, this message translates to:
  /// **'Oblast se nepodařilo najít.'**
  String get areaNotFound;

  /// No description provided for @sectorNotFound.
  ///
  /// In cs, this message translates to:
  /// **'Sektor se nepodařilo najít.'**
  String get sectorNotFound;

  /// No description provided for @routeNotFound.
  ///
  /// In cs, this message translates to:
  /// **'Cestu se nepodařilo najít.'**
  String get routeNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
