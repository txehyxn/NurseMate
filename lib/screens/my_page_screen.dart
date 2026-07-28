import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../design_system/nursemate_components.dart';
import '../design_system/nursemate_tokens.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isSignUp = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _notice;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.authService.currentUser;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _notice = null;
    });
    try {
      if (_isSignUp) {
        final signedIn = await widget.authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _displayNameController.text,
        );
        if (!mounted) return;
        if (!signedIn) {
          setState(() {
            _notice = '가입 확인 메일을 보냈습니다. 이메일 인증 후 로그인해 주세요.';
            _isSignUp = false;
          });
          return;
        }
      } else {
        await widget.authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      setState(() {
        _user = widget.authService.currentUser;
        _notice = '로그인되었습니다. 저장 데이터가 클라우드와 동기화됩니다.';
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _notice = _authMessage(error));
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _notice = error is StateError
            ? error.message
            : '요청을 처리하지 못했습니다. 네트워크 연결을 확인해 주세요.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.authService.signOut();
      if (!mounted) return;
      setState(() {
        _user = null;
        _notice = '로그아웃되었습니다. 이 기기의 오프라인 데이터는 유지됩니다.';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NurseMateColors.background,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: NurseMateColors.background,
        surfaceTintColor: NurseMateColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              children: [
                const NurseMatePageHeader(
                  title: '내 NurseMate',
                  subtitle: '로그인하면 메모와 듀티표를 안전하게 복구할 수 있어요.',
                ),
                const SizedBox(height: NurseMateSpacing.xl),
                if (_user == null) _buildAuthCard(context) else _buildAccount(),
                const SizedBox(height: NurseMateSpacing.lg),
                const NurseMateInfoCard(
                  icon: Icons.cloud_done_outlined,
                  accent: NurseMateColors.mint,
                  background: NurseMateColors.mintSoft,
                  child: Text(
                    '로그인 상태에서는 메모, 본문 이미지, 형광펜, 즐겨찾기와 '
                    '듀티표가 사용자 계정에 동기화됩니다. 로그아웃 상태에서도 '
                    '기존 오프라인 기능은 그대로 사용할 수 있습니다.',
                  ),
                ),
                if (_notice != null) ...[
                  const SizedBox(height: NurseMateSpacing.md),
                  NurseMateInfoCard(
                    key: const Key('authNotice'),
                    child: Text(_notice!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return NurseMateCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? '회원가입' : '로그인',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: NurseMateSpacing.xs),
            Text(
              _isSignUp
                  ? '계정을 만들고 데이터를 클라우드에 보관하세요.'
                  : '이전에 저장한 데이터를 다시 불러옵니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: NurseMateSpacing.xl),
            if (_isSignUp) ...[
              TextFormField(
                key: const Key('authDisplayNameField'),
                controller: _displayNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '이름 또는 닉네임',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름 또는 닉네임을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: NurseMateSpacing.md),
            ],
            TextFormField(
              key: const Key('authEmailField'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '이메일',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return '올바른 이메일 주소를 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: NurseMateSpacing.md),
            TextFormField(
              key: const Key('authPasswordField'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: _isSignUp
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              textInputAction: _isSignUp
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_isSignUp) _submit();
              },
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return '비밀번호는 8자 이상 입력해 주세요.';
                }
                return null;
              },
            ),
            if (_isSignUp) ...[
              const SizedBox(height: NurseMateSpacing.md),
              TextFormField(
                key: const Key('authPasswordConfirmField'),
                controller: _passwordConfirmController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
            ],
            if (!widget.authService.isAvailable) ...[
              const SizedBox(height: NurseMateSpacing.md),
              const Text(
                '클라우드 환경변수가 등록되지 않아 현재 로그인할 수 없습니다.',
                style: TextStyle(color: NurseMateColors.error),
              ),
            ],
            const SizedBox(height: NurseMateSpacing.xl),
            NurseMatePrimaryButton(
              label: _isSignUp ? '회원가입' : '로그인',
              icon: _isSignUp
                  ? Icons.person_add_alt_1_rounded
                  : Icons.login_rounded,
              onPressed: _isSubmitting || !widget.authService.isAvailable
                  ? null
                  : _submit,
            ),
            const SizedBox(height: NurseMateSpacing.sm),
            TextButton(
              key: const Key('toggleAuthModeButton'),
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() {
                      _isSignUp = !_isSignUp;
                      _notice = null;
                    }),
              child: Text(_isSignUp ? '이미 계정이 있나요? 로그인' : '처음이신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccount() {
    final user = _user!;
    final name = user.displayName?.trim();
    return NurseMateCard(
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: NurseMateColors.primarySoft,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 43,
              color: NurseMateColors.primary,
            ),
          ),
          const SizedBox(height: NurseMateSpacing.md),
          Text(
            name == null || name.isEmpty ? 'NurseMate 사용자' : name,
            style: const TextStyle(
              color: NurseMateColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: NurseMateSpacing.xs),
          Text(
            user.email,
            style: const TextStyle(color: NurseMateColors.textSecondary),
          ),
          const SizedBox(height: NurseMateSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('signOutButton'),
              onPressed: _isSubmitting ? null : _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('로그아웃'),
            ),
          ),
        ],
      ),
    );
  }
}

String _authMessage(AuthException error) {
  final message = error.message.toLowerCase();
  if (message.contains('invalid login credentials')) {
    return '이메일 또는 비밀번호가 올바르지 않습니다.';
  }
  if (message.contains('already registered')) {
    return '이미 가입된 이메일입니다.';
  }
  if (message.contains('email not confirmed')) {
    return '이메일 인증을 완료한 뒤 로그인해 주세요.';
  }
  if (message.contains('rate limit')) {
    return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
  }
  return '로그인 요청을 처리하지 못했습니다. 입력 내용을 확인해 주세요.';
}
