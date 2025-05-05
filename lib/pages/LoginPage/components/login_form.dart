import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/main_scaffold.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/SiteDeal/site_deal_provider.dart';
import 'package:siteplus_mb/utils/SiteVsBuilding/site_category_provider.dart';

import 'custom_text_field.dart';
import 'login_button.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const LoginForm({super.key, required this.formKey});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  final _categoriesProvider = SiteCategoriesProvider();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _fetchSiteCategories(String token) async {
    try {
      final categories = await _apiService.getSiteCategories(token);
      _categoriesProvider.setCategories(categories);
      print('Site categories loaded: ${categories.length} categories');
    } catch (e) {
      print('Error loading site categories: $e');
      // Don't block login process if this fails
    }
  }

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

        // Handle token
        if (response.containsKey('token') && response['token'] != null) {
          final token = response['token'];
          await prefs.setString('auth_token', token);
          print('Token saved: $token');
          // Fetch site categories after getting token
          await _fetchSiteCategories(token);
        } else {
          print('Error: response does not contain a valid token');
        }
        if (response.containsKey('areaId') && response['areaId'] != null) {
          final area = int.parse(response['areaId'].toString());
          await prefs.setInt('areaId', area);
          print('Area saved: $area');
        } else {
          print('Error: response does not contain a valid area');
        }
        // Handle hint
        if (response.containsKey('hint') && response['hint'] != null) {
          final hint = response['hint'].toString();
          await prefs.setString('hintId', hint);
          print('Hint saved: $hint');
          final userId = int.tryParse(hint);
          if (userId != null) {
            await Provider.of<SiteDealProvider>(
              context,
              listen: false,
            ).fetchAllSiteDeals(userId);
            print('Site deals fetched after login');
          } else {
            print('Error: Could not parse userId from hint');
          }
        }
        final district = response['district'].toString();
        final districtId = response['districtId'].toString();
        final userNameFromResponse = response['userName'].toString();
        await prefs.setString('district', district);
        await prefs.setString('districtId', districtId);
        await prefs.setString('userName', userNameFromResponse);
        await prefs.setString('username', _usernameController.text);

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful! Welcome to us'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to MainScaffold
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed! Your username or password is incorrect.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
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
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
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
