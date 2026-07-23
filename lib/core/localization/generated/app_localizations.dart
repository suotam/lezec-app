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
  /// **'Hledat oblasti, sektory, skály i cesty…'**
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
  /// **'Hledat oblasti, sektory, skály i cesty'**
  String get areasSearchHint;

  /// No description provided for @areasShowMapTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit mapu'**
  String get areasShowMapTooltip;

  /// No description provided for @mapMyLocationTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Moje poloha'**
  String get mapMyLocationTooltip;

  /// No description provided for @areasShowListTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit seznam'**
  String get areasShowListTooltip;

  /// No description provided for @areaDetailMapTitle.
  ///
  /// In cs, this message translates to:
  /// **'Mapa'**
  String get areaDetailMapTitle;

  /// No description provided for @searchSectorsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sektory'**
  String get searchSectorsTitle;

  /// No description provided for @searchRocksTitle.
  ///
  /// In cs, this message translates to:
  /// **'Skály a věže'**
  String get searchRocksTitle;

  /// No description provided for @searchRoutesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Cesty'**
  String get searchRoutesTitle;

  /// No description provided for @searchMoreResultsHint.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazeno prvních {count} výsledků, upřesněte hledání.'**
  String searchMoreResultsHint(int count);

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

  /// No description provided for @ascentEditAction.
  ///
  /// In cs, this message translates to:
  /// **'Upravit záznam'**
  String get ascentEditAction;

  /// No description provided for @editAscentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Úprava přelezu'**
  String get editAscentTitle;

  /// No description provided for @ascentUpdatedMessage.
  ///
  /// In cs, this message translates to:
  /// **'Záznam byl upraven.'**
  String get ascentUpdatedMessage;

  /// No description provided for @diaryAllAreas.
  ///
  /// In cs, this message translates to:
  /// **'Všechny oblasti'**
  String get diaryAllAreas;

  /// No description provided for @areaDistanceKm.
  ///
  /// In cs, this message translates to:
  /// **'{km} km'**
  String areaDistanceKm(int km);

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

  /// No description provided for @diaryGradeChartTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přelezy podle obtížnosti'**
  String get diaryGradeChartTitle;

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

  /// No description provided for @profileAccountTitle.
  ///
  /// In cs, this message translates to:
  /// **'Účet a synchronizace'**
  String get profileAccountTitle;

  /// No description provided for @authInfoBody.
  ///
  /// In cs, this message translates to:
  /// **'Účet slouží jen k záloze a synchronizaci deníku, oblíbených a projektů mezi zařízeními. Bez něj aplikace plně funguje.'**
  String get authInfoBody;

  /// No description provided for @authEmailLabel.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In cs, this message translates to:
  /// **'Heslo'**
  String get authPasswordLabel;

  /// No description provided for @authSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get authSignUp;

  /// No description provided for @authSignOut.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit se'**
  String get authSignOut;

  /// No description provided for @authConfirmEmail.
  ///
  /// In cs, this message translates to:
  /// **'Účet vytvořen. Potvrďte registraci v e-mailu a poté se přihlaste.'**
  String get authConfirmEmail;

  /// No description provided for @authFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se: {message}'**
  String authFailed(String message);

  /// No description provided for @authDeleteAccount.
  ///
  /// In cs, this message translates to:
  /// **'Smazat účet'**
  String get authDeleteAccount;

  /// No description provided for @authDeleteConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat účet?'**
  String get authDeleteConfirmTitle;

  /// No description provided for @authDeleteConfirmBody.
  ///
  /// In cs, this message translates to:
  /// **'Účet i všechna synchronizovaná data (deník, oblíbené, komentáře, fotky) budou trvale smazána ze serveru i z tohoto zařízení. Tuto akci nelze vzít zpět.'**
  String get authDeleteConfirmBody;

  /// No description provided for @authDeleteConfirmAction.
  ///
  /// In cs, this message translates to:
  /// **'Trvale smazat'**
  String get authDeleteConfirmAction;

  /// No description provided for @authDeletedMessage.
  ///
  /// In cs, this message translates to:
  /// **'Účet byl smazán.'**
  String get authDeletedMessage;

  /// No description provided for @tripLogTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zápis výjezdu'**
  String get tripLogTitle;

  /// No description provided for @tripSaveAction.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get tripSaveAction;

  /// No description provided for @tripLogAction.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat výjezd'**
  String get tripLogAction;

  /// No description provided for @tripPickArea.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat oblast'**
  String get tripPickArea;

  /// No description provided for @tripPickAreaFirst.
  ///
  /// In cs, this message translates to:
  /// **'Nejdřív vyberte oblast, pak naklikáte cesty.'**
  String get tripPickAreaFirst;

  /// No description provided for @tripNoteLabel.
  ///
  /// In cs, this message translates to:
  /// **'Popis výjezdu'**
  String get tripNoteLabel;

  /// No description provided for @tripPhotosTitle.
  ///
  /// In cs, this message translates to:
  /// **'Fotky'**
  String get tripPhotosTitle;

  /// No description provided for @tripPhotosOffline.
  ///
  /// In cs, this message translates to:
  /// **'Fotky vyžadují připojení k internetu.'**
  String get tripPhotosOffline;

  /// No description provided for @tripRoutesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přelezené cesty'**
  String get tripRoutesTitle;

  /// No description provided for @tripRouteFilterHint.
  ///
  /// In cs, this message translates to:
  /// **'Filtrovat cesty podle názvu'**
  String get tripRouteFilterHint;

  /// No description provided for @tripSaved.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Výjezd uložen — 1 přelez zapsán.} few{Výjezd uložen — {count} přelezy zapsány.} other{Výjezd uložen — {count} přelezů zapsáno.}}'**
  String tripSaved(int count);

  /// No description provided for @tripPhotosFailed.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{Výjezd uložen, ale 1 fotku se nepodařilo nahrát.} few{Výjezd uložen, ale {count} fotky se nepodařilo nahrát.} other{Výjezd uložen, ale {count} fotek se nepodařilo nahrát.}}'**
  String tripPhotosFailed(int count);

  /// No description provided for @tripDeleteAction.
  ///
  /// In cs, this message translates to:
  /// **'Smazat výjezd'**
  String get tripDeleteAction;

  /// No description provided for @tripDeleted.
  ///
  /// In cs, this message translates to:
  /// **'Výjezd byl smazán včetně přelezů.'**
  String get tripDeleted;

  /// No description provided for @topoSectionTitle.
  ///
  /// In cs, this message translates to:
  /// **'Topo a fotky sektoru'**
  String get topoSectionTitle;

  /// No description provided for @topoAddTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Přidat fotku'**
  String get topoAddTooltip;

  /// No description provided for @topoUploadFailed.
  ///
  /// In cs, this message translates to:
  /// **'Fotku se nepodařilo nahrát — zkuste to znovu.'**
  String get topoUploadFailed;

  /// No description provided for @topoDeleteConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat tuto fotku?'**
  String get topoDeleteConfirmTitle;

  /// No description provided for @topoDeleteAction.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get topoDeleteAction;

  /// No description provided for @topoEmptyManagerHint.
  ///
  /// In cs, this message translates to:
  /// **'Jako správce oblasti sem můžete nahrát topo sektoru s cestami.'**
  String get topoEmptyManagerHint;

  /// No description provided for @commentsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Komentáře'**
  String get commentsTitle;

  /// No description provided for @commentsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné komentáře. Buďte první!'**
  String get commentsEmpty;

  /// No description provided for @commentsLoadFailed.
  ///
  /// In cs, this message translates to:
  /// **'Komentáře se nepodařilo načíst — jste online?'**
  String get commentsLoadFailed;

  /// No description provided for @commentsSendFailed.
  ///
  /// In cs, this message translates to:
  /// **'Akci se nepodařilo provést — zkuste to znovu.'**
  String get commentsSendFailed;

  /// No description provided for @commentsSignInHint.
  ///
  /// In cs, this message translates to:
  /// **'Pro přidání komentáře se přihlaste v záložce Profil.'**
  String get commentsSignInHint;

  /// No description provided for @commentsComposerHint.
  ///
  /// In cs, this message translates to:
  /// **'Napsat komentář…'**
  String get commentsComposerHint;

  /// No description provided for @commentsSendTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat komentář'**
  String get commentsSendTooltip;

  /// No description provided for @commentsDeleteTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Smazat komentář'**
  String get commentsDeleteTooltip;

  /// No description provided for @commentsAnonymous.
  ///
  /// In cs, this message translates to:
  /// **'Lezec'**
  String get commentsAnonymous;

  /// No description provided for @issueReportAction.
  ///
  /// In cs, this message translates to:
  /// **'Nahlásit závadu'**
  String get issueReportAction;

  /// No description provided for @issueReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nahlášení závady'**
  String get issueReportTitle;

  /// No description provided for @issueReportHint.
  ///
  /// In cs, this message translates to:
  /// **'Popište závadu (vyklepaný kruh, nebezpečný blok, špatný přístup…)'**
  String get issueReportHint;

  /// No description provided for @issueReportSignInHint.
  ///
  /// In cs, this message translates to:
  /// **'Pro nahlášení závady se přihlaste v záložce Profil.'**
  String get issueReportSignInHint;

  /// No description provided for @issueReportSent.
  ///
  /// In cs, this message translates to:
  /// **'Děkujeme, závada byla nahlášena.'**
  String get issueReportSent;

  /// No description provided for @issueReportFailed.
  ///
  /// In cs, this message translates to:
  /// **'Nahlášení se nepodařilo odeslat — zkuste to znovu.'**
  String get issueReportFailed;

  /// No description provided for @issueReportSubmit.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat'**
  String get issueReportSubmit;

  /// No description provided for @profileIssuesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Hlášení závad'**
  String get profileIssuesTitle;

  /// No description provided for @issueStatusOpen.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené'**
  String get issueStatusOpen;

  /// No description provided for @issueStatusResolved.
  ///
  /// In cs, this message translates to:
  /// **'Vyřešené'**
  String get issueStatusResolved;

  /// No description provided for @issueStatusDismissed.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnuté'**
  String get issueStatusDismissed;

  /// No description provided for @issueMarkResolved.
  ///
  /// In cs, this message translates to:
  /// **'Označit jako vyřešené'**
  String get issueMarkResolved;

  /// No description provided for @issueMarkDismissed.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnout'**
  String get issueMarkDismissed;

  /// No description provided for @profileDisplayNameLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazované jméno'**
  String get profileDisplayNameLabel;

  /// No description provided for @profileDisplayNameHint.
  ///
  /// In cs, this message translates to:
  /// **'Jméno u komentářů'**
  String get profileDisplayNameHint;

  /// No description provided for @profileDisplayNameSaved.
  ///
  /// In cs, this message translates to:
  /// **'Jméno bylo uloženo.'**
  String get profileDisplayNameSaved;

  /// No description provided for @commonSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get commonSave;

  /// No description provided for @authForgotPassword.
  ///
  /// In cs, this message translates to:
  /// **'Zapomenuté heslo?'**
  String get authForgotPassword;

  /// No description provided for @authResetTitle.
  ///
  /// In cs, this message translates to:
  /// **'Obnova hesla'**
  String get authResetTitle;

  /// No description provided for @authResetSendCode.
  ///
  /// In cs, this message translates to:
  /// **'Poslat kód'**
  String get authResetSendCode;

  /// No description provided for @authResetCodeSent.
  ///
  /// In cs, this message translates to:
  /// **'Poslali jsme vám e-mail s ověřovacím kódem.'**
  String get authResetCodeSent;

  /// No description provided for @authResetCodeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kód z e-mailu'**
  String get authResetCodeLabel;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nové heslo'**
  String get authNewPasswordLabel;

  /// No description provided for @authResetConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Nastavit heslo'**
  String get authResetConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get commonCancel;

  /// No description provided for @profileSyncNow.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizovat'**
  String get profileSyncNow;

  /// No description provided for @profileSyncedAt.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizováno v {time}'**
  String profileSyncedAt(String time);

  /// No description provided for @profileSyncNever.
  ///
  /// In cs, this message translates to:
  /// **'Zatím nesynchronizováno'**
  String get profileSyncNever;

  /// No description provided for @profileSyncFailed.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace se nepodařila — zkontrolujte připojení.'**
  String get profileSyncFailed;

  /// No description provided for @profileVersionLabel.
  ///
  /// In cs, this message translates to:
  /// **'Verze'**
  String get profileVersionLabel;

  /// No description provided for @profileDataTitle.
  ///
  /// In cs, this message translates to:
  /// **'Data katalogu'**
  String get profileDataTitle;

  /// No description provided for @profileCatalogVersionLabel.
  ///
  /// In cs, this message translates to:
  /// **'Verze katalogu'**
  String get profileCatalogVersionLabel;

  /// No description provided for @profileCatalogImportedLabel.
  ///
  /// In cs, this message translates to:
  /// **'Importováno'**
  String get profileCatalogImportedLabel;

  /// No description provided for @profileCatalogCheckUpdates.
  ///
  /// In cs, this message translates to:
  /// **'Zkontrolovat aktualizace dat'**
  String get profileCatalogCheckUpdates;

  /// No description provided for @profileCatalogUpToDate.
  ///
  /// In cs, this message translates to:
  /// **'Data skal jsou aktuální.'**
  String get profileCatalogUpToDate;

  /// No description provided for @profileCatalogUpdated.
  ///
  /// In cs, this message translates to:
  /// **'Katalog aktualizován (verze {version}).'**
  String profileCatalogUpdated(int version);

  /// No description provided for @profileCatalogUpdateFailed.
  ///
  /// In cs, this message translates to:
  /// **'Aktualizaci se nepodařilo stáhnout — zkuste to později.'**
  String get profileCatalogUpdateFailed;

  /// No description provided for @profileMapCacheTitle.
  ///
  /// In cs, this message translates to:
  /// **'Mapová cache'**
  String get profileMapCacheTitle;

  /// No description provided for @profileMapCacheBody.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazené výřezy map se ukládají pro použití bez signálu.'**
  String get profileMapCacheBody;

  /// No description provided for @profileMapCacheClear.
  ///
  /// In cs, this message translates to:
  /// **'Vymazat'**
  String get profileMapCacheClear;

  /// No description provided for @profileMapCacheCleared.
  ///
  /// In cs, this message translates to:
  /// **'Mapová cache byla vymazána.'**
  String get profileMapCacheCleared;

  /// No description provided for @settingsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settingsTitle;

  /// No description provided for @settingsPreferredGradeLabel.
  ///
  /// In cs, this message translates to:
  /// **'Preferovaná stupnice'**
  String get settingsPreferredGradeLabel;

  /// No description provided for @settingsPreferredGradeOriginal.
  ///
  /// In cs, this message translates to:
  /// **'Původní (bez převodu)'**
  String get settingsPreferredGradeOriginal;

  /// No description provided for @settingsPreferredGradeHint.
  ///
  /// In cs, this message translates to:
  /// **'Přibližný převod se zobrazí vedle původní klasifikace.'**
  String get settingsPreferredGradeHint;

  /// No description provided for @profileSourcesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zdroje dat'**
  String get profileSourcesTitle;

  /// No description provided for @profileSourcesBody.
  ///
  /// In cs, this message translates to:
  /// **'Databáze skal a cest vychází z veřejné Databáze skal ČR Českého horolezeckého svazu (horosvaz.cz). Jde o offline kopii — před lezením vždy ověřte aktuální podmínky a omezení u zdroje. Mapové podklady poskytuje OpenStreetMap, případně Mapy.com (Seznam.cz).'**
  String get profileSourcesBody;

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
