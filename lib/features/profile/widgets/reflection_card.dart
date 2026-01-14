import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ReflectionCard extends StatelessWidget {
  final String categoryLabel;
  final String statement;
  final double value; // 0.0 – 1.0
  final String? gentlePrompt;

  const ReflectionCard({
    super.key,
    required this.categoryLabel,
    required this.statement,
    required this.value,
    this.gentlePrompt,
  });

  /// Safe placeholder for v1 before reflection data is wired
  const ReflectionCard.placeholder({
    super.key,
    required this.categoryLabel,
  })  : statement = 'Community insights will appear here over time.',
        value = 0.15,
        gentlePrompt = null;

  @override
  Widget build(BuildContext context) {
    // Cap visual fill at 90% max (never show 100%)
    final visualValue = value.clamp(0.0, 0.9);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Text(
              statement,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            _ReflectionBar(value: visualValue),

            if (gentlePrompt != null) ...[
              const SizedBox(height: 12),
              Text(
                gentlePrompt!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReflectionBar extends StatelessWidget {
  final double value;

  const _ReflectionBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        color: AppColors.surfaceMuted,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.reflectionGradient,
            ),
          ),
        ),
      ),
    );
  }
}
