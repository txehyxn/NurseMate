import 'package:flutter/material.dart';

import '../config/app_access_config.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, required this.onUnlocked});

  final Future<void> Function() onUnlocked;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isUnlocking = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_isUnlocking) return;

    if (_passwordController.text == nurseMateAccessPassword) {
      setState(() {
        _isUnlocking = true;
        _errorMessage = null;
      });
      try {
        await widget.onUnlocked();
      } on Object {
        if (!mounted) return;
        setState(() {
          _isUnlocking = false;
          _errorMessage = '잠금 해제 상태를 저장하지 못했습니다.';
        });
      }
      return;
    }

    setState(() {
      _errorMessage = '비밀번호가 올바르지 않습니다.';
    });
    _passwordController.clear();
    _passwordFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE0E8EF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F4F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.water_drop_outlined,
                              size: 36,
                              color: Color(0xFF4E8F89),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'NurseMate',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '앱을 사용하려면 비밀번호를 입력해 주세요.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          key: const Key('passwordField'),
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          autofocus: true,
                          obscureText: _obscurePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            errorText: _errorMessage,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? '비밀번호 표시'
                                  : '비밀번호 숨기기',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                          onSubmitted: (_) => _unlock(),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          key: const Key('unlockButton'),
                          onPressed: _isUnlocking ? null : _unlock,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('앱 열기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
