import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../domain/route_rating.dart';
import '../ratings_providers.dart';

/// Community star rating for a route: the average with a count, plus the
/// signed-in user's own tappable stars. Hidden without a backend.
class RouteRatingSection extends ConsumerWidget {
  const RouteRatingSection({super.key, required this.routeId});

  final String routeId;

  Future<void> _setStars(BuildContext context, WidgetRef ref, int stars) async {
    final repository = ref.read(routeRatingsRepositoryProvider);
    if (repository == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    if (ref.read(currentUserProvider).value == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.ratingSignInHint)));
      return;
    }
    final current = ref.read(routeRatingProvider(routeId)).value?.myStars;
    try {
      if (current == stars) {
        await repository.clearMyRating(routeId);
      } else {
        await repository.setMyRating(routeId, stars);
      }
      ref.invalidate(routeRatingProvider(routeId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.ratingSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (ref.watch(routeRatingsRepositoryProvider) == null) {
      return const SizedBox.shrink();
    }
    final summary =
        ref.watch(routeRatingProvider(routeId)).value ??
        RouteRatingSummary.empty;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Stars(value: summary.average),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      summary.hasRatings
                          ? summary.average.toStringAsFixed(1)
                          : l10n.ratingNone,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.hasRatings
                      ? l10n.ratingCount(summary.count)
                      : l10n.ratingCommunityLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.ratingYourLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                _MyStars(
                  myStars: summary.myStars,
                  onTap: (stars) => _setStars(context, ref, stars),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only average, supporting half stars.
class _Stars extends StatelessWidget {
  const _Stars({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star
                : (value >= i - 0.5 ? Icons.star_half : Icons.star_border),
            size: 20,
            color: color,
          ),
      ],
    );
  }
}

/// The user's own tappable 1–5 stars.
class _MyStars extends StatelessWidget {
  const _MyStars({required this.myStars, required this.onTap});

  final int? myStars;
  final void Function(int stars) onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(
              (myStars ?? 0) >= i ? Icons.star : Icons.star_border,
              color: color,
            ),
            onPressed: () => onTap(i),
          ),
      ],
    );
  }
}
