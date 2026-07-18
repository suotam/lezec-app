import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../climbing_routes/domain/route_context.dart';
import '../domain/ascent.dart';
import 'diary_providers.dart';

/// Bottom sheet for logging an ascent of [routeContext]'s route, or —
/// when [initial] is set — for editing an existing diary entry.
///
/// Pops with `true` after the ascent was written to the diary, so the
/// caller can show a confirmation.
class LogAscentSheet extends ConsumerStatefulWidget {
  const LogAscentSheet({super.key, this.routeContext, this.initial})
      : assert(
          (routeContext == null) != (initial == null),
          'pass either routeContext (log) or initial (edit)',
        );

  final RouteContext? routeContext;
  final Ascent? initial;

  static Future<bool?> show(BuildContext context, RouteContext routeContext) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => LogAscentSheet(routeContext: routeContext),
    );
  }

  static Future<bool?> showEdit(BuildContext context, Ascent ascent) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => LogAscentSheet(initial: ascent),
    );
  }

  @override
  ConsumerState<LogAscentSheet> createState() => _LogAscentSheetState();
}

class _LogAscentSheetState extends ConsumerState<LogAscentSheet> {
  late AscentStyle _style =
      widget.initial?.style ?? AscentStyle.redpoint;
  late DateTime _date = widget.initial?.date ?? DateTime.now();
  late final _noteController =
      TextEditingController(text: widget.initial?.note ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final notifier = ref.read(diaryProvider.notifier);
    if (widget.initial case final initial?) {
      final trimmedNote = _noteController.text.trim();
      await notifier.updateAscent(
        initial.copyWith(
          style: _style,
          date: _date,
          note: trimmedNote.isEmpty ? null : trimmedNote,
        ),
      );
    } else {
      await notifier.logAscent(
        routeContext: widget.routeContext!,
        style: _style,
        date: _date,
        note: _noteController.text,
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final editing = widget.initial != null;
    final routeName =
        widget.initial?.routeName ?? widget.routeContext!.route.name;
    final gradeValue =
        widget.initial?.grade.value ?? widget.routeContext!.route.grade.value;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editing ? l10n.editAscentTitle : l10n.logAscentTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$routeName · $gradeValue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.ascentStyleLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.ascentDateLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(formatDay(context, _date)),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.ascentNoteLabel,
                  hintText: l10n.ascentNoteHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(l10n.ascentSaveAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
