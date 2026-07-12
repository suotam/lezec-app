import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n.dart';
import '../../features/climbing_areas/presentation/area_detail_screen.dart';
import '../../features/climbing_areas/presentation/areas_screen.dart';
import '../../features/climbing_areas/presentation/sector_detail_screen.dart';
import '../../features/climbing_routes/presentation/route_detail_screen.dart';
import '../../features/diary/presentation/diary_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import 'app_shell.dart';

/// Route paths used across the app. Keep in one place so `context.go`
/// call sites never hand-assemble strings.
abstract final class AppRoutes {
  static const discover = '/';
  static const areas = '/areas';

  static String area(String areaId) => '/areas/$areaId';

  static String sector(String areaId, String sectorId) =>
      '/areas/$areaId/sectors/$sectorId';

  static String route(String routeId) => '/routes/$routeId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.discover,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/areas',
                builder: (context, state) => const AreasScreen(),
                routes: [
                  GoRoute(
                    path: ':areaId',
                    builder: (context, state) => AreaDetailScreen(
                      areaId: state.pathParameters['areaId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'sectors/:sectorId',
                        builder: (context, state) => SectorDetailScreen(
                          areaId: state.pathParameters['areaId']!,
                          sectorId: state.pathParameters['sectorId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/routes/:routeId',
                builder: (context, state) => RouteDetailScreen(
                  routeId: state.pathParameters['routeId']!,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                builder: (context, state) => const DiaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => ComingSoonScreen(
                  title: context.l10n.navCommunity,
                  description: context.l10n.communityDescription,
                  icon: Icons.forum_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => ComingSoonScreen(
                  title: context.l10n.navProfile,
                  description: context.l10n.profileDescription,
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
