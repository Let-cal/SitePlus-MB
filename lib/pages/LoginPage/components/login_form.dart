import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'custom_text_field.dart';
import 'login_button.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function onLoginSuccess;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.onLoginSuccess,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _usernameController,
            labelText: 'Username or Email',
            hintText: 'Enter your username or email',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username or email';
              }
              return null;
            },
            animationDelay: 400.ms,
          ),

          const SizedBox(height: 24),

          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            animationDelay: 600.ms,
          ),

          const SizedBox(height: 24),

          LoginButton(
            isLoading: _isLoading,
            onPressed: () {
              if (widget.formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                // Simulate API call
                Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    setState(() => _isLoading = false);
                    widget.onLoginSuccess();
                  },
                );
              }
            },
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}