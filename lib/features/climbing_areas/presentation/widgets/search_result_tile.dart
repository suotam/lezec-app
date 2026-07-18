import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../../domain/catalog_search.dart';

/// One sector / rock / route match in the catalog-wide search results.
/// Sector and rock tiles open the sector screen; route tiles open the
/// route detail.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.result});

  final CatalogSearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = result.sectorName == null
        ? result.areaName
        : '${result.sectorName} · ${result.areaName}';
    return ListTile(
      leading: switch (result.type) {
        CatalogSearchResultType.route when result.grade != null => GradeBadge(
          grade: result.grade!,
        ),
        CatalogSearchResultType.route => const Icon(Icons.route_outlined),
        CatalogSearchResultType.sector => const Icon(Icons.grid_view_outlined),
        CatalogSearchResultType.rock => const Icon(Icons.landscape_outlined),
      },
      title: Text(
        result.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => switch (result.type) {
        CatalogSearchResultType.route => context.push(
          AppRoutes.route(result.id),
        ),
        CatalogSearchResultType.sector || CatalogSearchResultType.rock =>
          context.go(AppRoutes.sector(result.areaId, result.sectorId)),
      },
    );
  }
}
