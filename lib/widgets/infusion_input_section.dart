import 'package:flutter/material.dart';

class InfusionInputSection extends StatelessWidget {
  const InfusionInputSection({
    super.key,
    required this.formKey,
    required this.volumeController,
    required this.hoursController,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController volumeController;
  final TextEditingController hoursController;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('처방 정보', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('처방된 용량과 전체 주입 시간을 입력하세요.'),
          const SizedBox(height: 22),
          _FieldLabel(label: '용량', hint: '예: 100'),
          TextFormField(
            key: const Key('volumeField'),
            controller: volumeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'mL'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '용량을 입력해 주세요.';
              }
              final parsed = double.tryParse(value);
              if (parsed == null) return '올바른 숫자를 입력해 주세요.';
              if (!parsed.isFinite || parsed <= 0) {
                return '용량은 0보다 커야 합니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: '시간', hint: '예: 1.5'),
          TextFormField(
            key: const Key('hoursField'),
            controller: hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'hr'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '시간을 입력해 주세요.';
              }
              final parsed = double.tryParse(value);
              if (parsed == null) return '올바른 숫자를 입력해 주세요.';
              if (!parsed.isFinite || parsed <= 0) {
                return '시간은 0보다 커야 합니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('calculateButton'),
            onPressed: onCalculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '계산하기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Flexible(
            child: Text(
              hint,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
