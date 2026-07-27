import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/theme/crux_colors.dart';
import '../../../shared/widgets/restriction_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../../climbing_areas/domain/climbing_area.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../../climbing_areas/presentation/widgets/area_card.dart';
import '../../projects/presentation/user_route_state_providers.dart';

/// Landing dashboard: brand header, search entry, featured and recently
/// viewed areas, personal stats and active restrictions.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  static const _featuredCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final areas = ref.watch(areasProvider).value ?? const <ClimbingArea>[];
    final recent =
        ref.watch(recentlyViewedAreasProvider).value ?? const <ClimbingArea>[];
    final userState = ref.watch(userRouteStateProvider).value;
    // A handful of teasers, not all ~hundreds of restricted areas in the
    // full catalog; the full picture lives on the area detail screens.
    final areasWithRestrictions = areas
        .where((area) => area.hasRestrictions)
        .take(4)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            _BrandHeader(onSearchTap: () => context.go(AppRoutes.areas)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => context.go(AppRoutes.smartSearch),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.smartSearchAction),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [SectionHeader(title: l10n.discoverFeaturedTitle)],
              ),
            ),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: areas.length.clamp(0, _featuredCount),
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final area = areas[index];
                  return AreaCard(
                    area: area,
                    compact: true,
                    onTap: () => context.go(AppRoutes.area(area.id)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.areas),
                      icon: const Icon(Icons.terrain_outlined),
                      label: Text(l10n.discoverBrowseAllAreas),
                    ),
                  ),
                  if (recent.isNotEmpty)
                    SectionHeader(title: l10n.discoverRecentTitle),
                ],
              ),
            ),
            if (recent.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: recent.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final area = recent[index];
                    return AreaCard(
                      area: area,
                      compact: true,
                      onTap: () => context.go(AppRoutes.area(area.id)),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l10n.discoverMyClimbingTitle),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.flag,
                          iconColor: theme.cruxColors.project,
                          label: l10n.discoverProjects,
                          value: userState?.projectIds.length ?? 0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          iconColor: theme.cruxColors.favorite,
                          label: l10n.discoverFavorites,
                          value: userState?.favoriteIds.length ?? 0,
                        ),
                      ),
                    ],
                  ),
                  if (areasWithRestrictions.isNotEmpty) ...[
                    SectionHeader(title: l10n.discoverRestrictionsTitle),
                    for (final area in areasWithRestrictions) ...[
                      _RestrictionEntry(area: area),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                  SectionHeader(title: l10n.discoverDataSourceTitle),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.cruxColors.info,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.public,
                          size: 20,
                          color: theme.cruxColors.onInfo,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.discoverDataSourceBody,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.cruxColors.onInfo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand header with the product identity and a search field lookalike
/// that opens the areas browser.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.black, 0.35)!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadii.lg * 2),
          bottomRight: Radius.circular(AppRadii.lg * 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.change_history, color: scheme.onPrimary, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.appTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            button: true,
            label: l10n.discoverSearchHint,
            child: Material(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: onSearchTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: scheme.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.discoverSearchHint,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: AppSpacing.sm),
            Text('$value', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Restriction teaser linking to the affected area.
class _RestrictionEntry extends StatelessWidget {
  const _RestrictionEntry({required this.area});

  final ClimbingArea area;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restriction = area.topRestriction!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.area(area.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SeverityBadge(severity: restriction.severity),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      restriction.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
