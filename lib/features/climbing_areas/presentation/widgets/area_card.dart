import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../shared/extensions/domain_labels.dart';
import '../../../../shared/widgets/restriction_widgets.dart';
import '../../domain/climbing_area.dart';

/// Card representing one area in lists. [compact] renders a fixed-width
/// variant for horizontal carousels on the discover screen.
class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.area,
    required this.onTap,
    this.compact = false,
    this.distanceKm,
  });

  final ClimbingArea area;
  final VoidCallback onTap;
  final bool compact;

  /// Distance from the user, shown when the list is sorted by proximity.
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      area.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (area.topRestriction case final restriction?) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SeverityBadge(severity: restriction.severity),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                distanceKm == null
                    ? area.regionName
                    : '${area.regionName} · '
                        '${l10n.areaDistanceKm(distanceKm!.round())}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  area.summary,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final type in area.climbingTypes)
                    _TagChip(label: type.label(l10n)),
                  _TagChip(label: area.rockType.label(l10n)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DefaultTextStyle(
                style: theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(l10n.sectorsCount(area.sectorCount)),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.route_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.routesCount(area.routeCount),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!compact) return card;
    return SizedBox(width: 260, child: card);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
