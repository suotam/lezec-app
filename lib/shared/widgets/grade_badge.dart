import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../features/climbing_routes/domain/route_grade.dart';

/// Square badge showing the original grade of a route. The grade is the
/// single most scanned piece of information, so it gets strong contrast.
class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade, this.large = false});

  final RouteGrade grade;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(minWidth: large ? 72 : 48),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: large ? AppSpacing.md : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        grade.value,
        textAlign: TextAlign.center,
        style:
            (large ? theme.textTheme.headlineSmall : theme.textTheme.labelLarge)
                ?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
      ),
    );
  }
}
