import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/service/api_service.dart';

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
  final _apiService = ApiService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  Future<void> _handleLogin() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (response['success']) {
        final prefs = await SharedPreferences.getInstance();

        // Xử lý token
        if (response.containsKey('token') && response['token'] != null) {
          final token = response['token'];
          await prefs.setString('auth_token', token);
          print('Token đã được lưu: ${token.substring(0, 15)}...');
        } else {
          print('Lỗi: response không chứa token hoặc không hợp lệ');
        }

        // Xử lý hint
        if (response.containsKey('hint') && response['hint'] != null) {
          final hint = response['hint'].toString();
          await prefs.setString('hintId', hint);
          print('Hint đã được lưu: $hint');
        } else {
          print('Lỗi: response không chứa hint hoặc không hợp lệ');
        }
        await prefs.setString('username', _usernameController.text);

        // Hiển thị thông báo thành công
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Đăng nhập thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển hướng đến MainScaffold
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
        widget.onLoginSuccess();
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

          LoginButton(isLoading: _isLoading, onPressed: _handleLogin),

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
