import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/l10n.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../issues_providers.dart';

/// "Report an issue" entry point on the area detail. Hidden without a
/// backend; signed-out users get a hint to sign in first.
class ReportIssueButton extends ConsumerWidget {
  const ReportIssueButton({
    super.key,
    required this.areaId,
    required this.areaName,
  });

  final String areaId;
  final String areaName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (ref.watch(issueReportsRepositoryProvider) == null) {
      return const SizedBox.shrink();
    }
    // Watched (not read) so the stream is live before the first tap.
    final user = ref.watch(currentUserProvider).value;
    return OutlinedButton.icon(
      icon: const Icon(Icons.report_problem_outlined),
      label: Text(l10n.issueReportAction),
      onPressed: () {
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.issueReportSignInHint)));
          return;
        }
        showDialog<void>(
          context: context,
          builder: (_) =>
              _ReportIssueDialog(areaId: areaId, areaName: areaName),
        );
      },
    );
  }
}

class _ReportIssueDialog extends ConsumerStatefulWidget {
  const _ReportIssueDialog({required this.areaId, required this.areaName});

  final String areaId;
  final String areaName;

  @override
  ConsumerState<_ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends ConsumerState<_ReportIssueDialog> {
  final _description = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final description = _description.text.trim();
    final repository = ref.read(issueReportsRepositoryProvider);
    if (description.isEmpty || repository == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final sentText = context.l10n.issueReportSent;
    final failedText = context.l10n.issueReportFailed;
    setState(() => _busy = true);
    try {
      await repository.fileReport(
        areaId: widget.areaId,
        areaName: widget.areaName,
        description: description,
      );
      ref.invalidate(visibleIssueReportsProvider);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(sentText)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failedText)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.issueReportTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.areaName, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _description,
            maxLength: 2000,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(hintText: l10n.issueReportHint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(l10n.issueReportSubmit),
        ),
      ],
    );
  }
}
