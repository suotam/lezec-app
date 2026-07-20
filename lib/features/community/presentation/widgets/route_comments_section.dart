import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../shared/extensions/date_formatting.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../../domain/route_comment.dart';
import '../comments_providers.dart';

/// Community comments under a route detail. Hidden entirely when no
/// backend is configured; reading works signed out, writing signed in.
class RouteCommentsSection extends ConsumerStatefulWidget {
  const RouteCommentsSection({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<RouteCommentsSection> createState() =>
      _RouteCommentsSectionState();
}

class _RouteCommentsSectionState extends ConsumerState<RouteCommentsSection> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    final repository = ref.read(commentsRepositoryProvider);
    final authorName = ref.read(authorNameProvider);
    if (body.isEmpty || repository == null || authorName == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final failedText = context.l10n.commentsSendFailed;
    setState(() => _sending = true);
    try {
      await repository.add(
        routeId: widget.routeId,
        body: body,
        authorName: authorName,
      );
      _composer.clear();
      ref.invalidate(routeCommentsProvider(widget.routeId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failedText)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(RouteComment comment) async {
    final repository = ref.read(commentsRepositoryProvider);
    if (repository == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final failedText = context.l10n.commentsSendFailed;
    try {
      await repository.remove(comment.id);
      ref.invalidate(routeCommentsProvider(widget.routeId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failedText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (ref.watch(commentsRepositoryProvider) == null) {
      return const SizedBox.shrink();
    }
    final comments = ref.watch(routeCommentsProvider(widget.routeId));
    final user = ref.watch(currentUserProvider).value;
    final profile = ref.watch(ownProfileProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.commentsTitle,
          trailing: switch (comments.value) {
            final list? => Text(
              '${list.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            _ => null,
          },
        ),
        switch (comments) {
          AsyncData(value: final list?) when list.isEmpty => Text(
            l10n.commentsEmpty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AsyncData(value: final list?) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final comment in list)
                  _CommentTile(
                    comment: comment,
                    canDelete:
                        user != null &&
                        (comment.userId == user.id ||
                            (profile?.isAdmin ?? false)),
                    onDelete: () => _delete(comment),
                  ),
              ],
            ),
          ),
          AsyncError() => Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commentsLoadFailed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(routeCommentsProvider(widget.routeId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
          _ => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
        const SizedBox(height: AppSpacing.md),
        if (user == null)
          Text(
            l10n.commentsSignInHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _composer,
                  maxLength: 2000,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: l10n.commentsComposerHint,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                tooltip: l10n.commentsSendTooltip,
              ),
            ],
          ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  final RouteComment comment;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${comment.authorName.isEmpty ? l10n.commentsAnonymous : comment.authorName}'
                  ' · ${formatDay(context, comment.createdAt)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(comment.body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: l10n.commentsDeleteTooltip,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
