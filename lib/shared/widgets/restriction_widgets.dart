import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/localization/l10n.dart';
import '../../core/theme/crux_colors.dart';
import '../../features/climbing_areas/domain/climbing_restriction.dart';
import '../extensions/domain_labels.dart';

typedef _SeverityColors = ({Color background, Color foreground});

_SeverityColors _colorsFor(BuildContext context, RestrictionSeverity severity) {
  final colors = Theme.of(context).cruxColors;
  return switch (severity) {
    RestrictionSeverity.info => (
      background: colors.info,
      foreground: colors.onInfo,
    ),
    RestrictionSeverity.warning => (
      background: colors.warning,
      foreground: colors.onWarning,
    ),
    RestrictionSeverity.closure => (
      background: colors.closure,
      foreground: colors.onClosure,
    ),
  };
}

IconData _iconFor(RestrictionSeverity severity) => switch (severity) {
  RestrictionSeverity.info => Icons.info_outline,
  RestrictionSeverity.warning => Icons.warning_amber_outlined,
  RestrictionSeverity.closure => Icons.block,
};

/// Compact severity badge used on area cards and list items.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity});

  final RestrictionSeverity severity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = _colorsFor(context, severity);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(severity), size: 14, color: colors.foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            severity.label(l10n),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full restriction card for detail screens.
class RestrictionCard extends StatelessWidget {
  const RestrictionCard({super.key, required this.restriction});

  final ClimbingRestriction restriction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(context, restriction.severity);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(restriction.severity),
                size: 18,
                color: colors.foreground,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  restriction.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            restriction.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.foreground,
            ),
          ),
          if (restriction.seasonalNote case final note?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              note,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline warning banner for plain warning strings on sectors and routes.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(context, RestrictionSeverity.warning);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: 18,
            color: colors.foreground,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
