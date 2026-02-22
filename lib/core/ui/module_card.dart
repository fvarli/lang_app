import 'package:flutter/material.dart';

import '../models/content_models.dart';
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
    final icon = switch (module.type) {
      ModuleType.reading => Icons.menu_book_outlined,
      ModuleType.listening => Icons.headphones_outlined,
      ModuleType.grammar => Icons.spellcheck_outlined,
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
              ProgressBar(
                value: totalCount == 0 ? 0 : completedCount / totalCount,
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
