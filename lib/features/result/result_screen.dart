import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final score = int.tryParse(uri.queryParameters['score'] ?? '0') ?? 0;
    final total = int.tryParse(uri.queryParameters['total'] ?? '0') ?? 0;
    final module = uri.queryParameters['module'];
    final pct = total == 0 ? 0 : ((score / total) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lesson Complete',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$score / $total',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('$pct% accuracy'),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () {
                          if (module == null || module.isEmpty) {
                            context.go(AppRoutes.home);
                            return;
                          }
                          context.go('${AppRoutes.moduleList}?module=$module');
                        },
                        child: const Text('Back to Module'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
