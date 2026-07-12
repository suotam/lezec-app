import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../domain/rock_type.dart';
import 'climbing_areas_providers.dart';
import 'widgets/area_card.dart';

/// Searchable, filterable list of all climbing areas.
class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(areaFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    ref.read(areaFilterProvider.notifier).clear();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(areaFilterProvider);
    final controller = ref.read(areaFilterProvider.notifier);
    final areas = ref.watch(filteredAreasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.areasTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: controller.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.areasSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.commonClearFilters,
                        onPressed: () {
                          controller.setQuery('');
                          _searchController.clear();
                        },
                      ),
              ),
            ),
          ),
          _FilterChipRow<ClimbingType>(
            label: l10n.filterClimbingType,
            values: ClimbingType.values,
            selected: filter.climbingTypes,
            labelOf: (type) => type.label(l10n),
            onToggle: controller.toggleClimbingType,
          ),
          _FilterChipRow<RockType>(
            label: l10n.filterRockType,
            values: RockType.values,
            selected: filter.rockTypes,
            labelOf: (type) => type.label(l10n),
            onToggle: controller.toggleRockType,
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: AsyncValueView(
              value: areas,
              onRetry: () => ref.invalidate(areasProvider),
              data: (areas) {
                if (areas.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off,
                    title: l10n.areasEmptyTitle,
                    message: l10n.areasEmptyBody,
                    action: filter.isEmpty
                        ? null
                        : OutlinedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: Text(l10n.commonClearFilters),
                          ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  itemCount: areas.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        l10n.areasResultsCount(areas.length),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      );
                    }
                    final area = areas[index - 1];
                    return AreaCard(
                      area: area,
                      onTap: () => context.go(AppRoutes.area(area.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow<T> extends StatelessWidget {
  const _FilterChipRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
  });

  final String label;
  final List<T> values;
  final Set<T> selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: values.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          final value = values[index - 1];
          return Center(
            child: FilterChip(
              label: Text(labelOf(value)),
              selected: selected.contains(value),
              onSelected: (_) => onToggle(value),
            ),
          );
        },
      ),
    );
  }
}
