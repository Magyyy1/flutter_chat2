import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/app_input.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final auth = context.read<AuthController>();

    final error = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );

      return;
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppInput(
              controller: _nameController,
              hint: 'Имя',
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: _emailController,
              hint: 'Email',
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: _passwordController,
              hint: 'Пароль',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Создать аккаунт',
              isLoading: auth.isLoading,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}