import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/non_covered_exam.dart';
import '../services/non_covered_exam_history_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/exam_list_tile.dart';
import 'non_covered_exam_detail_screen.dart';

class NonCoveredExamScreen extends StatefulWidget {
  const NonCoveredExamScreen({
    super.key,
    required this.title,
    required this.exams,
    this.historyService,
  });

  final String title;
  final List<NonCoveredExam> exams;
  final NonCoveredExamHistoryService? historyService;

  @override
  State<NonCoveredExamScreen> createState() => _NonCoveredExamScreenState();
}

class _NonCoveredExamScreenState extends State<NonCoveredExamScreen> {
  late final NonCoveredExamHistoryService _historyService;
  var _query = '';
  Set<String> _favoriteNames = const <String>{};

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? NonCoveredExamHistoryService();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _historyService.loadFavorites();
    if (!mounted) return;
    setState(() => _favoriteNames = favorites.toSet());
  }

  Future<void> _toggleFavorite(NonCoveredExam exam) async {
    await _historyService.toggleFavorite(exam.name);
    await _loadFavorites();
  }

  Future<void> _openDetail(NonCoveredExam exam) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NonCoveredExamDetailScreen(
          exam: exam,
          historyService: _historyService,
        ),
      ),
    );
    await _loadFavorites();
  }

  List<NonCoveredExam> get _filteredExams {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.exams;

    return widget.exams
        .where((exam) => exam.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final exams = _filteredExams;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NurseMateSpacing.page,
                    NurseMateSpacing.xs,
                    NurseMateSpacing.page,
                    NurseMateSpacing.lg,
                  ),
                  child: AppSearchBar(
                    searchBarKey: const Key('nonCoveredExamSearchBar'),
                    text: _query,
                    hintText: '검사명을 검색하세요',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: NurseMateMotion.fast,
                    switchInCurve: NurseMateMotion.curve,
                    switchOutCurve: NurseMateMotion.curve,
                    child: exams.isEmpty
                        ? const EmptyState(
                            key: Key('nonCoveredExamEmptyResult'),
                            icon: Icons.search_rounded,
                            title: '검색 결과가 없습니다.',
                            description: '',
                          )
                        : ListView.separated(
                            key: const Key('nonCoveredExamList'),
                            padding: const EdgeInsets.fromLTRB(
                              NurseMateSpacing.page,
                              0,
                              NurseMateSpacing.page,
                              NurseMateSpacing.section,
                            ),
                            itemCount: exams.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: NurseMateSpacing.md),
                            itemBuilder: (context, index) {
                              final exam = exams[index];
                              return ExamListTile(
                                exam: exam,
                                favorite: _favoriteNames.contains(exam.name),
                                onTap: () => _openDetail(exam),
                                onFavorite: () => _toggleFavorite(exam),
                              );
                            },
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
