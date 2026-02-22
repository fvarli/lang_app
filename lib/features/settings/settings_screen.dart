import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/state/app_state_scope.dart';
import '../../core/theme/design_tokens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'PREFERENCES',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: SwitchListTile(
              value: state.progress.darkMode,
              onChanged: (_) => state.toggleTheme(),
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark appearance.'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'DATA',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Reset progress'),
              subtitle: const Text(
                'Clear onboarding choices and completed lessons.',
              ),
              onTap: () => _showResetDialog(context, state),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ABOUT',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final versionText = snapshot.hasData
                    ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                    : 'Version unavailable';

                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('LangRoutine'),
                      subtitle: Text(
                        'Focus-first English routine\n$versionText',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('Send feedback'),
                      subtitle: const Text('feedback@langroutine.app'),
                      onTap: () => _sendFeedback(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, dynamic state) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This will clear all your completed lessons, streak, and onboarding choices. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                state.resetProgress();
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'feedback@langroutine.app',
      queryParameters: {'subject': 'LangRoutine Feedback'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open email app.')));
  }
}
