import 'package:flutter/material.dart';

import '../models/content_models.dart';
import '../theme/design_tokens.dart';
import 'progress_bar.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.completedCount,
    required this.totalCount,
    required this.progressPercent,
    required this.onTap,
  });

  final Module module;
  final int completedCount;
  final int totalCount;
  final int progressPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (module.type) {
      ModuleType.reading => Icons.menu_book_outlined,
      ModuleType.listening => Icons.headphones_outlined,
      ModuleType.grammar => Icons.spellcheck_outlined,
    };

    return Card(
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Icon(icon, size: 22, color: scheme.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    '$completedCount/$totalCount completed',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '$progressPercent%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ProgressBar(
                value: totalCount == 0 ? 0 : completedCount / totalCount,
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
