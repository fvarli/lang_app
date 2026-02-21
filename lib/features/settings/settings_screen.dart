import 'package:flutter/material.dart';

import '../../core/state/app_state_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: state.progress.darkMode,
              onChanged: (_) => state.toggleTheme(),
              title: const Text('Dark mode'),
            ),
          ),
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
        ],
      ),
    );
  }
}
