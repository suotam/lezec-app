import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utilities/external_navigation.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/restriction_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/climbing_area.dart';
import '../domain/climbing_restriction.dart';
import '../domain/climbing_sector.dart';
import '../domain/geo_point.dart';
import 'climbing_areas_providers.dart';

class AreaDetailScreen extends ConsumerStatefulWidget {
  const AreaDetailScreen({super.key, required this.areaId});

  final String areaId;

  @override
  ConsumerState<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends ConsumerState<AreaDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Record the visit once the first frame is up; the history feeds the
    // "recently viewed" rail on the discover screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedAreasProvider.notifier).recordView(widget.areaId);
    });
  }

  Future<void> _navigateTo(GeoPoint point, String label) async {
    final messenger = ScaffoldMessenger.of(context);
    final failureText = context.l10n.navigationFailed;
    final opened = await ref
        .read(externalNavigationServiceProvider)
        .navigateTo(point, label: label);
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(failureText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final areaValue = ref.watch(areaByIdProvider(widget.areaId));

    return Scaffold(
      appBar: AppBar(title: Text(areaValue.value?.name ?? '')),
      body: AsyncValueView(
        value: areaValue,
        onRetry: () => ref.invalidate(areasProvider),
        data: (area) {
          if (area == null) {
            return EmptyStateView(
              icon: Icons.terrain_outlined,
              title: l10n.notFoundTitle,
              message: l10n.areaNotFound,
            );
          }
          return _AreaDetailBody(area: area, onNavigate: _navigateTo);
        },
      ),
    );
  }
}

class _AreaDetailBody extends StatelessWidget {
  const _AreaDetailBody({required this.area, required this.onNavigate});

  final ClimbingArea area;
  final Future<void> Function(GeoPoint point, String label) onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Text(area.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          area.regionName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final type in area.climbingTypes)
              Chip(label: Text(type.label(l10n))),
            Chip(label: Text(area.rockType.label(l10n))),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${l10n.sectorsCount(area.sectorCount)} · ${l10n.routesCount(area.routeCount)}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          button: true,
          label: '${l10n.navigateAction}: ${area.name}',
          child: FilledButton.icon(
            onPressed: () => onNavigate(area.location, area.name),
            icon: const Icon(Icons.navigation_outlined),
            label: Text(l10n.navigateAction),
          ),
        ),
        if (area.restrictions.isNotEmpty) ...[
          SectionHeader(title: l10n.areaDetailRestrictionsTitle),
          for (final restriction in area.restrictions) ...[
            RestrictionCard(restriction: restriction),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        SectionHeader(title: l10n.areaDetailAboutTitle),
        Text(area.description, style: theme.textTheme.bodyMedium),
        if (area.access case final access?) ...[
          SectionHeader(title: l10n.areaDetailAccessTitle),
          Text(access.description, style: theme.textTheme.bodyMedium),
          if (access.approachMinutes case final minutes?) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.directions_walk,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.areaDetailApproachTime(minutes),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
        if (area.parking.isNotEmpty) ...[
          SectionHeader(title: l10n.areaDetailParkingTitle),
          for (final parking in area.parking) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.local_parking, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(parking.name, style: theme.textTheme.titleSmall),
                          if (parking.note case final note?) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(note, style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filledTonal(
                      onPressed: () =>
                          onNavigate(parking.location, parking.name),
                      icon: const Icon(Icons.navigation_outlined),
                      tooltip: '${l10n.navigateAction}: ${parking.name}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        SectionHeader(title: l10n.areaDetailSectorsTitle),
        for (final sector in area.sectors) ...[
          _SectorCard(areaId: area.id, sector: sector),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SectorCard extends StatelessWidget {
  const _SectorCard({required this.areaId, required this.sector});

  final String areaId;
  final ClimbingSector sector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.sector(areaId, sector.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sector.name, style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.routesCount(sector.routeCount),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (sector.warnings.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const SeverityBadge(
                        severity: RestrictionSeverity.warning,
                      ),
                    ],
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
