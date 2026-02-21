import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (!appState.isReady || appState.content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modules = appState.content!.modules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Daily'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _StatTile(
                        label: 'Level',
                        value: appState.progress.selectedLevel.name
                            .toUpperCase(),
                      ),
                      _StatTile(
                        label: 'Daily Goal',
                        value: '${appState.progress.dailyGoalMinutes} min',
                      ),
                      _StatTile(
                        label: 'Streak',
                        value: '${appState.progress.streak} day',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.1 : 1.35,
                ),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return _ModuleCard(module: module);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    final icon = switch (module.type) {
      ModuleType.reading => Icons.menu_book_outlined,
      ModuleType.listening => Icons.headphones_outlined,
      ModuleType.grammar => Icons.spellcheck_outlined,
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('${AppRoutes.moduleList}?module=${module.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 12),
              Text(module.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(module.description),
              const Spacer(),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
