import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/ui/app_chip.dart';
import '../../core/ui/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Level? _selectedLevel;
  int? _dailyGoal;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    if (!state.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -60,
            child: _GlowCircle(
              size: 280,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -60,
            child: _GlowCircle(
              size: 320,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _BrandMoment(),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final level in Level.values)
                                  AppChip(
                                    label: level.name.toUpperCase(),
                                    selected: _selectedLevel == level,
                                    onSelected: (_) {
                                      setState(() => _selectedLevel = level);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily goal',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final goal in const [5, 10, 15])
                                  AppChip(
                                    label: '$goal min/day',
                                    selected: _dailyGoal == goal,
                                    onSelected: (_) {
                                      setState(() => _dailyGoal = goal);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Start LangRoutine',
                      icon: Icons.arrow_forward_rounded,
                      onPressed:
                          _selectedLevel == null ||
                              _dailyGoal == null ||
                              !const {5, 10, 15}.contains(_dailyGoal)
                          ? null
                          : () async {
                              final level = _selectedLevel;
                              final dailyGoal = _dailyGoal;
                              if (level == null || dailyGoal == null) {
                                return;
                              }
                              await state.saveOnboarding(
                                level: level,
                                dailyGoalMinutes: dailyGoal,
                              );
                              if (!context.mounted) {
                                return;
                              }
                              context.go(AppRoutes.home);
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMoment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'LangRoutine',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'A calm daily routine for reading, listening, and grammar.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
