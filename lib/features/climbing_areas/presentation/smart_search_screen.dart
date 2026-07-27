import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/section_header.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../../climbing_routes/domain/grade_conversion.dart';
import '../domain/smart_search.dart';
import 'smart_search_providers.dart';
import 'widgets/area_card.dart';

/// Guided "find a suitable area" search: discipline, grade range and a
/// distance origin, filtering the whole catalog live.
class SmartSearchScreen extends ConsumerWidget {
  const SmartSearchScreen({super.key});

  List<String> _bandLabels(SmartDiscipline discipline) =>
      discipline == SmartDiscipline.routes
      ? routeGradeBandLabels
      : boulderGradeBandLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(smartSearchQueryProvider);
    final results = ref.watch(smartSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.smartSearchTitle)),
      body: AsyncValueView(
        value: results,
        data: (results) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            Text(
              l10n.smartSearchIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _DisciplinePicker(),
            if (query.discipline == SmartDiscipline.routes) ...[
              const SizedBox(height: AppSpacing.md),
              const _RouteTypeChips(),
            ],
            const SizedBox(height: AppSpacing.lg),
            _GradeRange(labels: _bandLabels(query.discipline), query: query),
            const SizedBox(height: AppSpacing.lg),
            const _OriginPicker(),
            if (query.origin != null) ...[
              const SizedBox(height: AppSpacing.md),
              _RadiusSlider(radiusKm: query.radiusKm),
            ],
            SectionHeader(
              title: l10n.smartResultsTitle,
              trailing: Text(
                l10n.areasResultsCount(results.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyStateView(
                  icon: Icons.search_off,
                  title: l10n.smartEmptyTitle,
                  message: l10n.smartEmptyBody,
                ),
              )
            else
              for (final result in results) ...[
                AreaCard(
                  area: result.area,
                  distanceKm: result.distanceKm,
                  onTap: () => context.go(AppRoutes.area(result.area.id)),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        ),
      ),
    );
  }
}

class _DisciplinePicker extends ConsumerWidget {
  const _DisciplinePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final discipline = ref.watch(
      smartSearchQueryProvider.select((q) => q.discipline),
    );
    return SegmentedButton<SmartDiscipline>(
      segments: [
        ButtonSegment(
          value: SmartDiscipline.routes,
          label: Text(l10n.smartDisciplineRoutes),
          icon: const Icon(Icons.route_outlined),
        ),
        ButtonSegment(
          value: SmartDiscipline.boulders,
          label: Text(l10n.smartDisciplineBoulders),
          icon: const Icon(Icons.landscape_outlined),
        ),
      ],
      selected: {discipline},
      onSelectionChanged: (selection) => ref
          .read(smartSearchQueryProvider.notifier)
          .setDiscipline(selection.first),
    );
  }
}

class _RouteTypeChips extends ConsumerWidget {
  const _RouteTypeChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(
      smartSearchQueryProvider.select((q) => q.routeTypes),
    );
    final controller = ref.read(smartSearchQueryProvider.notifier);
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final type in const [ClimbingType.sport, ClimbingType.trad])
          FilterChip(
            label: Text(type.label(l10n)),
            selected: selected.contains(type),
            onSelected: (_) => controller.toggleRouteType(type),
          ),
      ],
    );
  }
}

class _GradeRange extends ConsumerWidget {
  const _GradeRange({required this.labels, required this.query});

  final List<String> labels;
  final SmartSearchQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final maxIndex = labels.length - 1;
    final start = (query.minBand ?? 0).clamp(0, maxIndex);
    final end = (query.maxBand ?? maxIndex).clamp(0, maxIndex);
    final valueLabel = query.hasGradeFilter
        ? l10n.smartGradeRange(labels[start], labels[end])
        : l10n.smartGradeAny;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.smartGradeLabel, style: theme.textTheme.titleSmall),
            Text(
              valueLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        RangeSlider(
          min: 0,
          max: maxIndex.toDouble(),
          divisions: maxIndex,
          values: RangeValues(start.toDouble(), end.toDouble()),
          labels: RangeLabels(labels[start], labels[end]),
          onChanged: (values) {
            final min = values.start.round();
            final max = values.end.round();
            final full = min == 0 && max == maxIndex;
            ref
                .read(smartSearchQueryProvider.notifier)
                .setBands(full ? null : min, full ? null : max);
          },
        ),
      ],
    );
  }
}

class _OriginPicker extends ConsumerWidget {
  const _OriginPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final origin = ref.watch(smartSearchQueryProvider.select((q) => q.origin));
    final controller = ref.read(smartSearchQueryProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.smartOriginLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        if (origin != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Chip(
              avatar: const Icon(Icons.place, size: 18),
              label: Text(origin.label),
              onDeleted: controller.clearOrigin,
            ),
          ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(l10n.smartOriginMyLocation),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final unavailable = l10n.locationUnavailable;
                final label = l10n.smartOriginMyLocation;
                final ok = await controller.useMyLocation(label);
                if (!ok) {
                  messenger.showSnackBar(SnackBar(content: Text(unavailable)));
                }
              },
            ),
            DropdownMenu<SmartOrigin>(
              hintText: l10n.smartOriginPickTown,
              initialSelection:
                  origin != null && smartSearchTownPresets.contains(origin)
                  ? origin
                  : null,
              onSelected: (town) {
                if (town != null) controller.setTownOrigin(town);
              },
              dropdownMenuEntries: [
                for (final town in smartSearchTownPresets)
                  DropdownMenuEntry(value: town, label: town.label),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _RadiusSlider extends ConsumerWidget {
  const _RadiusSlider({required this.radiusKm});

  final double radiusKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.smartRadiusLabel, style: theme.textTheme.titleSmall),
            Text(
              l10n.smartRadiusValue(radiusKm.round()),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          min: 10,
          max: 200,
          divisions: 19,
          value: radiusKm.clamp(10, 200),
          label: l10n.smartRadiusValue(radiusKm.round()),
          onChanged: (value) =>
              ref.read(smartSearchQueryProvider.notifier).setRadiusKm(value),
        ),
      ],
    );
  }
}
