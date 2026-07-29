import 'package:flutter/material.dart';

import '../data/non_covered_exam_descriptions.dart';
import '../design_system/nursemate_design_system.dart';
import '../models/non_covered_exam.dart';
import '../services/non_covered_exam_history_service.dart';
import '../widgets/price_text.dart';
import '../widgets/section_header.dart';

class NonCoveredExamDetailScreen extends StatefulWidget {
  const NonCoveredExamDetailScreen({
    super.key,
    required this.exam,
    this.historyService,
  });

  final NonCoveredExam exam;
  final NonCoveredExamHistoryService? historyService;

  @override
  State<NonCoveredExamDetailScreen> createState() =>
      _NonCoveredExamDetailScreenState();
}

class _NonCoveredExamDetailScreenState
    extends State<NonCoveredExamDetailScreen> {
  late final NonCoveredExamHistoryService _historyService;
  var _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? NonCoveredExamHistoryService();
    _loadState();
  }

  Future<void> _loadState() async {
    await _historyService.addRecent(widget.exam.name);
    final isFavorite = await _historyService.isFavorite(widget.exam.name);
    if (!mounted) return;
    setState(() => _isFavorite = isFavorite);
  }

  Future<void> _toggleFavorite() async {
    final isFavorite = await _historyService.toggleFavorite(widget.exam.name);
    if (!mounted) return;
    setState(() => _isFavorite = isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final details = examDescriptions[widget.exam.name];
    final description = details?.description ?? '';
    final note = details?.note ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.name),
        actions: [
          IconButton(
            key: const Key('nonCoveredFavoriteButton'),
            tooltip: _isFavorite ? '즐겨찾기 해제' : '즐겨찾기 등록',
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: NurseMateMotion.fast,
              switchInCurve: NurseMateMotion.curve,
              switchOutCurve: NurseMateMotion.curve,
              child: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                key: ValueKey(_isFavorite),
                color: _isFavorite
                    ? NurseMateColors.yellow
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: NurseMateSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            NurseMateSpacing.page,
            NurseMateSpacing.xs,
            NurseMateSpacing.page,
            NurseMateSpacing.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: NurseMateCard(
                radius: NurseMateRadii.card,
                padding: const EdgeInsets.all(NurseMateSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ExamHeader(exam: widget.exam),
                    const _SectionDivider(),
                    _DetailSection(
                      title: '설명',
                      content: description.isEmpty
                          ? '등록된 설명이 없습니다.'
                          : description,
                    ),
                    const _SectionDivider(),
                    _DetailSection(
                      title: '비고',
                      content: note.isEmpty ? '등록된 비고가 없습니다.' : note,
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

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({required this.exam});

  final NonCoveredExam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exam.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: NurseMateSpacing.sm),
        PriceText(
          exam.price,
          style: theme.textTheme.titleLarge?.copyWith(
            color: NurseMateColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: NurseMateSpacing.sm),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NurseMateSpacing.lg),
      child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
