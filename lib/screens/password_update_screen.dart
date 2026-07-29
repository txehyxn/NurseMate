import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../design_system/nursemate_components.dart';
import '../design_system/nursemate_tokens.dart';
import '../services/auth_service.dart';

class PasswordUpdateScreen extends StatefulWidget {
  const PasswordUpdateScreen({
    super.key,
    required this.authService,
    required this.onCompleted,
  });

  final AuthService authService;
  final VoidCallback onCompleted;

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.authService.updatePassword(_passwordController.text);
      await widget.authService.signOut();
      if (!mounted) return;
      widget.onCompleted();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _updateErrorMessage(error));
    } on Object {
      if (!mounted) return;
      setState(() => _error = '비밀번호를 변경하지 못했습니다. 재설정 링크를 다시 요청해 주세요.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              children: [
                const NurseMatePageHeader(
                  title: '새 비밀번호 설정',
                  subtitle: '앞으로 사용할 새 비밀번호를 입력해 주세요.',
                ),
                const SizedBox(height: NurseMateSpacing.xl),
                NurseMateCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const NurseMateSectionTitle(
                          title: '비밀번호 변경',
                          icon: Icons.enhanced_encryption_outlined,
                        ),
                        const SizedBox(height: NurseMateSpacing.xl),
                        TextFormField(
                          key: const Key('newPasswordField'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: '새 비밀번호',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: NurseMateSpacing.md),
                        TextFormField(
                          key: const Key('newPasswordConfirmField'),
                          controller: _confirmController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _updatePassword(),
                          decoration: const InputDecoration(
                            labelText: '새 비밀번호 확인',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: NurseMateSpacing.md),
                          Text(
                            _error!,
                            key: const Key('passwordUpdateError'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: NurseMateSpacing.xl),
                        NurseMatePrimaryButton(
                          key: const Key('updatePasswordButton'),
                          label: '비밀번호 변경하기',
                          icon: Icons.check_rounded,
                          onPressed: _isSubmitting ? null : _updatePassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _validatePassword(String? value) {
  if ((value ?? '').length < 8) {
    return '비밀번호는 8자 이상 입력해 주세요.';
  }
  return null;
}

String _updateErrorMessage(AuthException error) {
  final message = error.message.toLowerCase();
  if (message.contains('same password')) {
    return '기존 비밀번호와 다른 비밀번호를 입력해 주세요.';
  }
  if (message.contains('expired') || message.contains('invalid')) {
    return '재설정 링크가 만료되었습니다. 비밀번호 찾기를 다시 진행해 주세요.';
  }
  return '비밀번호를 변경하지 못했습니다. 잠시 후 다시 시도해 주세요.';
}
