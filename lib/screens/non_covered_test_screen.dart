import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/non_covered_exam.dart';
import '../models/non_covered_test_item.dart';
import '../repositories/non_covered_exam_repository.dart';
import '../services/non_covered_exam_history_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/exam_list_tile.dart';
import '../widgets/section_header.dart';
import 'non_covered_exam_detail_screen.dart';
import 'non_covered_exam_screen.dart';

class NonCoveredTestScreen extends StatefulWidget {
  const NonCoveredTestScreen({super.key, this.historyService, this.repository});

  final NonCoveredExamHistoryService? historyService;
  final NonCoveredExamRepository? repository;

  @override
  State<NonCoveredTestScreen> createState() => _NonCoveredTestScreenState();
}

class _NonCoveredTestScreenState extends State<NonCoveredTestScreen> {
  late final NonCoveredExamHistoryService _historyService;
  late final NonCoveredExamRepository _repository;
  var _query = '';
  List<NonCoveredExam> _recentExams = const <NonCoveredExam>[];
  List<NonCoveredExam> _favoriteExams = const <NonCoveredExam>[];
  Set<String> _favoriteNames = const <String>{};

  static const _items = <NonCoveredTestItem>[
    NonCoveredTestItem(id: 'ultrasound', emoji: '🩻', name: '초음파'),
    NonCoveredTestItem(id: 'mri', emoji: '🧲', name: 'MRI'),
    NonCoveredTestItem(id: 'procedure', emoji: '🏥', name: '시술'),
    NonCoveredTestItem(id: 'etc', emoji: '📦', name: '기타'),
    NonCoveredTestItem(id: 'ct', emoji: '🩻', name: 'CT'),
  ];

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? NonCoveredExamHistoryService();
    _repository = widget.repository ?? const LocalNonCoveredExamRepository();
    _loadSavedExams();
  }

  List<NonCoveredExam> get _searchResults {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const <NonCoveredExam>[];
    return _repository
        .getAll()
        .where((exam) => exam.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  List<NonCoveredExam> _examsFor(String categoryId) {
    return switch (categoryId) {
      'ultrasound' => _repository.getUltrasound(),
      'mri' => _repository.getMRI(),
      'procedure' => _repository.getProcedure(),
      'etc' => _repository.getEtc(),
      'ct' => _repository.getCT(),
      _ => const <NonCoveredExam>[],
    };
  }

  Future<void> _loadSavedExams() async {
    final results = await Future.wait([
      _historyService.loadRecent(),
      _historyService.loadFavorites(),
    ]);
    if (!mounted) return;

    setState(() {
      _recentExams = _resolveExams(results[0]);
      _favoriteExams = _resolveExams(results[1]);
      _favoriteNames = results[1].toSet();
    });
  }

  Future<void> _toggleFavorite(NonCoveredExam exam) async {
    await _historyService.toggleFavorite(exam.name);
    await _loadSavedExams();
  }

  List<NonCoveredExam> _resolveExams(List<String> names) {
    final examsByName = <String, NonCoveredExam>{
      for (final exam in _repository.getAll()) exam.name: exam,
    };
    return names
        .map((name) => examsByName[name])
        .whereType<NonCoveredExam>()
        .toList(growable: false);
  }

  Future<void> _openCategory(NonCoveredTestItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NonCoveredExamScreen(
          title: item.name,
          exams: _examsFor(item.id),
          historyService: _historyService,
        ),
      ),
    );
    await _loadSavedExams();
  }

  Future<void> _openExam(NonCoveredExam exam) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NonCoveredExamDetailScreen(
          exam: exam,
          historyService: _historyService,
        ),
      ),
    );
    await _loadSavedExams();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchResults;
    final isSearching = _query.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('비급여 검사')),
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
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSearchBar(
                    searchBarKey: const Key('nonCoveredTestSearchBar'),
                    text: _query,
                    hintText: '검사명을 검색하세요',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  if (!isSearching && _recentExams.isNotEmpty) ...[
                    const SizedBox(height: NurseMateSpacing.xl),
                    _SavedExamSection(
                      key: const Key('nonCoveredRecentSection'),
                      title: '최근 조회',
                      icon: Icons.history_rounded,
                      exams: _recentExams,
                      favoriteNames: _favoriteNames,
                      onTap: _openExam,
                      onFavorite: _toggleFavorite,
                    ),
                  ],
                  if (!isSearching && _favoriteExams.isNotEmpty) ...[
                    const SizedBox(height: NurseMateSpacing.xl),
                    _SavedExamSection(
                      key: const Key('nonCoveredFavoriteSection'),
                      title: '즐겨찾기',
                      icon: Icons.star_rounded,
                      exams: _favoriteExams,
                      favoriteNames: _favoriteNames,
                      onTap: _openExam,
                      onFavorite: _toggleFavorite,
                    ),
                  ],
                  const SizedBox(height: NurseMateSpacing.xl),
                  if (isSearching)
                    AnimatedSwitcher(
                      duration: NurseMateMotion.fast,
                      switchInCurve: NurseMateMotion.curve,
                      switchOutCurve: NurseMateMotion.curve,
                      child: searchResults.isEmpty
                          ? const _EmptySearchResult()
                          : _ExamSearchResults(
                              key: ValueKey(
                                searchResults
                                    .map((exam) => exam.name)
                                    .join(','),
                              ),
                              exams: searchResults,
                              favoriteNames: _favoriteNames,
                              onTap: _openExam,
                              onFavorite: _toggleFavorite,
                            ),
                    )
                  else
                    _TestItemGrid(items: _items, onTap: _openCategory),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamSearchResults extends StatelessWidget {
  const _ExamSearchResults({
    super.key,
    required this.exams,
    required this.favoriteNames,
    required this.onTap,
    required this.onFavorite,
  });

  final List<NonCoveredExam> exams;
  final Set<String> favoriteNames;
  final ValueChanged<NonCoveredExam> onTap;
  final ValueChanged<NonCoveredExam> onFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('nonCoveredGlobalSearchResults'),
      children: [
        for (var index = 0; index < exams.length; index++) ...[
          ExamListTile(
            exam: exams[index],
            favorite: favoriteNames.contains(exams[index].name),
            onTap: () => onTap(exams[index]),
            onFavorite: () => onFavorite(exams[index]),
          ),
          if (index != exams.length - 1)
            const SizedBox(height: NurseMateSpacing.md),
        ],
      ],
    );
  }
}

class _SavedExamSection extends StatelessWidget {
  const _SavedExamSection({
    super.key,
    required this.title,
    required this.icon,
    required this.exams,
    required this.favoriteNames,
    required this.onTap,
    required this.onFavorite,
  });

  final String title;
  final IconData icon;
  final List<NonCoveredExam> exams;
  final Set<String> favoriteNames;
  final ValueChanged<NonCoveredExam> onTap;
  final ValueChanged<NonCoveredExam> onFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title, icon: icon),
        const SizedBox(height: NurseMateSpacing.md),
        for (var index = 0; index < exams.length; index++) ...[
          ExamListTile(
            exam: exams[index],
            favorite: favoriteNames.contains(exams[index].name),
            showPrice: false,
            onTap: () => onTap(exams[index]),
            onFavorite: () => onFavorite(exams[index]),
          ),
          if (index != exams.length - 1)
            const SizedBox(height: NurseMateSpacing.sm),
        ],
      ],
    );
  }
}

class _TestItemGrid extends StatelessWidget {
  const _TestItemGrid({required this.items, required this.onTap});

  final List<NonCoveredTestItem> items;
  final ValueChanged<NonCoveredTestItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 640 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - NurseMateSpacing.md * (columnCount - 1)) /
            columnCount;
        return Wrap(
          spacing: NurseMateSpacing.md,
          runSpacing: NurseMateSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _CategoryCard(item: item, onTap: () => onTap(item)),
              ),
          ],
        );
      },
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('nonCoveredEmptySearchResult'),
      height: 280,
      child: const EmptyState(
        icon: Icons.search_rounded,
        iconKey: Key('nonCoveredEmptySearchIcon'),
        title: '검색 결과가 없습니다.',
        description: '',
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.onTap});

  final NonCoveredTestItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NurseMateCard(
      key: Key('nonCoveredCategory-${item.id}'),
      radius: NurseMateRadii.button,
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? NurseMateColors.primary.withValues(alpha: 0.18)
                  : NurseMateColors.primarySoft,
              borderRadius: BorderRadius.circular(NurseMateRadii.input),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 27)),
          ),
          const SizedBox(width: NurseMateSpacing.md),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: NurseMateSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
