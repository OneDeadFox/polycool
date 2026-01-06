import 'package:flutter/material.dart';

class ReflectionCard extends StatelessWidget {
  /// Title is optional (e.g. "Communication style"). If null, it won't render.
  final String? title;

  /// Main statement shown to the user.
  final String statement;

  /// Value from 0.0 to 1.0. We will *display* up to 0.90 max (never 100%).
  final double value;

  /// Optional gentle prompt. If null/empty, it won't render.
  final String? prompt;

  /// Optional override for gradient colors (keep within your palette later).
  final List<Color>? gradient;

  const ReflectionCard({
    super.key,
    this.title,
    required this.statement,
    required this.value,
    this.prompt,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasPrompt = prompt != null && prompt!.trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
            ],
            Text(
              statement,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _NeverFullGradientBar(
              value: v,
              gradient: gradient,
            ),
            if (hasPrompt) ...[
              const SizedBox(height: 12),
              Text(
                prompt!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.35,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NeverFullGradientBar extends StatelessWidget {
  final double value;
  final List<Color>? gradient;

  const _NeverFullGradientBar({
    required this.value,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Never show a fully filled bar.
    // We cap the displayed fill at 0.90 (90%).
    final displayed = (value * 0.90).clamp(0.0, 0.90);

    final colors = gradient ??
        const [
          Color(0xFF4F46E5), // indigo-ish
          Color(0xFF60A5FA), // soft blue
        ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 12,
        child: Stack(
          children: [
            // Track
            Positioned.fill(
              child: Container(
                color: const Color(0xFFEFF6FF), // very light blue track
              ),
            ),
            // Fill
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: displayed, // 0.0 -> 0.90
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
