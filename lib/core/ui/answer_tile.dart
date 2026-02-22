import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum AnswerTileState { idle, selected, correct, incorrect }

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
    this.showCorrectHighlight = false,
  });

  final String label;
  final AnswerTileState state;
  final VoidCallback? onTap;
  final bool showCorrectHighlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color? borderColor;
    IconData icon;
    Color iconColor;

    if (showCorrectHighlight) {
      bgColor = isDark ? AppColors.correctBgDark : AppColors.correctBg;
      borderColor = AppColors.correctBorder;
      icon = Icons.check_circle;
      iconColor = AppColors.correctBorder;
    } else {
      switch (state) {
        case AnswerTileState.idle:
          bgColor = scheme.surfaceContainerHighest;
          borderColor = null;
          icon = Icons.radio_button_off;
          iconColor = scheme.outline;
        case AnswerTileState.selected:
          bgColor = scheme.primaryContainer;
          borderColor = null;
          icon = Icons.radio_button_checked;
          iconColor = scheme.primary;
        case AnswerTileState.correct:
          bgColor = isDark ? AppColors.correctBgDark : AppColors.correctBg;
          borderColor = AppColors.correctBorder;
          icon = Icons.check_circle;
          iconColor = AppColors.correctBorder;
        case AnswerTileState.incorrect:
          bgColor = isDark ? AppColors.incorrectBgDark : AppColors.incorrectBg;
          borderColor = AppColors.incorrectBorder;
          icon = Icons.cancel;
          iconColor = AppColors.incorrectBorder;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.mdAll,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
