import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../shared/extensions/domain_labels.dart';
import '../../domain/ascent.dart';
import '../../domain/diary_stats.dart';

/// Horizontal bar chart of ascent counts per grade for the currently
/// filtered diary entries. Single series in the brand hue; counts sit as
/// direct labels at the bar ends, grade labels stay in text ink.
class GradeHistogramCard extends StatelessWidget {
  const GradeHistogramCard({super.key, required this.ascents});

  final List<Ascent> ascents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bars = gradeHistogram(ascents);
    if (bars.isEmpty) return const SizedBox.shrink();
    final maxCount = bars
        .map((bar) => bar.count)
        .reduce((a, b) => a > b ? a : b);
    // Spell out the grading system only when the diary mixes systems.
    final mixedSystems = bars.map((bar) => bar.grade.system).toSet().length > 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.diaryGradeChartTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            for (final bar in bars) ...[
              Semantics(
                label:
                    '${bar.grade.value} (${bar.grade.system.label(l10n)}): '
                    '${l10n.diaryAscentsCount(bar.count)}',
                excludeSemantics: true,
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        mixedSystems
                            ? '${bar.grade.value} ${bar.grade.system.label(l10n)}'
                            : bar.grade.value,
                        style: theme.textTheme.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: bar.count / maxCount,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${bar.count}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
