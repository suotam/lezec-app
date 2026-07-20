import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/grade_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../../climbing_areas/domain/area_filter.dart';
import '../../climbing_areas/domain/climbing_area.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../../climbing_routes/domain/climbing_route.dart';
import '../domain/ascent.dart';
import 'diary_providers.dart';

/// Bulk trip logging: pick an area, date, style, note and photos, tick
/// the routes climbed — each becomes an ordinary diary ascent linked to
/// the trip.
class LogTripScreen extends ConsumerStatefulWidget {
  const LogTripScreen({super.key});

  @override
  ConsumerState<LogTripScreen> createState() => _LogTripScreenState();
}

class _LogTripScreenState extends ConsumerState<LogTripScreen> {
  ClimbingArea? _area;
  DateTime _date = DateTime.now();
  AscentStyle _style = AscentStyle.redpoint;
  final _note = TextEditingController();
  final _routeFilter = TextEditingController();
  final List<Uint8List> _photos = [];
  final Map<String, TripRouteSelection> _selected = {};
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    _routeFilter.dispose();
    super.dispose();
  }

  Future<void> _pickArea() async {
    final area = await showDialog<ClimbingArea>(
      context: context,
      builder: (_) => const _AreaPickerDialog(),
    );
    if (area != null && mounted) {
      setState(() {
        _area = area;
        _selected.clear();
        _routeFilter.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickPhotos() async {
    final picked = await ref.read(photoPickerProvider)();
    if (picked.isNotEmpty && mounted) {
      setState(() => _photos.addAll(picked));
    }
  }

  Future<void> _save() async {
    final area = _area;
    if (area == null || _selected.isEmpty || _saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final savedText = l10n.tripSaved(_selected.length);
    String photosFailed(int count) => l10n.tripPhotosFailed(count);
    setState(() => _saving = true);
    try {
      final failed = await ref
          .read(tripsProvider.notifier)
          .logTrip(
            area: area,
            date: _date,
            style: _style,
            note: _note.text,
            routes: _selected.values.toList(),
            photos: _photos,
          );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(failed == 0 ? savedText : photosFailed(failed))),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commentsSendFailed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final area = _area;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripLogTitle),
        actions: [
          TextButton(
            onPressed: area != null && _selected.isNotEmpty && !_saving
                ? _save
                : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.tripSaveAction),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          OutlinedButton.icon(
            onPressed: _pickArea,
            icon: const Icon(Icons.terrain_outlined),
            label: Text(area?.name ?? l10n.tripPickArea),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(formatDay(context, _date)),
                ),
              ),
            ],
          ),
          SectionHeader(title: l10n.ascentStyleLabel),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final style in AscentStyle.values)
                ChoiceChip(
                  label: Text(style.label(l10n)),
                  selected: _style == style,
                  onSelected: (_) => setState(() => _style = style),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: l10n.tripNoteLabel),
          ),
          SectionHeader(title: l10n.tripPhotosTitle),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (index, bytes) in _photos.indexed)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: Image.memory(
                        bytes,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(index)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.scrim.withValues(
                              alpha: 0.6,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              OutlinedButton(
                onPressed: _pickPhotos,
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          if (ref.watch(tripPhotosRepositoryProvider) == null &&
              _photos.isEmpty)
            Text(
              l10n.tripPhotosOffline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          SectionHeader(
            title: l10n.tripRoutesTitle,
            trailing: _selected.isEmpty
                ? null
                : Text(
                    l10n.routesCount(_selected.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
          if (area == null)
            Text(
              l10n.tripPickAreaFirst,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            TextField(
              controller: _routeFilter,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.tripRouteFilterHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RouteChecklist(
              areaId: area.id,
              query: _routeFilter.text.trim().toLowerCase(),
              selected: _selected,
              onToggle: (route, sectorName) => setState(() {
                if (_selected.containsKey(route.id)) {
                  _selected.remove(route.id);
                } else {
                  _selected[route.id] = (route: route, sectorName: sectorName);
                }
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Searchable area picker over the whole catalog.
class _AreaPickerDialog extends ConsumerStatefulWidget {
  const _AreaPickerDialog();

  @override
  ConsumerState<_AreaPickerDialog> createState() => _AreaPickerDialogState();
}

class _AreaPickerDialogState extends ConsumerState<_AreaPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final areas = ref.watch(areasProvider).value ?? const <ClimbingArea>[];
    final matches = filterAreas(areas, AreaFilter(query: _query));
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.areasSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: matches.length.clamp(0, 30),
                itemBuilder: (context, index) {
                  final area = matches[index];
                  return ListTile(
                    title: Text(
                      area.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      area.regionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).pop(area),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox list of the area's routes, grouped by sector (rocks appear
/// as `sector · rock` groups), pre-filtered by [query].
class _RouteChecklist extends ConsumerWidget {
  const _RouteChecklist({
    required this.areaId,
    required this.query,
    required this.selected,
    required this.onToggle,
  });

  final String areaId;
  final String query;
  final Map<String, TripRouteSelection> selected;
  final void Function(ClimbingRoute route, String sectorName) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final area = ref.watch(areaByIdProvider(areaId)).value;
    if (area == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    bool matches(ClimbingRoute route) =>
        query.isEmpty || route.name.toLowerCase().contains(query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final sector in area.sectors) ...[
          for (final (label, routes) in [
            for (final rock in sector.rocks)
              ('${sector.name} · ${rock.name}', rock.routes),
            (sector.name, sector.routes),
          ])
            if (routes.where(matches).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final route in routes.where(matches))
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: selected.containsKey(route.id),
                  onChanged: (_) => onToggle(route, label),
                  title: Row(
                    children: [
                      GradeBadge(grade: route.grade),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          route.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
        ],
      ],
    );
  }
}
