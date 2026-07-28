import 'package:flutter/material.dart';

import '../design_system/nursemate_tokens.dart';
import '../models/memo.dart';
import '../repositories/memo_repository.dart';
import '../widgets/highlighted_memo_text.dart';
import 'memo_editor_screen.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key, this.repository, this.photoPicker});

  final MemoRepository? repository;
  final MemoPhotoPicker? photoPicker;

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  MemoRepository? _repository;
  List<Memo> _memos = const [];
  String _query = '';
  bool _showFavoritesOnly = false;
  bool _isLoading = true;
  Object? _loadError;

  List<Memo> get _filteredMemos {
    final query = _query.trim().toLowerCase();
    return _memos.where((memo) {
      if (_showFavoritesOnly && !memo.isFavorite) return false;
      if (query.isEmpty) return true;
      return memo.title.toLowerCase().contains(query) ||
          memo.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _repository = widget.repository ?? await HiveMemoRepository.open();
      await _loadMemos();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMemos() async {
    final repository = _repository;
    if (repository == null) return;
    final memos = await repository.getAll();
    if (!mounted) return;
    setState(() {
      _memos = memos;
      _isLoading = false;
      _loadError = null;
    });
  }

  Future<void> _openEditor([Memo? memo]) async {
    final repository = _repository;
    if (repository == null) return;
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MemoEditorScreen(
          repository: repository,
          memo: memo,
          photoPicker: widget.photoPicker ?? pickMemoPhotoFromGallery,
        ),
      ),
    );
    if (didChange == true) {
      await _loadMemos();
    }
  }

  Future<void> _toggleFavorite(Memo memo) async {
    final repository = _repository;
    if (repository == null) return;
    await repository.save(memo.copyWith(isFavorite: !memo.isFavorite));
    await _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          '메모장',
          style: TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('addMemoButton'),
            tooltip: '새 메모',
            onPressed: _repository == null ? null : () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FavoriteFilterButton(
                      isSelected: _showFavoritesOnly,
                      onTap: () => setState(
                        () => _showFavoritesOnly = !_showFavoritesOnly,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchBar(
                    key: const Key('memoSearchBar'),
                    hintText: '메모 검색',
                    leading: const Icon(Icons.search_rounded),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return const Center(child: Text('메모를 불러오지 못했습니다.'));
    }

    final memos = _filteredMemos;
    if (memos.isEmpty) {
      if (_query.trim().isNotEmpty) {
        return const Center(child: Text('검색 결과가 없습니다.'));
      }
      return const Center(
        child: Text(
          '작성된 메모가 없습니다.\n\n'
          '오른쪽 위 + 버튼을 눌러\n'
          '첫 번째 메모를 작성해보세요.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: memos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _MemoCard(
          memo: memos[index],
          onTap: _openEditor,
          onFavoriteToggle: _toggleFavorite,
        );
      },
    );
  }
}

class _MemoCard extends StatelessWidget {
  const _MemoCard({
    required this.memo,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Memo memo;
  final ValueChanged<Memo> onTap;
  final ValueChanged<Memo> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('memoCard_${memo.id}'),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDCE6F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(memo),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            memo.title.isEmpty ? '제목 없음' : memo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          key: Key('memoFavorite_${memo.id}'),
                          tooltip: memo.isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
                          onPressed: () => onFavoriteToggle(memo),
                          icon: Icon(
                            memo.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: memo.isFavorite
                                ? NurseMateColors.orange
                                : NurseMateColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    HighlightedMemoText(
                      text: memo.content.isEmpty ? '내용 없음' : memo.content,
                      highlights: memo.content.isEmpty
                          ? const []
                          : memo.highlights,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatDateTime(memo.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (memo.photos.isNotEmpty) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    memo.photos.first.bytes,
                    key: Key('memoCardPhoto_${memo.id}'),
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 82,
                      height: 82,
                      child: ColoredBox(
                        color: Color(0xFFF0F3F7),
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteFilterButton extends StatelessWidget {
  const _FavoriteFilterButton({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('favoriteMemoFilterButton'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(NurseMateRadii.button),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? NurseMateColors.primarySoft
                : NurseMateColors.surface,
            borderRadius: BorderRadius.circular(NurseMateRadii.button),
            border: Border.all(
              color: isSelected
                  ? NurseMateColors.primary.withValues(alpha: 0.35)
                  : NurseMateColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 19,
                color: isSelected
                    ? NurseMateColors.primary
                    : NurseMateColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                '즐겨찾기만 보기',
                style: TextStyle(
                  color: isSelected
                      ? NurseMateColors.primary
                      : NurseMateColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}
