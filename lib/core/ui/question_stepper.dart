import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class QuestionStepper extends StatelessWidget {
  const QuestionStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.completedSteps = const {},
  });

  final int totalSteps;
  final int currentStep;
  final Set<int> completedSteps;

  @override
  Widget build(BuildContext context) {
    if (totalSteps > 10) {
      return Text(
        '${currentStep + 1} / $totalSteps',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: AppDurations.fast,
            width: i == currentStep ? 10 : 8,
            height: i == currentStep ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completedSteps.contains(i) || i == currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
        ],
      ],
    );
  }
}
