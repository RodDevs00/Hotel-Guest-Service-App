import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/haven_logo.dart';
import '../../providers/providers.dart';

class GuestSignInScreen extends ConsumerStatefulWidget {
  const GuestSignInScreen({super.key});

  @override
  ConsumerState<GuestSignInScreen> createState() => _GuestSignInScreenState();
}

class _GuestSignInScreenState extends ConsumerState<GuestSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _roomController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).guestSignIn(
            roomNumber: _roomController.text,
            checkInCode: _codeController.text,
          );
      if (mounted) context.go('/guest');
    } catch (e) {
      setState(
        () => _error = friendlyError(
          e,
          fallback: 'Unable to sign in. Check your room number and check-in code.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: HavenLogo()),
                    const SizedBox(height: 28),
                    Text(
                      'Guest room sign-in',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the room number and check-in code from your keycard jacket.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_outlined, color: AppColors.teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Printed beneath the magnetic stripe on your keycard sleeve.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        labelText: 'Room number',
                        helperText: '3 or 4 digits',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your room number' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Check-in code',
                        helperText: 'Case sensitive',
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your check-in code' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sign In'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/privacy'),
                      child: const Text('Review Privacy Notice'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
