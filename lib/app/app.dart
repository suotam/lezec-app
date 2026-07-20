import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/l10n.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/climbing_areas/presentation/climbing_areas_providers.dart';
import '../features/sync/presentation/sync_providers.dart';
import 'router/app_router.dart';

class CruxApp extends ConsumerWidget {
  const CruxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sync whenever a signed-out state turns signed-in — covers both a
    // fresh login and the restored session on app start.
    ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
      if (previous?.value == null && next.value != null) {
        ref.read(syncControllerProvider.notifier).syncNow();
      }
    });
    // Kick off the once-per-session catalog update check; failures stay
    // inside the provider (offline is normal).
    ref.listen(catalogUpdateProvider, (_, _) {});
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Czech-first product: pinned until a language setting ships with the
      // Profile stage. English strings are already populated, so switching
      // later means removing this line.
      locale: const Locale('cs'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
