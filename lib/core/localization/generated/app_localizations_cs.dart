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
  String get discoverSearchHint => 'Hledat oblasti, sektory, skály i cesty…';

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
  String get discoverTopRatedTitle => 'Nejlépe hodnocené cesty';

  @override
  String get discoverRestrictionsTitle => 'Aktuální omezení';

  @override
  String get areasTitle => 'Oblasti';

  @override
  String get areasSearchHint => 'Hledat oblasti, sektory, skály i cesty';

  @override
  String get areasShowMapTooltip => 'Zobrazit mapu';

  @override
  String get mapMyLocationTooltip => 'Moje poloha';

  @override
  String get areasShowListTooltip => 'Zobrazit seznam';

  @override
  String get areaDetailMapTitle => 'Mapa';

  @override
  String get searchSectorsTitle => 'Sektory';

  @override
  String get searchRocksTitle => 'Skály a věže';

  @override
  String get searchRoutesTitle => 'Cesty';

  @override
  String searchMoreResultsHint(int count) {
    return 'Zobrazeno prvních $count výsledků, upřesněte hledání.';
  }

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
  String get smartSearchAction => 'Najít vhodnou oblast';

  @override
  String get smartSearchTitle => 'Najít oblast';

  @override
  String get smartSearchIntro =>
      'Zvolte disciplínu, obtížnost a odkud to máte mít blízko.';

  @override
  String get smartDisciplineRoutes => 'Cesty';

  @override
  String get smartDisciplineBoulders => 'Bouldery';

  @override
  String get smartGradeLabel => 'Obtížnost';

  @override
  String get smartGradeAny => 'libovolná';

  @override
  String smartGradeRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get smartOriginLabel => 'Odkud';

  @override
  String get smartOriginMyLocation => 'Moje poloha';

  @override
  String get smartOriginPickTown => 'Vybrat město';

  @override
  String get smartOriginNone => 'Bez omezení vzdálenosti';

  @override
  String get smartRadiusLabel => 'Do vzdálenosti (vzdušně)';

  @override
  String smartRadiusValue(int km) {
    return '$km km';
  }

  @override
  String get smartResultsTitle => 'Výsledky';

  @override
  String get smartEmptyTitle => 'Nic neodpovídá';

  @override
  String get smartEmptyBody =>
      'Zkuste rozšířit rozsah obtížnosti nebo zvětšit vzdálenost.';

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
  String get ascentEditAction => 'Upravit záznam';

  @override
  String get editAscentTitle => 'Úprava přelezu';

  @override
  String get ascentUpdatedMessage => 'Záznam byl upraven.';

  @override
  String get diaryAllAreas => 'Všechny oblasti';

  @override
  String areaDistanceKm(int km) {
    return '$km km';
  }

  @override
  String get routeMyAscentsTitle => 'Moje přelezy';

  @override
  String get routeClimbedLabel => 'Přelezeno';

  @override
  String get diaryGradeChartTitle => 'Přelezy podle obtížnosti';

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
  String get profileAccountTitle => 'Účet a synchronizace';

  @override
  String get authInfoBody =>
      'Účet slouží jen k záloze a synchronizaci deníku, oblíbených a projektů mezi zařízeními. Bez něj aplikace plně funguje.';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Heslo';

  @override
  String get authSignIn => 'Přihlásit se';

  @override
  String get authSignUp => 'Vytvořit účet';

  @override
  String get authSignOut => 'Odhlásit se';

  @override
  String get authConfirmEmail =>
      'Účet vytvořen. Potvrďte registraci v e-mailu a poté se přihlaste.';

  @override
  String authFailed(String message) {
    return 'Nepodařilo se: $message';
  }

  @override
  String get authDeleteAccount => 'Smazat účet';

  @override
  String get authDeleteConfirmTitle => 'Smazat účet?';

  @override
  String get authDeleteConfirmBody =>
      'Účet i všechna synchronizovaná data (deník, oblíbené, komentáře, fotky) budou trvale smazána ze serveru i z tohoto zařízení. Tuto akci nelze vzít zpět.';

  @override
  String get authDeleteConfirmAction => 'Trvale smazat';

  @override
  String get authDeletedMessage => 'Účet byl smazán.';

  @override
  String get tripLogTitle => 'Zápis výjezdu';

  @override
  String get tripSaveAction => 'Uložit';

  @override
  String get tripLogAction => 'Zapsat výjezd';

  @override
  String get tripPickArea => 'Vybrat oblast';

  @override
  String get tripPickAreaFirst =>
      'Nejdřív vyberte oblast, pak naklikáte cesty.';

  @override
  String get tripNoteLabel => 'Popis výjezdu';

  @override
  String get tripPhotosTitle => 'Fotky';

  @override
  String get tripPhotosOffline => 'Fotky vyžadují připojení k internetu.';

  @override
  String get tripRoutesTitle => 'Přelezené cesty';

  @override
  String get tripRouteFilterHint => 'Filtrovat cesty podle názvu';

  @override
  String tripSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Výjezd uložen — $count přelezů zapsáno.',
      few: 'Výjezd uložen — $count přelezy zapsány.',
      one: 'Výjezd uložen — 1 přelez zapsán.',
    );
    return '$_temp0';
  }

  @override
  String tripPhotosFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Výjezd uložen, ale $count fotek se nepodařilo nahrát.',
      few: 'Výjezd uložen, ale $count fotky se nepodařilo nahrát.',
      one: 'Výjezd uložen, ale 1 fotku se nepodařilo nahrát.',
    );
    return '$_temp0';
  }

  @override
  String get tripDeleteAction => 'Smazat výjezd';

  @override
  String get tripDeleted => 'Výjezd byl smazán včetně přelezů.';

  @override
  String get offlineDownloadAction => 'Stáhnout offline';

  @override
  String get offlineDownloadedLabel => 'Staženo offline';

  @override
  String offlineDownloadProgress(int percent) {
    return 'Stahuji… $percent %';
  }

  @override
  String get offlineDownloadDone =>
      'Oblast je stažená — mapa i topo fungují bez signálu.';

  @override
  String offlineDownloadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count souborů se nepodařilo stáhnout — zkuste to znovu.',
      few: '$count soubory se nepodařilo stáhnout — zkuste to znovu.',
      one: '1 soubor se nepodařilo stáhnout — zkuste to znovu.',
    );
    return '$_temp0';
  }

  @override
  String get weatherAction => 'Počasí';

  @override
  String get weatherTitle => 'Počasí';

  @override
  String get weatherLoadFailed =>
      'Předpověď se nepodařilo načíst — jste online?';

  @override
  String get topoSectionTitle => 'Topo a fotky sektoru';

  @override
  String get topoAddTooltip => 'Přidat fotku';

  @override
  String get topoUploadFailed =>
      'Fotku se nepodařilo nahrát — zkuste to znovu.';

  @override
  String get topoDeleteConfirmTitle => 'Smazat tuto fotku?';

  @override
  String get topoDeleteAction => 'Smazat';

  @override
  String get topoEmptyManagerHint =>
      'Jako správce oblasti sem můžete nahrát topo sektoru s cestami.';

  @override
  String get ratingCommunityLabel => 'Hodnocení komunity';

  @override
  String get ratingNone => 'Zatím nehodnoceno';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hodnocení',
      few: '$count hodnocení',
      one: '1 hodnocení',
    );
    return '$_temp0';
  }

  @override
  String get ratingYourLabel => 'Vaše hodnocení';

  @override
  String get ratingSignInHint =>
      'Pro hodnocení cesty se přihlaste v záložce Profil.';

  @override
  String get ratingSaveFailed =>
      'Hodnocení se nepodařilo uložit — zkuste to znovu.';

  @override
  String get commentsTitle => 'Komentáře';

  @override
  String get commentsEmpty => 'Zatím žádné komentáře. Buďte první!';

  @override
  String get commentsLoadFailed =>
      'Komentáře se nepodařilo načíst — jste online?';

  @override
  String get commentsSendFailed =>
      'Akci se nepodařilo provést — zkuste to znovu.';

  @override
  String get commentsSignInHint =>
      'Pro přidání komentáře se přihlaste v záložce Profil.';

  @override
  String get commentsComposerHint => 'Napsat komentář…';

  @override
  String get commentsSendTooltip => 'Odeslat komentář';

  @override
  String get commentsDeleteTooltip => 'Smazat komentář';

  @override
  String get commentsAnonymous => 'Lezec';

  @override
  String get issueReportAction => 'Nahlásit závadu';

  @override
  String get issueReportTitle => 'Nahlášení závady';

  @override
  String get issueReportHint =>
      'Popište závadu (vyklepaný kruh, nebezpečný blok, špatný přístup…)';

  @override
  String get issueReportSignInHint =>
      'Pro nahlášení závady se přihlaste v záložce Profil.';

  @override
  String get issueReportSent => 'Děkujeme, závada byla nahlášena.';

  @override
  String get issueReportFailed =>
      'Nahlášení se nepodařilo odeslat — zkuste to znovu.';

  @override
  String get issueReportSubmit => 'Odeslat';

  @override
  String get profileIssuesTitle => 'Hlášení závad';

  @override
  String get issueStatusOpen => 'Otevřené';

  @override
  String get issueStatusResolved => 'Vyřešené';

  @override
  String get issueStatusDismissed => 'Zamítnuté';

  @override
  String get issueMarkResolved => 'Označit jako vyřešené';

  @override
  String get issueMarkDismissed => 'Zamítnout';

  @override
  String get profileDisplayNameLabel => 'Zobrazované jméno';

  @override
  String get profileDisplayNameHint => 'Jméno u komentářů';

  @override
  String get profileDisplayNameSaved => 'Jméno bylo uloženo.';

  @override
  String get commonSave => 'Uložit';

  @override
  String get authForgotPassword => 'Zapomenuté heslo?';

  @override
  String get authResetTitle => 'Obnova hesla';

  @override
  String get authResetSendCode => 'Poslat kód';

  @override
  String get authResetCodeSent => 'Poslali jsme vám e-mail s ověřovacím kódem.';

  @override
  String get authResetCodeLabel => 'Kód z e-mailu';

  @override
  String get authNewPasswordLabel => 'Nové heslo';

  @override
  String get authResetConfirm => 'Nastavit heslo';

  @override
  String get commonCancel => 'Zrušit';

  @override
  String get profileSyncNow => 'Synchronizovat';

  @override
  String profileSyncedAt(String time) {
    return 'Synchronizováno v $time';
  }

  @override
  String get profileSyncNever => 'Zatím nesynchronizováno';

  @override
  String get profileSyncFailed =>
      'Synchronizace se nepodařila — zkontrolujte připojení.';

  @override
  String get profileVersionLabel => 'Verze';

  @override
  String get profileDataTitle => 'Data katalogu';

  @override
  String get profileCatalogVersionLabel => 'Verze katalogu';

  @override
  String get profileCatalogImportedLabel => 'Importováno';

  @override
  String get profileCatalogCheckUpdates => 'Zkontrolovat aktualizace dat';

  @override
  String get profileCatalogUpToDate => 'Data skal jsou aktuální.';

  @override
  String profileCatalogUpdated(int version) {
    return 'Katalog aktualizován (verze $version).';
  }

  @override
  String get profileCatalogUpdateFailed =>
      'Aktualizaci se nepodařilo stáhnout — zkuste to později.';

  @override
  String get profileMapCacheTitle => 'Mapová cache';

  @override
  String get profileMapCacheBody =>
      'Zobrazené výřezy map se ukládají pro použití bez signálu.';

  @override
  String get profileMapCacheClear => 'Vymazat';

  @override
  String get profileMapCacheCleared => 'Mapová cache byla vymazána.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsPreferredGradeLabel => 'Preferovaná stupnice';

  @override
  String get settingsPreferredGradeOriginal => 'Původní (bez převodu)';

  @override
  String get settingsPreferredGradeHint =>
      'Přibližný převod se zobrazí vedle původní klasifikace.';

  @override
  String get profileSourcesTitle => 'Zdroje dat';

  @override
  String get profileSourcesBody =>
      'Databáze skal a cest vychází z veřejné Databáze skal ČR Českého horolezeckého svazu (horosvaz.cz). Jde o offline kopii — před lezením vždy ověřte aktuální podmínky a omezení u zdroje. Mapové podklady poskytuje OpenStreetMap, případně Mapy.com (Seznam.cz).';

  @override
  String get notFoundTitle => 'Nenalezeno';

  @override
  String get areaNotFound => 'Oblast se nepodařilo najít.';

  @override
  String get sectorNotFound => 'Sektor se nepodařilo najít.';

  @override
  String get routeNotFound => 'Cestu se nepodařilo najít.';
}
