import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utilities/map_tile_cache.dart';
import '../../../../shared/widgets/crux_map.dart';
import '../../../topo/presentation/topo_providers.dart';
import '../../data/area_download_service.dart';
import '../../domain/climbing_area.dart';

/// Areas the user downloaded for offline use (ids persisted locally).
class OfflineAreasNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'offline_area_ids';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> markDownloaded(String areaId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = {...await future, areaId};
    await prefs.setStringList(_key, ids.toList());
    state = AsyncData(ids);
  }
}

final offlineAreasProvider =
    AsyncNotifierProvider<OfflineAreasNotifier, Set<String>>(
      OfflineAreasNotifier.new,
    );

/// "Download for offline": prefetches the area's map tiles and sector
/// topo photos into the disk cache with a progress label.
class OfflineDownloadButton extends ConsumerStatefulWidget {
  const OfflineDownloadButton({super.key, required this.area});

  final ClimbingArea area;

  @override
  ConsumerState<OfflineDownloadButton> createState() =>
      _OfflineDownloadButtonState();
}

class _OfflineDownloadButtonState extends ConsumerState<OfflineDownloadButton> {
  double? _progress;

  Future<void> _download() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final doneText = l10n.offlineDownloadDone;
    setState(() => _progress = 0);
    try {
      final urls = [
        ...tileUrlsForArea(
          widget.area,
          ref.read(mapTileSourceProvider).urlTemplate,
        ),
        // Sector topos, when a backend exists.
        if (ref.read(sectorPhotosRepositoryProvider) case final repository?)
          for (final sector in widget.area.sectors)
            for (final photo in await repository.forSector(sector.id))
              photo.publicUrl,
      ];
      final failed = await AreaDownloadService(ref.read(mapTileCacheProvider))
          .download(
            urls: urls,
            onProgress: (done, total) {
              if (mounted) setState(() => _progress = done / total);
            },
          );
      if (failed == 0) {
        await ref
            .read(offlineAreasProvider.notifier)
            .markDownloaded(widget.area.id);
        messenger.showSnackBar(SnackBar(content: Text(doneText)));
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.offlineDownloadFailed(failed))),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.offlineDownloadFailed(1))),
      );
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final downloaded =
        ref.watch(offlineAreasProvider).value?.contains(widget.area.id) ??
        false;
    final progress = _progress;

    return OutlinedButton.icon(
      onPressed: progress != null ? null : _download,
      icon: progress != null
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress > 0 ? progress : null,
              ),
            )
          : Icon(downloaded ? Icons.offline_pin : Icons.download_outlined),
      label: Text(
        progress != null
            ? l10n.offlineDownloadProgress((progress * 100).round())
            : downloaded
            ? l10n.offlineDownloadedLabel
            : l10n.offlineDownloadAction,
      ),
    );
  }
}
