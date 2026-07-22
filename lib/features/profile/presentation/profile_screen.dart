import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utilities/map_tile_cache.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../../shared/extensions/domain_labels.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../climbing_areas/data/catalog_update_service.dart';
import '../../climbing_areas/data/drift_catalog_store.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../../climbing_routes/domain/route_grade.dart';
import '../../issues/domain/issue_report.dart';
import '../../issues/presentation/issues_providers.dart';
import '../../sync/presentation/sync_providers.dart';
import 'profile_providers.dart';
import 'settings_providers.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final catalogInfoProvider = FutureProvider<CatalogInfo>(
  (ref) => ref.watch(driftCatalogStoreProvider).info(),
);

final mapCacheSizeProvider = Provider<int>(
  (ref) => ref.watch(mapTileCacheProvider).sizeInBytes(),
);

/// Local profile: app info, catalog data, map cache management and data
/// source attributions. Accounts and sync arrive with the backend stage.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final version = ref.watch(appVersionProvider).value;
    final catalogInfo = ref.watch(catalogInfoProvider).value;
    final cacheBytes = ref.watch(mapCacheSizeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                Icons.terrain,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              title: Text(l10n.appTitle, style: theme.textTheme.titleMedium),
              subtitle: Text(
                version == null
                    ? l10n.appTagline
                    : '${l10n.appTagline}\n${l10n.profileVersionLabel}: $version',
              ),
              isThreeLine: version != null,
            ),
          ),
          SectionHeader(title: l10n.profileAccountTitle),
          const _AccountCard(),
          const _IssueReportsCard(),
          SectionHeader(title: l10n.profileDataTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: l10n.profileCatalogVersionLabel,
                    value: catalogInfo?.version ?? '–',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: l10n.profileCatalogImportedLabel,
                    value: catalogInfo?.importedAt == null
                        ? '–'
                        : formatDay(context, catalogInfo!.importedAt!),
                  ),
                  if (catalogInfo != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${l10n.areasResultsCount(catalogInfo.areaCount)} · '
                      '${l10n.routesCount(catalogInfo.routeCount)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (ref.watch(catalogUpdateServiceProvider) != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    const _CatalogUpdateButton(),
                  ],
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.profileMapCacheTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(cacheBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.profileMapCacheBody,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(mapTileCacheProvider).clear();
                      ref.invalidate(mapCacheSizeProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.profileMapCacheCleared)),
                      );
                    },
                    child: Text(l10n.profileMapCacheClear),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.settingsTitle),
          const _SettingsCard(),
          SectionHeader(title: l10n.profileSourcesTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.profileSourcesBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

/// Sign-in / signed-in state with sync controls. The account exists only
/// for backup and cross-device sync; everything works without it.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: user == null ? const _SignInForm() : _SignedInPanel(user: user),
      ),
    );
  }
}

class _SignedInPanel extends ConsumerWidget {
  const _SignedInPanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final sync = ref.watch(syncControllerProvider);
    final syncLabel = switch (sync) {
      AsyncData(:final value) when value != null => l10n.profileSyncedAt(
        formatTime(context, value),
      ),
      AsyncError() => l10n.profileSyncFailed,
      _ => l10n.profileSyncNever,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                user.email,
                style: theme.textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _DisplayNameRow(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          syncLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: sync.hasError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: sync.isLoading
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).syncNow(),
              icon: sync.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(l10n.profileSyncNow),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: Text(l10n.authSignOut),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _message;
  bool _messageIsError = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final info = await action();
      if (mounted) {
        setState(() {
          _message = info;
          _messageIsError = false;
        });
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _message = context.l10n.authFailed(failure.message);
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final repository = ref.read(authRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authInfoBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(labelText: l10n.authEmailLabel),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.authPasswordLabel),
        ),
        if (_message case final message?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _messageIsError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await repository.signIn(
                        email: _email.text.trim(),
                        password: _password.text,
                      );
                      return null;
                    }),
              child: Text(l10n.authSignIn),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      final result = await repository.signUp(
                        email: _email.text.trim(),
                        password: _password.text,
                      );
                      return result.needsEmailConfirmation
                          ? context.mounted
                                ? context.l10n.authConfirmEmail
                                : null
                          : null;
                    }),
              child: Text(l10n.authSignUp),
            ),
          ],
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      _PasswordResetDialog(initialEmail: _email.text.trim()),
                ),
          child: Text(l10n.authForgotPassword),
        ),
      ],
    );
  }
}

/// Two-step in-app password recovery: send a one-time code to the email,
/// then verify it together with the new password. No deep links needed —
/// on success the user is signed in.
class _PasswordResetDialog extends ConsumerStatefulWidget {
  const _PasswordResetDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_PasswordResetDialog> createState() =>
      _PasswordResetDialogState();
}

class _PasswordResetDialogState extends ConsumerState<_PasswordResetDialog> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repository = ref.read(authRepositoryProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!_codeSent) {
        await repository.requestPasswordReset(_email.text.trim());
        if (mounted) setState(() => _codeSent = true);
      } else {
        await repository.completePasswordReset(
          email: _email.text.trim(),
          code: _code.text.trim(),
          newPassword: _newPassword.text,
        );
        if (mounted) Navigator.of(context).pop();
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = context.l10n.authFailed(failure.message));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.authResetTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _email,
            enabled: !_codeSent,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.authEmailLabel),
          ),
          if (_codeSent) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.authResetCodeSent,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.authResetCodeLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.authNewPasswordLabel),
            ),
          ],
          if (_error case final error?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(
            _codeSent ? l10n.authResetConfirm : l10n.authResetSendCode,
          ),
        ),
      ],
    );
  }
}

/// Manually re-runs the once-per-session catalog update check and
/// reports the outcome in a snackbar.
class _CatalogUpdateButton extends ConsumerWidget {
  const _CatalogUpdateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final check = ref.watch(catalogUpdateProvider);
    return OutlinedButton.icon(
      onPressed: check.isLoading
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              final upToDate = l10n.profileCatalogUpToDate;
              final failed = l10n.profileCatalogUpdateFailed;
              String updated(int version) =>
                  l10n.profileCatalogUpdated(version);
              ref.invalidate(catalogUpdateProvider);
              try {
                final result = await ref.read(catalogUpdateProvider.future);
                if (result == null) return;
                if (result.outcome == CatalogUpdateOutcome.updated) {
                  ref.invalidate(catalogInfoProvider);
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      result.outcome == CatalogUpdateOutcome.updated
                          ? updated(result.version)
                          : upToDate,
                    ),
                  ),
                );
              } catch (_) {
                messenger.showSnackBar(SnackBar(content: Text(failed)));
              }
            },
      icon: check.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_download_outlined),
      label: Text(l10n.profileCatalogCheckUpdates),
    );
  }
}

/// Display name shown with the user's comments; editable in place.
class _DisplayNameRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final displayName = ref.watch(ownProfileProvider).value?.displayName ?? '';
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _DisplayNameDialog(initialName: displayName),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.profileDisplayNameLabel}: '
                '${displayName.isEmpty ? '–' : displayName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayNameDialog extends ConsumerStatefulWidget {
  const _DisplayNameDialog({required this.initialName});

  final String initialName;

  @override
  ConsumerState<_DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends ConsumerState<_DisplayNameDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = ref.read(profileRepositoryProvider);
    if (repository == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final savedText = context.l10n.profileDisplayNameSaved;
    setState(() => _busy = true);
    await repository.setDisplayName(_name.text.trim());
    ref.invalidate(ownProfileProvider);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(savedText)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.profileDisplayNameLabel),
      content: TextField(
        controller: _name,
        maxLength: 60,
        decoration: InputDecoration(hintText: l10n.profileDisplayNameHint),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// The signed-in user's issue reports (admins and area managers see all
/// reports in their scope, courtesy of RLS).
class _IssueReportsCard extends ConsumerWidget {
  const _IssueReportsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reports = ref.watch(visibleIssueReportsProvider).value;
    if (reports == null || reports.isEmpty) return const SizedBox.shrink();
    final isAdmin = ref.watch(ownProfileProvider).value?.isAdmin ?? false;

    String statusLabel(IssueStatus status) => switch (status) {
      IssueStatus.open => l10n.issueStatusOpen,
      IssueStatus.resolved => l10n.issueStatusResolved,
      IssueStatus.dismissed => l10n.issueStatusDismissed,
    };

    Future<void> setStatus(IssueReport report, IssueStatus status) async {
      final repository = ref.read(issueReportsRepositoryProvider);
      if (repository == null) return;
      final messenger = ScaffoldMessenger.of(context);
      final failedText = l10n.issueReportFailed;
      try {
        await repository.setStatus(report.id, status);
        ref.invalidate(visibleIssueReportsProvider);
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(failedText)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.profileIssuesTitle),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final report in reports)
                ListTile(
                  title: Text(
                    report.areaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${report.description}\n'
                    '${formatDay(context, report.createdAt)}'
                    ' · ${statusLabel(report.status)}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: isAdmin && report.status == IssueStatus.open
                      ? PopupMenuButton<IssueStatus>(
                          onSelected: (status) => setStatus(report, status),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: IssueStatus.resolved,
                              child: Text(l10n.issueMarkResolved),
                            ),
                            PopupMenuItem(
                              value: IssueStatus.dismissed,
                              child: Text(l10n.issueMarkDismissed),
                            ),
                          ],
                        )
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// App settings: the preferred grade scale for approximate conversions.
class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preferred = ref.watch(preferredGradingSystemProvider).value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsPreferredGradeLabel,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButton<GradingSystem?>(
              value: preferred,
              isExpanded: true,
              onChanged: (system) => ref
                  .read(preferredGradingSystemProvider.notifier)
                  .set(system),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.settingsPreferredGradeOriginal),
                ),
                for (final system in GradingSystem.values)
                  DropdownMenuItem(
                    value: system,
                    child: Text(system.label(l10n)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.settingsPreferredGradeHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
