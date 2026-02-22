import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/state/app_state_scope.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: state.progress.darkMode,
              onChanged: (_) => state.toggleTheme(),
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark appearance.'),
            ),
          ),
          const SizedBox(height: 12),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Reset progress'),
              subtitle: const Text(
                'Clear onboarding choices and completed lessons.',
              ),
              onTap: () => state.resetProgress(),
            ),
          ),
          const SizedBox(height: 12),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
