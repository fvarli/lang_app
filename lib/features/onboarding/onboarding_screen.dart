import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/theme/design_tokens.dart';
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
              ).colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -60,
            child: _GlowCircle(
              size: 320,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  children: [
                    _BrandMoment(),
                    const Divider(height: AppSpacing.xxxl),
                    _HowItWorksCard(),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What is your English level?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
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
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How much time can you dedicate?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
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
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Begin Your Routine',
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(Icons.auto_stories_outlined, color: scheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              'LangRoutine',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Build your English skills in just minutes a day. Calm, structured, and effective.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _HowItWorksRow(
              icon: Icons.menu_book,
              label: 'Read short passages to build comprehension',
              color: scheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _HowItWorksRow(
              icon: Icons.headphones,
              label: 'Listen to audio to train your ear',
              color: scheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _HowItWorksRow(
              icon: Icons.spellcheck,
              label: 'Practice grammar with focused exercises',
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
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
