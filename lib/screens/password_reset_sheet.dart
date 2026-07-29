import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../design_system/nursemate_components.dart';
import '../design_system/nursemate_tokens.dart';
import '../services/auth_service.dart';

Future<void> showPasswordResetSheet({
  required BuildContext context,
  required AuthService authService,
  String initialEmail = '',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PasswordResetSheet(
      authService: authService,
      initialEmail: initialEmail,
    ),
  );
}

class PasswordResetSheet extends StatefulWidget {
  const PasswordResetSheet({
    super.key,
    required this.authService,
    this.initialEmail = '',
  });

  final AuthService authService;
  final String initialEmail;

  @override
  State<PasswordResetSheet> createState() => _PasswordResetSheetState();
}

class _PasswordResetSheetState extends State<PasswordResetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSubmitting = false;
  bool _didSend = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.authService.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() => _didSend = true);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _resetErrorMessage(error));
    } on Object {
      if (!mounted) return;
      setState(() => _error = '재설정 메일을 보내지 못했습니다. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NurseMateRadii.panel),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        NurseMateSpacing.page,
        NurseMateSpacing.sm,
        NurseMateSpacing.page,
        NurseMateSpacing.xl + bottomInset,
      ),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: NurseMateMotion.fast,
          switchInCurve: NurseMateMotion.curve,
          child: _didSend ? _buildSuccess(context) : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('passwordResetForm'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: NurseMateSpacing.lg),
          const NurseMateSectionTitle(
            title: '비밀번호 찾기',
            icon: Icons.lock_reset_rounded,
          ),
          const SizedBox(height: NurseMateSpacing.xs),
          Text(
            '가입한 이메일로 비밀번호 재설정 링크를 보내드려요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: NurseMateSpacing.xl),
          TextFormField(
            key: const Key('passwordResetEmailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _send(),
            decoration: const InputDecoration(
              labelText: '이메일',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: _validateEmail,
          ),
          if (_error != null) ...[
            const SizedBox(height: NurseMateSpacing.md),
            Text(
              _error!,
              key: const Key('passwordResetError'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: NurseMateSpacing.xl),
          NurseMatePrimaryButton(
            key: const Key('sendPasswordResetButton'),
            label: '재설정 메일 보내기',
            icon: Icons.send_rounded,
            onPressed: _isSubmitting ? null : _send,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      key: const ValueKey('passwordResetSuccess'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: NurseMateSpacing.lg),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: NurseMateColors.mintSoft,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: NurseMateColors.mint,
            size: 36,
          ),
        ),
        const SizedBox(height: NurseMateSpacing.lg),
        Text('메일을 보냈어요', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NurseMateSpacing.xs),
        Text(
          '이메일의 재설정 링크를 눌러 새 비밀번호를 입력해 주세요.\n'
          '메일이 없다면 스팸함도 확인해 주세요.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: NurseMateSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            key: const Key('closePasswordResetButton'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return '올바른 이메일 주소를 입력해 주세요.';
  }
  return null;
}

String _resetErrorMessage(AuthException error) {
  final message = error.message.toLowerCase();
  if (message.contains('rate limit')) {
    return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
  }
  return '재설정 메일을 보내지 못했습니다. 이메일 주소를 확인해 주세요.';
}
