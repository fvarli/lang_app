import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Level _selectedLevel = Level.a1;
  int _dailyGoal = 10;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    if (!state.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Build your English routine',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your level and daily commitment. You can change both later.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final level in Level.values)
                            ChoiceChip(
                              label: Text(level.name.toUpperCase()),
                              selected: _selectedLevel == level,
                              onSelected: (_) {
                                setState(() => _selectedLevel = level);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final goal in const [5, 10, 15])
                            ChoiceChip(
                              label: Text('$goal min / day'),
                              selected: _dailyGoal == goal,
                              onSelected: (_) {
                                setState(() => _dailyGoal = goal);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      await state.saveOnboarding(
                        level: _selectedLevel,
                        dailyGoalMinutes: _dailyGoal,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      context.go(AppRoutes.home);
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Start Learning'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
