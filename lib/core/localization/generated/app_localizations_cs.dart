// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Crux CZ';

  @override
  String get appTagline => 'Průvodce českými skalami';

  @override
  String get navDiscover => 'Objevovat';

  @override
  String get navAreas => 'Oblasti';

  @override
  String get navDiary => 'Deník';

  @override
  String get navCommunity => 'Komunita';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Zkusit znovu';

  @override
  String get commonErrorTitle => 'Něco se pokazilo';

  @override
  String get commonDataLoadError =>
      'Data se nepodařilo načíst. Zkuste to prosím znovu.';

  @override
  String get commonClearFilters => 'Zrušit filtry';

  @override
  String get discoverSearchHint => 'Hledat oblast, region nebo skálu…';

  @override
  String get discoverFeaturedTitle => 'Doporučené oblasti';

  @override
  String get discoverRecentTitle => 'Naposledy zobrazené';

  @override
  String get discoverMyClimbingTitle => 'Moje lezení';

  @override
  String get discoverProjects => 'Projekty';

  @override
  String get discoverFavorites => 'Oblíbené cesty';

  @override
  String get discoverBrowseAllAreas => 'Procházet všechny oblasti';

  @override
  String get discoverDataSourceTitle => 'Zdroj dat';

  @override
  String get discoverDataSourceBody =>
      'Data pocházejí z Databáze skal ČHS (horosvaz.cz). Jde o offline kopii pořízenou při vývoji aplikace — aktuální stav, omezení a podmínky lezení si vždy ověřujte přímo v databázi ČHS.';

  @override
  String get discoverRestrictionsTitle => 'Aktuální omezení';

  @override
  String get areasTitle => 'Oblasti';

  @override
  String get areasSearchHint => 'Hledat podle názvu, regionu nebo popisu';

  @override
  String areasResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oblastí',
      few: '$count oblasti',
      one: '1 oblast',
    );
    return '$_temp0';
  }

  @override
  String get areasEmptyTitle => 'Nic jsme nenašli';

  @override
  String get areasEmptyBody =>
      'Zkuste upravit hledaný výraz nebo zrušit filtry.';

  @override
  String get filterClimbingType => 'Typ lezení';

  @override
  String get filterRockType => 'Typ skály';

  @override
  String get filterRegion => 'Region';

  @override
  String get areasSortRouteCount => 'Počet cest';

  @override
  String get areasSortDistance => 'Nejbližší';

  @override
  String get locationUnavailable =>
      'Polohu se nepodařilo zjistit. Zkontrolujte oprávnění k poloze a zapnuté polohové služby.';

  @override
  String sectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sektorů',
      few: '$count sektory',
      one: '1 sektor',
    );
    return '$_temp0';
  }

  @override
  String routesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cest',
      few: '$count cesty',
      one: '1 cesta',
    );
    return '$_temp0';
  }

  @override
  String get climbingTypeSport => 'Sportovní';

  @override
  String get climbingTypeTrad => 'Tradiční';

  @override
  String get climbingTypeBoulder => 'Bouldering';

  @override
  String get rockTypeSandstone => 'Pískovec';

  @override
  String get rockTypeLimestone => 'Vápenec';

  @override
  String get rockTypeGranite => 'Žula';

  @override
  String get rockTypeGneiss => 'Rula';

  @override
  String get rockTypeBasalt => 'Čedič';

  @override
  String get rockTypeOther => 'Jiná skála';

  @override
  String get gradingSystemUiaa => 'UIAA';

  @override
  String get gradingSystemFrench => 'Francouzská';

  @override
  String get gradingSystemCzechSandstone => 'Saská (pískovcová)';

  @override
  String get gradingSystemFontainebleau => 'Fontainebleau';

  @override
  String get gradingSystemVScale => 'V-škála';

  @override
  String get gradingSystemYds => 'YDS';

  @override
  String get gradingSystemBritish => 'Britská';

  @override
  String get severityInfo => 'Informace';

  @override
  String get severityWarning => 'Upozornění';

  @override
  String get severityClosure => 'Zákaz lezení';

  @override
  String get areaDetailAboutTitle => 'O oblasti';

  @override
  String get areaDetailAccessTitle => 'Přístup';

  @override
  String areaDetailApproachTime(int minutes) {
    return '$minutes min chůze';
  }

  @override
  String get areaDetailParkingTitle => 'Parkování';

  @override
  String get areaDetailRestrictionsTitle => 'Omezení a upozornění';

  @override
  String get areaDetailSectorsTitle => 'Sektory';

  @override
  String get navigateAction => 'Navigovat';

  @override
  String get navigationFailed => 'Mapovou aplikaci se nepodařilo otevřít.';

  @override
  String get sectorRoutesTitle => 'Cesty';

  @override
  String get sectorIndependentRoutesTitle => 'Samostatné cesty';

  @override
  String get sectorAccessTitle => 'Přístup k sektoru';

  @override
  String get sortGuidebook => 'Průvodce';

  @override
  String get sortByName => 'Název';

  @override
  String get sortByGrade => 'Obtížnost';

  @override
  String get routeTypeLabel => 'Typ';

  @override
  String get routeLengthLabel => 'Délka';

  @override
  String routeLengthMeters(int meters) {
    return '$meters m';
  }

  @override
  String get routeGradeLabel => 'Obtížnost';

  @override
  String get routeDescriptionTitle => 'Popis';

  @override
  String get routeProtectionTitle => 'Jištění';

  @override
  String get routeFirstAscentTitle => 'Prvovýstup';

  @override
  String get routeWarningsTitle => 'Upozornění';

  @override
  String get routeLocationTitle => 'Umístění';

  @override
  String get favoriteAdd => 'Přidat do oblíbených';

  @override
  String get favoriteRemove => 'Odebrat z oblíbených';

  @override
  String get projectAdd => 'Přidat do projektů';

  @override
  String get projectRemove => 'Odebrat z projektů';

  @override
  String get favoriteLabel => 'Oblíbená';

  @override
  String get projectLabel => 'Projekt';

  @override
  String get diaryTitle => 'Deník';

  @override
  String get diaryEmptyTitle => 'Zatím žádné přelezy';

  @override
  String get diaryEmptyBody =>
      'Otevřete detail cesty a zapište svůj první přelez.';

  @override
  String diaryAscentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count přelezů',
      few: '$count přelezy',
      one: '1 přelez',
    );
    return '$_temp0';
  }

  @override
  String get logAscentAction => 'Zapsat přelez';

  @override
  String get logAscentTitle => 'Zápis přelezu';

  @override
  String get ascentStyleLabel => 'Styl přelezu';

  @override
  String get ascentDateLabel => 'Datum';

  @override
  String get ascentNoteLabel => 'Poznámka';

  @override
  String get ascentNoteHint => 'Jak to šlo, podmínky, spolulezci…';

  @override
  String get ascentSaveAction => 'Uložit přelez';

  @override
  String get ascentLoggedMessage => 'Přelez byl uložen do deníku.';

  @override
  String get ascentDeleteAction => 'Smazat záznam';

  @override
  String get ascentDeletedMessage => 'Záznam byl smazán.';

  @override
  String get routeMyAscentsTitle => 'Moje přelezy';

  @override
  String get routeClimbedLabel => 'Přelezeno';

  @override
  String get diaryStatsTotalLabel => 'Celkem';

  @override
  String get diaryStatsThisYearLabel => 'Letos';

  @override
  String get diaryStatsRoutesLabel => 'Různých cest';

  @override
  String get diaryFilterEmptyTitle => 'Nic neodpovídá filtru';

  @override
  String get diaryFilterEmptyBody =>
      'Žádný přelez nemá vybraný styl. Zrušte filtr a záznamy se znovu zobrazí.';

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
  String get ascentStyleSolo => 'Sólo';

  @override
  String get ascentStyleAttempt => 'Pokus';

  @override
  String get comingSoonTitle => 'Připravujeme';

  @override
  String get comingSoonBody =>
      'Tato část aplikace bude dostupná v některé z dalších fází vývoje.';

  @override
  String get diaryDescription =>
      'Záznamy výstupů, statistiky a přehled vašich projektů na jednom místě.';

  @override
  String get communityDescription =>
      'Komentáře, novinky ze skal a sdílení s ostatními lezci.';

  @override
  String get profileDescription =>
      'Váš lezecký profil, nastavení a synchronizace mezi zařízeními.';

  @override
  String get notFoundTitle => 'Nenalezeno';

  @override
  String get areaNotFound => 'Oblast se nepodařilo najít.';

  @override
  String get sectorNotFound => 'Sektor se nepodařilo najít.';

  @override
  String get routeNotFound => 'Cestu se nepodařilo najít.';
}
