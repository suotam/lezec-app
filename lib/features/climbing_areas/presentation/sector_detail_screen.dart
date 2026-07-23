import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/restriction_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../../climbing_routes/domain/route_sorting.dart';
import '../../climbing_routes/presentation/widgets/route_list_tile.dart';
import '../../topo/presentation/widgets/sector_topo_section.dart';
import '../domain/climbing_sector.dart';
import 'climbing_areas_providers.dart';

class SectorDetailScreen extends ConsumerStatefulWidget {
  const SectorDetailScreen({
    super.key,
    required this.areaId,
    required this.sectorId,
  });

  final String areaId;
  final String sectorId;

  @override
  ConsumerState<SectorDetailScreen> createState() => _SectorDetailScreenState();
}

class _SectorDetailScreenState extends ConsumerState<SectorDetailScreen> {
  RouteSortOrder _sortOrder = RouteSortOrder.guidebook;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sectorValue = ref.watch(
      sectorProvider((areaId: widget.areaId, sectorId: widget.sectorId)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(sectorValue.value?.name ?? '')),
      body: AsyncValueView(
        value: sectorValue,
        onRetry: () => ref.invalidate(areasProvider),
        data: (sector) {
          if (sector == null) {
            return EmptyStateView(
              icon: Icons.grid_view_outlined,
              title: l10n.notFoundTitle,
              message: l10n.sectorNotFound,
            );
          }
          return _SectorBody(
            areaId: widget.areaId,
            sector: sector,
            sortOrder: _sortOrder,
            onSortChanged: (order) => setState(() => _sortOrder = order),
          );
        },
      ),
    );
  }
}

class _SectorBody extends StatelessWidget {
  const _SectorBody({
    required this.areaId,
    required this.sector,
    required this.sortOrder,
    required this.onSortChanged,
  });

  final String areaId;
  final ClimbingSector sector;
  final RouteSortOrder sortOrder;
  final ValueChanged<RouteSortOrder> onSortChanged;

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
        Text(sector.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.routesCount(sector.routeCount),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (sector.description case final description?) ...[
          const SizedBox(height: AppSpacing.md),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
        if (sector.accessNote case final accessNote?) ...[
          SectionHeader(title: l10n.sectorAccessTitle),
          Text(accessNote, style: theme.textTheme.bodyMedium),
        ],
        if (sector.warnings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          for (final warning in sector.warnings) ...[
            WarningBanner(text: warning),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        SectorTopoSection(areaId: areaId, sectorId: sector.id),
        const SizedBox(height: AppSpacing.lg),
        SegmentedButton<RouteSortOrder>(
          segments: [
            ButtonSegment(
              value: RouteSortOrder.guidebook,
              label: Text(l10n.sortGuidebook),
            ),
            ButtonSegment(
              value: RouteSortOrder.name,
              label: Text(l10n.sortByName),
            ),
            ButtonSegment(
              value: RouteSortOrder.grade,
              label: Text(l10n.sortByGrade),
            ),
          ],
          selected: {sortOrder},
          onSelectionChanged: (selection) => onSortChanged(selection.first),
          showSelectedIcon: false,
        ),
        for (final rock in sector.rocks) ...[
          SectionHeader(
            title: rock.name,
            trailing: Text(
              l10n.routesCount(rock.routes.length),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (rock.description case final description?) ...[
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Card(
            child: Column(
              children: [
                for (final route in sortRoutes(rock.routes, sortOrder))
                  RouteListTile(route: route),
              ],
            ),
          ),
        ],
        if (sector.routes.isNotEmpty) ...[
          SectionHeader(
            title: sector.rocks.isEmpty
                ? l10n.sectorRoutesTitle
                : l10n.sectorIndependentRoutesTitle,
            trailing: Text(
              l10n.routesCount(sector.routes.length),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (final route in sortRoutes(sector.routes, sortOrder))
                  RouteListTile(route: route),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
