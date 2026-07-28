import 'package:flutter/material.dart';

import '../models/drug.dart';
import '../repositories/drug_preferences_repository.dart';
import '../widgets/drug_image.dart';

class DrugDetailScreen extends StatefulWidget {
  const DrugDetailScreen({
    super.key,
    required this.drug,
    required this.preferencesRepository,
    this.initiallyFavorite = false,
  });

  final Drug drug;
  final DrugPreferencesRepository preferencesRepository;
  final bool initiallyFavorite;

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initiallyFavorite;
  }

  Future<void> _toggleFavorite() async {
    final nextValue = !_isFavorite;
    await widget.preferencesRepository.setFavorite(
      widget.drug.id,
      isFavorite: nextValue,
    );
    if (!mounted) return;
    setState(() => _isFavorite = nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final drug = widget.drug;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          '약 상세 정보',
          style: TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('favoriteDrugButton'),
            tooltip: _isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? const Color(0xFFF1A900) : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
              children: [
                _DrugHeader(drug: drug),
                const SizedBox(height: 14),
                _NursingPoints(drug: drug),
                _InfoSection(title: '효능·효과', body: drug.efficacy),
                _InfoSection(title: '용법·용량', body: drug.dosage),
                _WarningSection(
                  key: const Key('contraindicationSection'),
                  title: '금기사항',
                  body: drug.contraindication,
                  background: const Color(0xFFFFECEC),
                  foreground: const Color(0xFF9F1D1D),
                ),
                _WarningSection(
                  title: '주의사항',
                  body: drug.precaution,
                  background: const Color(0xFFFFF6DA),
                  foreground: const Color(0xFF745400),
                ),
                _InfoSection(title: '상호작용', body: drug.interaction),
                _InfoSection(title: '부작용', body: drug.adverseEffect),
                _InfoSection(title: '보관방법', body: drug.storage),
                _InfoSection(title: '제조사', body: drug.manufacturer),
                _InfoSection(
                  title: '보험코드',
                  body: drug.insuranceCode ?? '확인 가능한 보험코드 없음',
                ),
                _SourceCard(drug: drug),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrugHeader extends StatelessWidget {
  const _DrugHeader({required this.drug});

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFEAF2FD),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: DrugImage(drug: drug, size: 150)),
            const SizedBox(height: 16),
            Text(
              drug.productName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _LabeledValue(label: '한글 성분', value: drug.ingredientKor),
            _LabeledValue(label: '영문 성분', value: drug.ingredientEng),
            _LabeledValue(label: '제조사', value: drug.manufacturer),
            _LabeledValue(label: '구분', value: drug.prescriptionLabel),
            _LabeledValue(label: '제형', value: drug.dosageForm),
            _LabeledValue(label: '투여경로', value: drug.administrationRoute),
          ],
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '$label  $value',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDCE6F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 9),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _NursingPoints extends StatelessWidget {
  const _NursingPoints({required this.drug});

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('nursingPointsSection'),
      elevation: 0,
      color: const Color(0xFFF0F8F5),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('간호 포인트', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _PointGroup(
              title: '투약 전 확인사항',
              values: drug.nursingPoints.beforeAdministration,
            ),
            _PointGroup(
              title: '투약 후 관찰사항',
              values: drug.nursingPoints.afterAdministration,
            ),
            _PointGroup(
              title: '흔한 부작용',
              values: drug.nursingPoints.commonAdverseEffects,
            ),
            _PointGroup(
              title: '주의 환자',
              values: drug.nursingPoints.cautionPatients,
            ),
          ],
        ),
      ),
    );
  }
}

class _PointGroup extends StatelessWidget {
  const _PointGroup({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✔ $title', style: const TextStyle(fontWeight: FontWeight.w700)),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(left: 18, top: 4),
              child: Text('• $value'),
            ),
        ],
      ),
    );
  }
}

class _WarningSection extends StatelessWidget {
  const _WarningSection({
    super.key,
    required this.title,
    required this.body,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String body;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: foreground),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(body, style: TextStyle(color: foreground)),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.drug});

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final date =
        '${drug.updatedAt.year}-'
        '${twoDigits(drug.updatedAt.month)}-'
        '${twoDigits(drug.updatedAt.day)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Text(
        '출처: ${drug.source}\n마지막 확인일: $date\n\n'
        '실제 투약 전에는\n최신 허가사항과 병원 지침을 반드시 확인하세요.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
