import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../ui/widgets/game_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _errorText;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await _authService.signIn(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      // Friendly error mapping
      final msg = _mapAuthError(e);
      setState(() => _errorText = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHeader(showBack: false, showAvatar: false),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_errorText != null) ...[
                _ErrorBanner(text: _errorText!),
                const SizedBox(height: 12),
              ],
              _InputField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: passwordController,
                label: 'Password',
                obscure: true,
                icon: Icons.lock_outline,
                validator: _validatePassword,
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35C69D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loading ? null : handleLogin,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String _mapAuthError(Object e) {
    final msg = e.toString();
    // Try to map common FirebaseAuth error codes present in message
    if (msg.contains('user-not-found')) return 'No account found with that email.';
    if (msg.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (msg.contains('invalid-email')) return 'The email address is badly formatted.';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
    return 'Unable to sign in. Please check your email and password.';
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF35C69D), width: 1.5),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
