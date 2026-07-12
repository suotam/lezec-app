import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/grade_badge.dart';
import 'diary_providers.dart';
import '../domain/ascent.dart';

/// Chronological list of logged ascents, newest first.
class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ascents = ref.watch(diaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: AsyncValueView(
        value: ascents,
        onRetry: () => ref.invalidate(diaryProvider),
        data: (entries) {
          if (entries.isEmpty) {
            return EmptyStateView(
              icon: Icons.menu_book_outlined,
              title: l10n.diaryEmptyTitle,
              message: l10n.diaryEmptyBody,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            itemCount: entries.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  l10n.diaryAscentsCount(entries.length),
                  style: Theme.of(context).textTheme.titleMedium,
                );
              }
              return _AscentCard(ascent: entries[index - 1]);
            },
          );
        },
      ),
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
                await ref
                    .read(diaryProvider.notifier)
                    .deleteAscent(ascent.id);
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
