import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfusionInputSection extends StatelessWidget {
  const InfusionInputSection({
    super.key,
    required this.formKey,
    required this.volumeController,
    required this.hoursController,
    required this.minutesController,
    required this.dropFactor,
    required this.onDropFactorChanged,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController volumeController;
  final TextEditingController hoursController;
  final TextEditingController minutesController;
  final int dropFactor;
  final ValueChanged<int> onDropFactorChanged;
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
          const Text('처방된 수액량과 전체 주입 시간을 입력하세요.'),
          const SizedBox(height: 22),
          _FieldLabel(label: '총 수액량', hint: '예: 100'),
          TextFormField(
            key: const Key('volumeField'),
            controller: volumeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(suffixText: 'mL'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '수액량을 입력해 주세요.';
              }
              final parsed = double.tryParse(value);
              if (parsed == null) return '올바른 숫자를 입력해 주세요.';
              if (!parsed.isFinite || parsed <= 0) {
                return '수액량은 0보다 커야 합니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: '주입 시간', hint: '전체 처방 시간'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('hoursField'),
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(suffixText: '시간'),
                  validator: (value) => _validateTime(value, isMinute: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('minutesField'),
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(suffixText: '분'),
                  validator: (value) => _validateTime(value, isMinute: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: '수액세트', hint: '포장지의 점적계수 확인'),
          DropdownButtonFormField<int>(
            key: const Key('dropFactorField'),
            initialValue: dropFactor,
            decoration: const InputDecoration(),
            items: const [10, 15, 20, 60]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value gtt/mL'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onDropFactorChanged(value);
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

  String? _validateTime(String? value, {required bool isMinute}) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return '숫자를 입력해 주세요.';
    if (parsed < 0) return '0 이상이어야 합니다.';
    if (isMinute && parsed > 59) return '0~59 사이로 입력해 주세요.';
    if (!isMinute && parsed == 0 && int.tryParse(minutesController.text) == 0) {
      return '1분 이상 입력해 주세요.';
    }
    return null;
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
