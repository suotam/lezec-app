import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/theme/crux_colors.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/grade_badge.dart';
import '../../../shared/widgets/restriction_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../diary/presentation/log_ascent_sheet.dart';
import '../../community/presentation/widgets/route_comments_section.dart';
import '../../projects/presentation/user_route_state_providers.dart';
import '../domain/route_context.dart';
import 'climbing_routes_providers.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contextValue = ref.watch(routeContextProvider(routeId));

    return Scaffold(
      appBar: AppBar(title: Text(contextValue.value?.route.name ?? '')),
      body: AsyncValueView(
        value: contextValue,
        onRetry: () => ref.invalidate(routeContextProvider(routeId)),
        data: (routeContext) {
          if (routeContext == null) {
            return EmptyStateView(
              icon: Icons.route_outlined,
              title: l10n.notFoundTitle,
              message: l10n.routeNotFound,
            );
          }
          return _RouteDetailBody(routeContext: routeContext);
        },
      ),
    );
  }
}

class _RouteDetailBody extends ConsumerWidget {
  const _RouteDetailBody({required this.routeContext});

  final RouteContext routeContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final route = routeContext.route;
    final userState = ref.watch(userRouteStateProvider).value;
    final isFavorite = userState?.isFavorite(route.id) ?? false;
    final isProject = userState?.isProject(route.id) ?? false;
    final notifier = ref.read(userRouteStateProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradeBadge(grade: route.grade, large: true),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${l10n.routeGradeLabel}: ${route.grade.value} '
                    '(${route.grade.system.label(l10n)})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Chip(label: Text(route.type.label(l10n))),
            if (route.lengthMeters case final length?)
              Chip(
                avatar: const Icon(Icons.height, size: 16),
                label: Text(l10n.routeLengthMeters(length)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ToggleActionButton(
                active: isFavorite,
                activeIcon: Icons.favorite,
                inactiveIcon: Icons.favorite_border,
                activeColor: theme.cruxColors.favorite,
                label: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
                shortLabel: l10n.favoriteLabel,
                onPressed: () => notifier.toggleFavorite(route.id),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ToggleActionButton(
                active: isProject,
                activeIcon: Icons.flag,
                inactiveIcon: Icons.flag_outlined,
                activeColor: theme.cruxColors.project,
                label: isProject ? l10n.projectRemove : l10n.projectAdd,
                shortLabel: l10n.projectLabel,
                onPressed: () => notifier.toggleProject(route.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final logged = await LogAscentSheet.show(context, routeContext);
            if (logged == true && context.mounted) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.ascentLoggedMessage)),
              );
            }
          },
          icon: const Icon(Icons.edit_note),
          label: Text(l10n.logAscentAction),
        ),
        if (route.warnings.isNotEmpty) ...[
          SectionHeader(title: l10n.routeWarningsTitle),
          for (final warning in route.warnings) ...[
            WarningBanner(text: warning),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        if (route.description case final description?) ...[
          SectionHeader(title: l10n.routeDescriptionTitle),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
        if (route.protection case final protection?) ...[
          SectionHeader(title: l10n.routeProtectionTitle),
          Text(protection, style: theme.textTheme.bodyMedium),
        ],
        if (route.firstAscent case final firstAscent?) ...[
          SectionHeader(title: l10n.routeFirstAscentTitle),
          Text(firstAscent, style: theme.textTheme.bodyMedium),
        ],
        if (ref.watch(routeAscentsProvider(route.id)) case final ascents
            when ascents.isNotEmpty) ...[
          SectionHeader(title: l10n.routeMyAscentsTitle),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, ascent) in ascents.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(
                      '${ascent.style.label(l10n)} · '
                      '${formatDay(context, ascent.date)}',
                    ),
                    subtitle: ascent.note == null
                        ? null
                        : Text(
                            ascent.note!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
        SectionHeader(title: l10n.routeLocationTitle),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.terrain_outlined),
                title: Text(routeContext.area.name),
                subtitle: Text(routeContext.area.regionName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.area(routeContext.area.id)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.grid_view_outlined),
                title: Text(
                  routeContext.rock == null
                      ? routeContext.sector.name
                      : '${routeContext.sector.name} · ${routeContext.rock!.name}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(
                  AppRoutes.sector(
                    routeContext.area.id,
                    routeContext.sector.id,
                  ),
                ),
              ),
            ],
          ),
        ),
        RouteCommentsSection(routeId: route.id),
      ],
    );
  }
}

/// Favorite/project toggle rendered as a full-width tonal button whose
/// semantics announce the action ("add to favorites" / "remove …").
class _ToggleActionButton extends StatelessWidget {
  const _ToggleActionButton({
    required this.active,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.label,
    required this.shortLabel,
    required this.onPressed,
  });

  final bool active;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final String label;
  final String shortLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(
          active ? activeIcon : inactiveIcon,
          color: active ? activeColor : null,
        ),
        label: Text(shortLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
