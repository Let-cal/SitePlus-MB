import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ).createShader(bounds),
            child: Text(
              'SitePlus',
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(
            duration: 2500.ms,
            color: Colors.white.withOpacity(0.4),
            size: 0.3,
          )
          .then()
          .shimmer(
            duration: 2500.ms,
            color: Colors.white.withOpacity(0.2),
            size: 0.2,
            delay: 1000.ms,
          )
          .then()
          .custom(
            duration: 3000.ms,
            builder: (context, value, child) => Transform.scale(
              scale: 1.0 + 0.03 * sin(value * pi * 2),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
