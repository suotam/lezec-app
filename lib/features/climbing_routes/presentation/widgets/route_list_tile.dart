import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/crux_colors.dart';
import '../../../../shared/extensions/domain_labels.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../../../diary/presentation/diary_providers.dart';
import '../../../projects/presentation/user_route_state_providers.dart';
import '../../../profile/presentation/settings_providers.dart';
import '../../domain/climbing_route.dart';
import '../../domain/grade_conversion.dart';

/// One route in a sector/rock list. Shows the grade badge, name, meta line
/// and the user's favorite/project marks.
class RouteListTile extends ConsumerWidget {
  const RouteListTile({super.key, required this.route});

  final ClimbingRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final userState = ref.watch(userRouteStateProvider).value;
    final isFavorite = userState?.isFavorite(route.id) ?? false;
    final isProject = userState?.isProject(route.id) ?? false;
    final isClimbed = ref.watch(climbedRouteIdsProvider).contains(route.id);

    final preferred = ref.watch(preferredGradingSystemProvider).value;
    final converted = preferred == null
        ? null
        : convertGrade(route.grade, preferred);
    final meta = [
      if (converted != null) '≈ $converted',
      route.type.label(l10n),
      if (route.lengthMeters case final length?) l10n.routeLengthMeters(length),
      if (route.warnings.isNotEmpty) l10n.severityWarning,
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      minVerticalPadding: AppSpacing.sm,
      leading: GradeBadge(grade: route.grade),
      title: Text(
        route.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        meta,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isClimbed) ...[
            Icon(
              Icons.check_circle,
              size: 18,
              color: theme.colorScheme.primary,
              semanticLabel: l10n.routeClimbedLabel,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (isFavorite)
            Icon(
              Icons.favorite,
              size: 18,
              color: theme.cruxColors.favorite,
              semanticLabel: l10n.favoriteLabel,
            ),
          if (isProject) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.flag,
              size: 18,
              color: theme.cruxColors.project,
              semanticLabel: l10n.projectLabel,
            ),
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.push(AppRoutes.route(route.id)),
    );
  }
}
