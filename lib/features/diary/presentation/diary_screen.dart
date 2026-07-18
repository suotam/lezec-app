import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import 'widgets/grade_histogram_card.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/grade_badge.dart';
import '../domain/ascent.dart';
import '../domain/diary_stats.dart';
import 'diary_providers.dart';
import 'log_ascent_sheet.dart';

/// Chronological list of logged ascents with basic statistics and a
/// style filter.
class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filtered = ref.watch(filteredAscentsProvider);
    final stats = ref.watch(diaryStatsProvider);
    final filter = ref.watch(diaryFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: AsyncValueView(
        value: filtered,
        onRetry: () => ref.invalidate(diaryProvider),
        data: (entries) {
          if (stats == null || stats.totalAscents == 0) {
            return EmptyStateView(
              icon: Icons.menu_book_outlined,
              title: l10n.diaryEmptyTitle,
              message: l10n.diaryEmptyBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              _StatsCard(stats: stats),
              const SizedBox(height: AppSpacing.md),
              _StyleFilterChips(stats: stats, filter: filter),
              const SizedBox(height: AppSpacing.sm),
              _YearAndAreaFilters(filter: filter),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty)
                EmptyStateView(
                  icon: Icons.filter_alt_off_outlined,
                  title: l10n.diaryFilterEmptyTitle,
                  message: l10n.diaryFilterEmptyBody,
                  action: OutlinedButton(
                    onPressed: () =>
                        ref.read(diaryFilterProvider.notifier).clear(),
                    child: Text(l10n.commonClearFilters),
                  ),
                )
              else ...[
                GradeHistogramCard(ascents: entries),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.diaryAscentsCount(entries.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final ascent in entries) ...[
                  _AscentCard(ascent: ascent),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final DiaryStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            _StatItem(
              value: stats.totalAscents,
              label: l10n.diaryStatsTotalLabel,
            ),
            _StatItem(
              value: stats.ascentsThisYear,
              label: l10n.diaryStatsThisYearLabel,
            ),
            _StatItem(
              value: stats.uniqueRoutes,
              label: l10n.diaryStatsRoutesLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Year chips (climb years present in the diary) and an area dropdown.
class _YearAndAreaFilters extends ConsumerWidget {
  const _YearAndAreaFilters({required this.filter});

  final DiaryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ascents = ref.watch(diaryProvider).value ?? const <Ascent>[];
    final years = diaryYears(ascents);
    final areas = diaryAreas(ascents);
    final controller = ref.read(diaryFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (years.length > 1)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final year in years)
                FilterChip(
                  label: Text('$year'),
                  selected: filter.years.contains(year),
                  onSelected: (_) => controller.toggleYear(year),
                ),
            ],
          ),
        if (areas.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          DropdownMenu<String?>(
            initialSelection: filter.areaId,
            requestFocusOnTap: false,
            leadingIcon: const Icon(Icons.terrain_outlined),
            textStyle: Theme.of(context).textTheme.bodyMedium,
            onSelected: controller.setArea,
            dropdownMenuEntries: [
              DropdownMenuEntry<String?>(
                value: null,
                label: l10n.diaryAllAreas,
              ),
              for (final area in areas)
                DropdownMenuEntry<String?>(
                  value: area.areaId,
                  label: '${area.areaName} (${area.count})',
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// One chip per style that occurs in the diary (with its count); tapping
/// filters the list, multiple styles combine.
class _StyleFilterChips extends ConsumerWidget {
  const _StyleFilterChips({required this.stats, required this.filter});

  final DiaryStats stats;
  final DiaryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final entry in stats.byStyle.entries)
          FilterChip(
            label: Text('${entry.key.label(l10n)} · ${entry.value}'),
            selected: filter.styles.contains(entry.key),
            onSelected: (_) =>
                ref.read(diaryFilterProvider.notifier).toggleStyle(entry.key),
          ),
      ],
    );
  }
}

class _AscentCard extends ConsumerWidget {
  const _AscentCard({required this.ascent});

  final Ascent ascent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final note = ascent.note;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: GradeBadge(grade: ascent.grade),
        title: Text(ascent.routeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ascent.style.label(l10n)} · ${formatDay(context, ascent.date)}',
            ),
            Text(
              '${ascent.areaName} · ${ascent.sectorName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (note != null)
              Text(
                note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<void>(
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final message = l10n.ascentUpdatedMessage;
                final updated = await LogAscentSheet.showEdit(context, ascent);
                if (updated == true) {
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                }
              },
              child: Text(l10n.ascentEditAction),
            ),
            PopupMenuItem<void>(
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(diaryProvider.notifier).deleteAscent(ascent.id);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.ascentDeletedMessage)),
                );
              },
              child: Text(l10n.ascentDeleteAction),
            ),
          ],
        ),
        onTap: () => context.go(AppRoutes.route(ascent.routeId)),
      ),
    );
  }
}
