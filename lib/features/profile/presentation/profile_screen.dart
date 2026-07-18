import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utilities/map_tile_cache.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/widgets/section_header.dart';
import '../../climbing_areas/data/drift_catalog_store.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';

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
