import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utilities/map_tile_cache.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../climbing_areas/data/drift_catalog_store.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../../sync/presentation/sync_providers.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final catalogInfoProvider = FutureProvider<CatalogInfo>(
  (ref) => ref.watch(driftCatalogStoreProvider).info(),
);

final mapCacheSizeProvider = Provider<int>(
  (ref) => ref.watch(mapTileCacheProvider).sizeInBytes(),
);

/// Local profile: app info, catalog data, map cache management and data
/// source attributions. Accounts and sync arrive with the backend stage.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final version = ref.watch(appVersionProvider).value;
    final catalogInfo = ref.watch(catalogInfoProvider).value;
    final cacheBytes = ref.watch(mapCacheSizeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                Icons.terrain,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              title: Text(l10n.appTitle, style: theme.textTheme.titleMedium),
              subtitle: Text(
                version == null
                    ? l10n.appTagline
                    : '${l10n.appTagline}\n${l10n.profileVersionLabel}: $version',
              ),
              isThreeLine: version != null,
            ),
          ),
          SectionHeader(title: l10n.profileAccountTitle),
          const _AccountCard(),
          SectionHeader(title: l10n.profileDataTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: l10n.profileCatalogVersionLabel,
                    value: catalogInfo?.version ?? '–',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: l10n.profileCatalogImportedLabel,
                    value: catalogInfo?.importedAt == null
                        ? '–'
                        : formatDay(context, catalogInfo!.importedAt!),
                  ),
                  if (catalogInfo != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${l10n.areasResultsCount(catalogInfo.areaCount)} · '
                      '${l10n.routesCount(catalogInfo.routeCount)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.profileMapCacheTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(cacheBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.profileMapCacheBody,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(mapTileCacheProvider).clear();
                      ref.invalidate(mapCacheSizeProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.profileMapCacheCleared)),
                      );
                    },
                    child: Text(l10n.profileMapCacheClear),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.profileSourcesTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.profileSourcesBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

/// Sign-in / signed-in state with sync controls. The account exists only
/// for backup and cross-device sync; everything works without it.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: user == null ? const _SignInForm() : _SignedInPanel(user: user),
      ),
    );
  }
}

class _SignedInPanel extends ConsumerWidget {
  const _SignedInPanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final sync = ref.watch(syncControllerProvider);
    final syncLabel = switch (sync) {
      AsyncData(:final value) when value != null => l10n.profileSyncedAt(
        formatTime(context, value),
      ),
      AsyncError() => l10n.profileSyncFailed,
      _ => l10n.profileSyncNever,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                user.email,
                style: theme.textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          syncLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: sync.hasError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: sync.isLoading
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).syncNow(),
              icon: sync.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(l10n.profileSyncNow),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: Text(l10n.authSignOut),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _message;
  bool _messageIsError = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final info = await action();
      if (mounted) {
        setState(() {
          _message = info;
          _messageIsError = false;
        });
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _message = context.l10n.authFailed(failure.message);
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final repository = ref.read(authRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authInfoBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(labelText: l10n.authEmailLabel),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.authPasswordLabel),
        ),
        if (_message case final message?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _messageIsError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await repository.signIn(
                        email: _email.text.trim(),
                        password: _password.text,
                      );
                      return null;
                    }),
              child: Text(l10n.authSignIn),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      final result = await repository.signUp(
                        email: _email.text.trim(),
                        password: _password.text,
                      );
                      return result.needsEmailConfirmation
                          ? context.mounted
                                ? context.l10n.authConfirmEmail
                                : null
                          : null;
                    }),
              child: Text(l10n.authSignUp),
            ),
          ],
        ),
      ],
    );
  }
}
