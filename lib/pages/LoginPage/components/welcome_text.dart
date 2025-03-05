import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Welcome Back',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fade(duration: 800.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue your journey',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fade(duration: 800.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms),
      ],
    );
  }
}