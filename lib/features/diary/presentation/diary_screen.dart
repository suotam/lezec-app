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
import '../domain/trip.dart';
import 'diary_providers.dart';
import 'log_ascent_sheet.dart';
import 'log_trip_screen.dart';

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
      appBar: AppBar(
        title: Text(l10n.diaryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.hiking),
            tooltip: l10n.tripLogAction,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => const LogTripScreen(),
              ),
            ),
          ),
        ],
      ),
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
                ..._timelineWidgets(
                  entries,
                  ref.watch(tripsProvider).value ?? const [],
                ),
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

/// Interleaves trip cards with standalone ascents, newest first. Ascents
/// belonging to a trip render right under their trip card — visually
/// grouped, but still the same ordinary entries.
List<Widget> _timelineWidgets(List<Ascent> entries, List<Trip> trips) {
  final byTrip = <String, List<Ascent>>{};
  final standalone = <Ascent>[];
  for (final ascent in entries) {
    final tripId = ascent.tripId;
    if (tripId != null) {
      byTrip.putIfAbsent(tripId, () => []).add(ascent);
    } else {
      standalone.add(ascent);
    }
  }

  final items =
      <(DateTime date, DateTime createdAt, List<Widget> widgets)>[
        for (final trip in trips)
          if (byTrip[trip.id] case final tripAscents?)
            (
              trip.date,
              trip.createdAt,
              [
                _TripCard(trip: trip, ascentCount: tripAscents.length),
                const SizedBox(height: AppSpacing.sm),
                for (final ascent in tripAscents) ...[
                  _AscentCard(ascent: ascent),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
        for (final ascent in standalone)
          (
            ascent.date,
            ascent.createdAt,
            [
              _AscentCard(ascent: ascent),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
      ]..sort((a, b) {
        final byDate = b.$1.compareTo(a.$1);
        return byDate != 0 ? byDate : b.$2.compareTo(a.$2);
      });

  return [for (final item in items) ...item.$3];
}

/// Header card of one trip: area, date, note, photos and a delete menu.
class _TripCard extends ConsumerWidget {
  const _TripCard({required this.trip, required this.ascentCount});

  final Trip trip;
  final int ascentCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final photos = ref.watch(tripPhotosProvider(trip.id)).value;
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hiking, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.areaName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${formatDay(context, trip.date)}'
                        ' · ${l10n.diaryAscentsCount(ascentCount)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<void>(
                  itemBuilder: (context) => [
                    PopupMenuItem<void>(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final deletedText = l10n.tripDeleted;
                        await ref
                            .read(tripsProvider.notifier)
                            .deleteTrip(trip.id);
                        messenger.showSnackBar(
                          SnackBar(content: Text(deletedText)),
                        );
                      },
                      child: Text(l10n.tripDeleteAction),
                    ),
                  ],
                ),
              ],
            ),
            if (trip.note case final note?) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(note, style: theme.textTheme.bodyMedium),
            ],
            if (photos != null && photos.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _TripPhotoThumb(storagePath: photos[index].storagePath),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One downloaded photo thumbnail; tapping opens a zoomable viewer.
class _TripPhotoThumb extends ConsumerWidget {
  const _TripPhotoThumb({required this.storagePath});

  final String storagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bytes = ref.watch(tripPhotoBytesProvider(storagePath));
    return switch (bytes) {
      AsyncData(:final value) => GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(AppSpacing.md),
            child: InteractiveViewer(child: Image.memory(value)),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Image.memory(value, width: 72, height: 72, fit: BoxFit.cover),
        ),
      ),
      AsyncError() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      _ => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    };
  }
}
