# Produktová a technická roadmapa aplikace pro české lezce

## 1. Vize produktu

Cílem je vytvořit kompletní mobilní aplikaci pro české skalní lezce, která pokryje celý průběh lezeckého výjezdu:

1. výběr oblasti a cest,
2. získání informací o přístupu, parkování a omezeních,
3. navigace na místo,
4. použití průvodce offline přímo pod skalou,
5. zápis přelezů,
6. sledování projektů a statistik,
7. komunitní komentáře a aktuální informace,
8. hlášení závad správcům,
9. finanční podpora správců,
10. později také metodický a bezpečnostní obsah.

Aplikace bude vyvíjena ve Flutteru pro Android i iOS. Během počátečního vývoje se bude testovat především na Androidu, ale veškerý kód musí zůstat multiplatformní.

---

# 2. Hlavní produktové moduly

## 2.1 Databáze skal a cest

Datová hierarchie:

```text
Země
└── Region
    └── Oblast
        └── Sektor
            └── Skála nebo blok
                └── Cesta nebo boulder
```

Datový model musí umožnit také jednodušší struktury, například cestu přímo v sektoru bez samostatného objektu skály.

### Oblast

Oblast bude obsahovat například:

* název,
* alternativní název,
* region,
* GPS polohu,
* stručný a podrobný popis,
* typ horniny,
* převládající typ lezení,
* počet cest,
* obtížnostní rozsah,
* vhodnost pro začátečníky,
* sezónu,
* orientaci stěn,
* pravidla oblasti,
* omezení ochrany přírody,
* informace o magnéziu,
* informace o parkování,
* přístupovou cestu,
* správce oblasti,
* platební QR kód,
* aktuální upozornění,
* datum poslední aktualizace,
* zdroj dat.

### Sektor

Sektor bude obsahovat:

* název,
* popis,
* GPS polohu,
* přístup od parkoviště,
* orientaci,
* typ horniny,
* seznam skal nebo cest,
* omezení,
* aktuální stav,
* známé závady.

### Cesta

Cesta bude obsahovat:

* název,
* originální obtížnost,
* klasifikační systém,
* normalizovanou interní obtížnost,
* orientační převody,
* typ lezení,
* délku,
* počet délek,
* charakter cesty,
* druh jištění,
* počet jištění,
* informace o dojištění,
* autora,
* rok prvovýstupu,
* popis,
* informace o nástupu,
* sestup nebo slanění,
* doporučené vybavení,
* hodnocení,
* komentáře,
* přelezy,
* fotografie,
* závady,
* omezení,
* zdroj dat a datum importu.

---

# 3. Podporované druhy lezení

Datový model bude připraven na:

* sportovní lezení,
* tradiční lezení,
* pískovcové lezení,
* bouldering,
* vícedélkové lezení,
* drytooling,
* ledové lezení.

První obsahová verze se zaměří především na:

* sportovní skály,
* pískovec,
* tradiční lezení,
* bouldering.

---

# 4. Klasifikační systémy

Aplikace bude podporovat minimálně:

* UIAA,
* francouzskou sportovní klasifikaci,
* českou pískovcovou klasifikaci,
* Fontainebleau,
* americkou V-scale,
* Yosemite Decimal System,
* britskou klasifikaci.

Každá cesta musí mít zachovanou originální klasifikaci.

Uživatel si později zvolí preferovanou klasifikaci. Přepočty budou označené jako orientační, protože mezi systémy neexistuje vždy přesný převod.

---

# 5. Objevování oblastí

Uživatel bude moci oblasti hledat:

* v seznamu,
* na mapě,
* podle názvu,
* podle vzdálenosti,
* podle regionu,
* podle obtížnosti,
* podle typu lezení,
* podle horniny,
* podle vhodnosti pro děti,
* podle vhodnosti pro začátečníky,
* podle délky cest,
* podle orientace,
* podle dostupnosti,
* podle aktuálních omezení.

Výsledky půjde řadit například podle:

* vzdálenosti,
* popularity,
* hodnocení,
* počtu cest,
* názvu.

---

# 6. Navigace

Aplikace bude ukládat samostatné body pro:

* parkoviště,
* začátek přístupové cesty,
* oblast,
* sektor,
* konkrétní skálu.

Uživatel bude moci:

* zobrazit místo na interní mapě,
* otevřít Mapy.com,
* otevřít jinou dostupnou navigační aplikaci,
* navigovat na parkoviště,
* navigovat k nástupu nebo skále.

Později bude možné přidat:

* přístupovou trasu,
* více parkovišť,
* body, kde se nesmí parkovat,
* nebezpečná nebo uzavřená místa.

---

# 7. Offline režim

Offline-first fungování je základní požadavek.

Uživatel si bude moci stáhnout celou oblast, která bude obsahovat:

* základní informace,
* sektory,
* skály,
* cesty,
* omezení,
* parkoviště,
* GPS body,
* přístupové popisy,
* menší náhledy fotografií,
* komunitní informace platné v okamžiku stažení.

Bez připojení bude možné:

* procházet stažené oblasti,
* vyhledávat cesty,
* zobrazovat detaily,
* přidat přelez,
* přidat poznámku,
* přidat fotografii,
* vytvořit hlášení závady,
* vytvořit hlášení aktuálního stavu.

Po obnovení spojení se změny synchronizují.

---

# 8. Lezecký deník

Každý přelez bude moci obsahovat:

* cestu,
* datum,
* styl přelezu,
* lezení na prvním nebo druhém,
* počet pokusů,
* vlastní hodnocení,
* poznámku,
* fotografie,
* spolulezce,
* viditelnost,
* čas nebo délku aktivity,
* vlastní subjektivní obtížnost.

Podporované styly například:

* OS,
* Flash,
* RP,
* PP,
* AF,
* TR,
* Solo,
* Attempt.

Uživatel bude moci cestu označit jako:

* chci vylézt,
* projekt,
* přelezeno,
* oblíbená.

Deník bude obsahovat:

* chronologický seznam,
* kalendář,
* filtrování,
* statistiky,
* přelezy podle oblastí,
* přelezy podle obtížností,
* vývoj výkonnosti,
* projekty,
* fotografie.

---

# 9. Soukromí a sledování

Deník bude mít tři základní režimy:

* veřejný,
* přístupný schváleným sledujícím,
* soukromý.

Uživatel bude moci povolit nebo odmítnout žádost o sledování soukromého deníku.

Jednotlivý přelez může mít vlastní nastavení viditelnosti odlišné od výchozího nastavení profilu.

Soukromé zprávy nejsou součástí prvních etap.

---

# 10. Komunitní obsah

Uživatelé budou později moci:

* komentovat cesty,
* hodnotit cesty,
* přidávat fotografie,
* sledovat veřejné přelezy,
* sledovat lezce,
* přidávat aktuální stav oblasti,
* nahlašovat závady,
* nahlašovat nevhodný obsah.

Hodnocení cesty může být rozdělené na:

* celkovou kvalitu,
* kvalitu jištění,
* lámavost,
* krásu lezení,
* vhodnost pro začátečníky,
* shodu deklarované obtížnosti se skutečností.

---

# 11. Aktuální stav oblasti

Krátkodobé komunitní hlášení bude oddělené od dlouhodobých závad.

Typy aktuálního stavu:

* suché,
* částečně mokré,
* mokré,
* nevhodné podmínky,
* hodně lidí,
* problém s přístupem,
* problém s parkováním,
* jiné upozornění.

Hlášení bude mít omezenou platnost a po určité době automaticky expiruje.

---

# 12. Závady a komunikace se správcem

Typy závad:

* poškozené jištění,
* uvolněný kámen,
* poškozený slaňovací bod,
* problém s přístupem,
* problém s parkováním,
* poškození skály,
* neplatné informace,
* jiné nebezpečí.

Závada může obsahovat:

* oblast,
* sektor,
* cestu,
* popis,
* fotografii,
* GPS polohu,
* datum,
* autora hlášení,
* stav řešení.

Stavy:

* nové,
* čeká na ověření,
* potvrzené,
* zveřejněné,
* řeší se,
* vyřešené,
* zamítnuté.

Správce oblasti bude moci:

* zobrazit nahlášené závady,
* potvrdit závadu,
* zveřejnit ji uživatelům,
* přidat vlastní upozornění,
* označit závadu jako řešenou,
* upravovat informace o přístupu,
* upravovat parkování,
* přidat novou cestu,
* upravit existující cestu,
* přidat platební QR kód.

---

# 13. Role a oprávnění

Budoucí role:

## Návštěvník

* prohlížení veřejných dat,
* vyhledávání oblastí,
* používání navigace.

## Uživatel

* vlastní deník,
* projekty,
* komentáře,
* fotografie,
* hlášení stavu,
* hlášení závad,
* sledování ostatních.

## Editor

* úprava oblastí,
* úprava sektorů,
* úprava cest,
* schvalování navržených změn,
* práce s importovanými daty.

## Správce oblasti

* správa konkrétních oblastí,
* řešení závad,
* publikování upozornění,
* úprava přístupových informací,
* správa platebního QR kódu.

## Moderátor

* správa komentářů,
* správa fotografií,
* řešení nahlášeného obsahu,
* omezení uživatelů.

## Administrátor

* kompletní přístup,
* správa rolí,
* správa uživatelů,
* správa datových importů,
* konfigurace systému.

Role nebudou implementované v první etapě, ale architektura s nimi musí počítat.

---

# 14. Import dat z ČHS

Import bude tvořen samostatným nástrojem mimo Flutter aplikaci.

## První verze importu

Scraper získá pouze textová a strukturovaná data, například:

* regiony,
* oblasti,
* sektory,
* skály,
* názvy cest,
* obtížnosti,
* délky,
* autory,
* roky prvovýstupů,
* popisy,
* informace o přístupu,
* omezení,
* souřadnice, pokud jsou veřejně dostupné.

Nebudou se automaticky stahovat:

* fotografie,
* topo,
* uživatelské profilové údaje,
* osobní údaje,
* komentáře, dokud nebude rozhodnuto jinak.

## Požadavky na scraper

Scraper musí:

* být oddělený od mobilní aplikace,
* používat omezenou rychlost požadavků,
* podporovat opakované spuštění,
* nerozbíjet data při přerušení,
* ukládat zdrojovou URL,
* ukládat datum importu,
* detekovat změny,
* nevytvářet duplicity,
* logovat chyby,
* umožnit ruční kontrolu importu,
* exportovat data do stabilního interního formátu.

## Normalizace

Importovaná data se nesmí používat přímo v UI.

Nejprve se převedou na vlastní datový model aplikace:

```text
RawChsArea
    ↓
normalizace a validace
    ↓
ClimbingArea
```

To umožní později přidat další zdroje bez přepisování aplikace.

---

# 15. Technická architektura mobilní aplikace

Technologie:

* Flutter,
* Dart,
* Riverpod,
* GoRouter,
* Drift se SQLite,
* Dio pro budoucí API,
* Freezed,
* json_serializable,
* URL launcher pro externí navigaci,
* mapová knihovna vybraná podle licenčních a offline požadavků.

Struktura projektu bude feature-first:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── bootstrap/
├── core/
│   ├── database/
│   ├── network/
│   ├── errors/
│   ├── theme/
│   ├── localization/
│   └── utilities/
├── features/
│   ├── discover/
│   ├── climbing_areas/
│   ├── routes/
│   ├── diary/
│   ├── projects/
│   ├── community/
│   ├── reports/
│   ├── profile/
│   └── offline/
└── shared/
    ├── widgets/
    ├── models/
    └── services/
```

Každá feature bude rozdělena na:

```text
data/
domain/
presentation/
```

Aplikace bude používat repository rozhraní:

```text
ClimbingAreaRepository
ClimbingRouteRepository
DiaryRepository
ProjectRepository
ReportRepository
UserRepository
```

První implementace budou lokální. Později přibydou vzdálené a synchronizované implementace.

---

# 16. Designový směr

Aplikace má mít:

* moderní outdoorový vzhled,
* jednoznačnou lezeckou identitu,
* vysokou čitelnost na slunci,
* velké a dobře ovladatelné prvky,
* světlý i tmavý režim,
* důraz na mapy, fotografie a informace,
* konzistentní design systém,
* kvalitní prázdné, načítací a chybové stavy.

Nemá působit jako generická zelená turistická aplikace.

Design může čerpat inspiraci z:

* struktury a jednoduchosti Mapy.com,
* sportovního profilu Stravy,
* informační hloubky Mountain Project,
* vizuální práce s oblastmi v 27 Crags.

Výsledný design však musí být vlastní.

---

# 17. Etapy implementace

## Etapa 0 – Projektový základ

Cíl:

* ověřit Flutter projekt,
* nastavit architekturu,
* vytvořit design systém,
* připravit navigaci,
* připravit lokální databázi,
* vytvořit dokumentaci.

Výstup:

* spustitelná Android a iOS aplikace,
* spodní navigace,
* prázdné sekce,
* témata,
* základní testy,
* README,
* žádný backend.

---

## Etapa 1 – Vertikální průchod databází skal

Cíl:

Uživatel dokáže projít:

```text
Oblasti → oblast → sektor → skála → cesta
```

Funkce:

* realistická lokální demo data,
* seznam oblastí,
* vyhledávání,
* základní filtry,
* detail oblasti,
* detail sektoru,
* seznam cest,
* detail cesty,
* oblíbené,
* projekty,
* otevření externí navigace.

---

## Etapa 2 – Lokální deník

Funkce:

* zápis přelezu,
* výběr stylu,
* poznámka,
* hodnocení,
* fotografie,
* projekty,
* seznam přelezů,
* detail záznamu,
* základní statistiky,
* ukládání v SQLite.

---

## Etapa 3 – Scraper ČHS

Funkce:

* analýza struktury webu,
* získání oblastí,
* získání sektorů,
* získání cest,
* normalizace obtížností,
* ukládání zdroje,
* detekce duplicit,
* export do JSON nebo SQLite,
* validační report.

Po této etapě budou demo data nahrazena reálným importovaným vzorkem.

---

## Etapa 4 – Offline balíčky

Funkce:

* stažení oblasti,
* správa stažených dat,
* offline prohlížení,
* offline zápis přelezu,
* fronta změn čekajících na synchronizaci,
* informace o velikosti balíčku a poslední aktualizaci.

---

## Etapa 5 – Backend a synchronizace

Backend bude řešit:

* databázi oblastí,
* uživatele,
* deníky,
* fotografie,
* komentáře,
* hlášení,
* role,
* synchronizaci,
* audit změn.

Mobilní aplikace začne kombinovat lokální a vzdálená data.

---

## Etapa 6 – Přihlášení a profily

Funkce:

* registrace,
* přihlášení,
* Google,
* Apple,
* e-mail,
* profil,
* nastavení soukromí,
* veřejný deník,
* soukromý deník,
* žádosti o sledování.

---

## Etapa 7 – Komunita

Funkce:

* komentáře,
* hodnocení,
* fotografie,
* veřejné přelezy,
* sledování uživatelů,
* komunitní stav oblastí,
* nahlašování obsahu.

---

## Etapa 8 – Správci a závady

Funkce:

* hlášení závady,
* role správce,
* seznam závad,
* schválení,
* publikace upozornění,
* označení závady jako vyřešené,
* úprava údajů oblasti,
* platební QR kód.

---

## Etapa 9 – Editorská a administrátorská aplikace

Rozhraní pro:

* oblasti,
* sektory,
* cesty,
* importy,
* uživatele,
* role,
* komentáře,
* hlášení,
* závady,
* metodický obsah.

Může vzniknout jako:

* responzivní Flutter web,
* samostatná webová aplikace,
* kombinace mobilních správcovských funkcí a webové administrace.

---

## Etapa 10 – Pokročilé funkce

* metodika,
* uzly,
* videa,
* první pomoc,
* podmínky na skalách,
* počasí,
* slunce a orientace,
* doporučení oblastí,
* pokročilé statistiky,
* společné výjezdy,
* export deníku,
* veřejné profily,
* sdílení přelezů,
* případné předplatné nebo další monetizace.

---

# 18. Zásady vývoje

Každá etapa musí:

* být samostatně spustitelná,
* mít jasná akceptační kritéria,
* obsahovat testy důležité logiky,
* neporušovat předchozí funkce,
* aktualizovat dokumentaci,
* nepřidávat zbytečné závislosti,
* neimplementovat předčasně backendové funkce,
* zachovat Android a iOS kompatibilitu.

AI agent nesmí bez výslovného zadání:

* měnit základní architekturu,
* přidávat Firebase nebo jiný backend,
* přidávat přihlášení,
* přidávat placené služby,
* scrapovat web přímo z mobilní aplikace,
* používat data bez uložení jejich původu,
* generovat obrovské množství nevyužitého kódu.

---

# 19. První klíčový uživatelský scénář

První plně funkční scénář:

1. Uživatel otevře aplikaci.
2. Na hlavní stránce vyhledá oblast.
3. Otevře detail oblasti.
4. Zobrazí sektory.
5. Otevře sektor a konkrétní cestu.
6. Přečte si obtížnost, popis, přístup a omezení.
7. Označí cestu jako projekt.
8. Otevře navigaci na parkoviště.
9. Po lezení zapíše přelez.
10. Přidá styl, poznámku, hodnocení a fotografii.
11. Přelez se objeví v lokálním deníku.

Tento scénář musí fungovat bez účtu, bez backendu a bez internetového připojení.
