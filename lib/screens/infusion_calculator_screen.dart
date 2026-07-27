import 'package:flutter/material.dart';

import '../models/infusion_calculation_result.dart';
import '../services/infusion_calculator.dart';
import '../widgets/calculation_result_section.dart';
import '../widgets/infusion_input_section.dart';

class InfusionCalculatorScreen extends StatefulWidget {
  const InfusionCalculatorScreen({super.key});

  @override
  State<InfusionCalculatorScreen> createState() =>
      _InfusionCalculatorScreenState();
}

class _InfusionCalculatorScreenState extends State<InfusionCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _volumeController = TextEditingController(text: '100');
  final _hoursController = TextEditingController(text: '3');
  final _minutesController = TextEditingController(text: '0');
  final _actualDropsController = TextEditingController();
  final _calculator = const InfusionCalculator();

  int _dropFactor = 20;
  InfusionCalculationResult? _result;
  InfusionComparison? _comparison;

  @override
  void dispose() {
    _volumeController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _actualDropsController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final result = _calculator.calculate(
        volumeMl: double.parse(_volumeController.text),
        hours: int.parse(_hoursController.text),
        minutes: int.parse(_minutesController.text),
        dropFactor: _dropFactor,
      );
      setState(() {
        _result = result;
        _comparison = null;
        _actualDropsController.clear();
      });
    } on Object catch (_) {
      _showMessage('입력값을 다시 확인해 주세요.');
    }
  }

  void _compare() {
    FocusScope.of(context).unfocus();
    final actual = double.tryParse(_actualDropsController.text);
    if (actual == null || !actual.isFinite || actual < 0) {
      _showMessage('1분간 관찰한 실제 방울 수를 입력해 주세요.');
      return;
    }
    final result = _result;
    if (result == null) return;
    setState(() => _comparison = result.compareWith(actual));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: const Row(
          children: [
            _BrandMark(),
            SizedBox(width: 10),
            Text(
              'NurseMate',
              style: TextStyle(
                color: Color(0xFF17324D),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '수액 속도를 계산하고\n챔버를 비교하세요',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text('처방 기준과 실제 챔버의 방울 수를 한 화면에서 확인할 수 있어요.'),
                  const SizedBox(height: 24),
                  _Panel(
                    child: InfusionInputSection(
                      formKey: _formKey,
                      volumeController: _volumeController,
                      hoursController: _hoursController,
                      minutesController: _minutesController,
                      dropFactor: _dropFactor,
                      onDropFactorChanged: (value) =>
                          setState(() => _dropFactor = value),
                      onCalculate: _calculate,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Panel(
                    child: _result == null
                        ? const _EmptyResult()
                        : CalculationResultSection(
                            result: _result!,
                            actualDropsController: _actualDropsController,
                            comparison: _comparison,
                            onCompare: _compare,
                          ),
                  ),
                  const SizedBox(height: 18),
                  const _SafetyNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E7EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A17324D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF2166D1),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text('계산 결과', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('수액 정보를 입력한 뒤 계산하기를 눌러 주세요.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 23),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1DFB4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF9A6B0A), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '계산 결과는 점적 속도 확인을 돕기 위한 참고값입니다. 실제 투여 전 처방, 수액세트 점적계수 및 기관 지침을 반드시 확인하세요.',
              style: TextStyle(color: Color(0xFF6F551B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
