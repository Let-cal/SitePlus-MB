import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
              'HÂN HẠNH CHÀO ĐÓN BẠN',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 23,
                letterSpacing: 1.5,
                color: colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fade(duration: 800.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms),

        const SizedBox(height: 8),

        Text(
              'Đăng nhập để khám phá tiếp',
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
