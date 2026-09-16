import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../domain/usecases/discovery_usecase.dart';
import '../../../core/services/service_locator.dart';

/// Contact form — stores the message in the owner inbox (backend `/contact`).
/// Works even when no email provider is configured. Requests are rate-limited
/// server-side (5/hour per device IP) to keep the inbox spam-free.
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  String? _result;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _result = null;
    });
    final ok = await sl<DiscoveryUseCase>().submitContact(
      name: _name.text.trim(),
      email: _email.text.trim(),
      subject: _subject.text.trim().isEmpty ? null : _subject.text.trim(),
      message: _message.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _message.clear();
        _result = 'Message sent. We will reply to your email as soon as we can.';
      } else {
        _result = 'That did not go through. Please try again in a moment.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Contact us', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A real person reads these. Order questions, product '
                'questions, affiliate partnerships — all welcome.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _name,
                decoration: _input('Your name'),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please add your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: _input('Email address'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Please add your email';
                  if (!value.contains('@')) return 'That email looks off';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subject,
                decoration: _input('Subject (optional)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _message,
                decoration: _input('Message'),
                minLines: 5,
                maxLines: 10,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Please write a bit more (at least 10 characters)'
                    : null,
              ),
              const SizedBox(height: AppSpacing.l),
              if (_result != null) ...[
                Text(
                  _result!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: (_result!.startsWith('Message'))
                        ? const Color(0xFF2E7D32)
                        : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send message',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}