import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class LessonContentCard extends StatelessWidget {
  const LessonContentCard({
    super.key,
    required this.moduleLabel,
    required this.child,
  });

  final String moduleLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                moduleLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
