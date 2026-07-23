import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/utilities/map_tile_cache.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../diary/presentation/diary_providers.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../../domain/sector_photos_repository.dart';
import '../topo_providers.dart';

/// Sector topo/overview photos: uploaded by the area's managers or
/// admins, visible to everyone (cached on disk, so they work offline
/// once seen). Hidden entirely when there is no backend, and when there
/// are no photos and the viewer cannot upload any.
class SectorTopoSection extends ConsumerWidget {
  const SectorTopoSection({
    super.key,
    required this.areaId,
    required this.sectorId,
  });

  final String areaId;
  final String sectorId;

  Future<void> _addPhotos(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(sectorPhotosRepositoryProvider);
    if (repository == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final failedText = context.l10n.topoUploadFailed;
    final photos = await ref.read(photoPickerProvider)();
    var failed = 0;
    for (final bytes in photos) {
      try {
        await repository.upload(
          areaId: areaId,
          sectorId: sectorId,
          bytes: bytes,
        );
      } catch (_) {
        failed++;
      }
    }
    ref.invalidate(sectorPhotosProvider(sectorId));
    if (failed > 0) {
      messenger.showSnackBar(SnackBar(content: Text(failedText)));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SectorPhoto photo,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.topoDeleteConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.topoDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sectorPhotosRepositoryProvider)?.remove(photo);
      ref.invalidate(sectorPhotosProvider(sectorId));
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.mounted ? l10n.topoUploadFailed : '')),
      );
    }
  }

  void _openFullscreen(BuildContext context, SectorPhoto photo) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 6,
                child: Center(child: _CachedPhoto(url: photo.publicUrl)),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (ref.watch(sectorPhotosRepositoryProvider) == null) {
      return const SizedBox.shrink();
    }
    final photos =
        ref.watch(sectorPhotosProvider(sectorId)).value ??
        const <SectorPhoto>[];
    final canManage = ref.watch(canManageAreaProvider(areaId));
    if (photos.isEmpty && !canManage) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.topoSectionTitle,
          trailing: canManage
              ? IconButton(
                  onPressed: () => _addPhotos(context, ref),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  tooltip: l10n.topoAddTooltip,
                )
              : null,
        ),
        if (photos.isEmpty)
          Text(
            l10n.topoEmptyManagerHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => _openFullscreen(context, photo),
                  onLongPress: canManage
                      ? () => _confirmDelete(context, ref, photo)
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: SizedBox(
                      width: 200,
                      child: _CachedPhoto(url: photo.publicUrl),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Renders a remote image through the disk cache (offline after first
/// view); shows a broken-image placeholder on failure.
class _CachedPhoto extends ConsumerWidget {
  const _CachedPhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(cachedImageBytesProvider(url));
    return switch (bytes) {
      AsyncData(:final value) => Image.memory(value, fit: BoxFit.cover),
      AsyncError() => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      ),
      _ => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    };
  }
}
