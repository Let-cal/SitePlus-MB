import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              shadowColor: colorScheme.primary.withOpacity(0.3),
            ),
            child:
                isLoading
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'Sign In to Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        )
        .animate()
        .fade(duration: 800.ms, delay: 1000.ms)
        .scale(delay: 1000.ms, duration: 400.ms, begin: Offset(0.95, 0.95));
  }
}
