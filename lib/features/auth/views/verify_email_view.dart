import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/utils/base_state.dart';

class VerifyEmailView extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailView({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends ConsumerState<VerifyEmailView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<BaseState>(authViewModelProvider, (previous, next) {
      if (next.status == ViewState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
      } else if (next.status == ViewState.success && next.data != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-posta Doğrulandı! Giriş yapılıyor...'), backgroundColor: Colors.green));
        // State değiştiği için main.dart otomatik HomeDispatcher'a atacaktır, 
        // Ancak bu ekran stack'te kaldığı için root'a dönmek iyi olabilir:
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('E-posta Doğrulama')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.mark_email_read, size: 80, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 24),
              const Text(
                'Kodu Girin',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.email} adresine gönderilen 6 haneli doğrulama kodunu girin.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Doğrulama Kodu', prefixIcon: Icon(Icons.numbers)),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
              ),
              const SizedBox(height: 32),
              authState.status == ViewState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        ref.read(authViewModelProvider.notifier).verifyEmail(
                          widget.email,
                          _codeController.text.trim(),
                        );
                      },
                      child: const Text('Doğrula'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(authViewModelProvider.notifier).resendCode(widget.email);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni kod istendi.')));
                },
                child: const Text('Kodu tekrar gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
