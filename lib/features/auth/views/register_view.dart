import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/utils/base_state.dart';

import 'verify_email_view.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentNoController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentNoController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<BaseState>(authViewModelProvider, (previous, next) {
      if (next.status == ViewState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
      } else if (next.status == ViewState.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt Başarılı! E-posta doğrulamasına geçiliyor...'), backgroundColor: Colors.green));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailView(email: _emailController.text.trim()),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.person_add_alt_1, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const Text(
                'Hesap Oluştur',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sisteme katılmak için bilgilerinizi girin',
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Okul E-posta (@ogr.inonu.edu.tr)', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _studentNoController, decoration: const InputDecoration(labelText: 'Öğrenci No', prefixIcon: Icon(Icons.badge)), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Bölüm', prefixIcon: Icon(Icons.school))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock)), obscureText: true),
              const SizedBox(height: 32),
              authState.status == ViewState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        ref.read(authViewModelProvider.notifier).register({
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'password': _passwordController.text.trim(),
                          'studentNo': _studentNoController.text.trim(),
                          'department': _departmentController.text.trim(),
                        });
                      },
                      child: const Text('Kayıt Ol'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zaten hesabın var mı? Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
