import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/checklist_item.dart';
import '../services/checklist_service.dart';
import '../widgets/checklist_tile.dart';
import '../widgets/progress_card.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({
    super.key,
    required this.shift,
    required this.title,
    required this.items,
    this.service,
    this.keyPrefix = 'checklist',
  });

  final ChecklistShift shift;
  final String title;
  final List<ChecklistItem> items;
  final ChecklistService? service;
  final String keyPrefix;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late final ChecklistService _service = widget.service ?? ChecklistService();
  Set<String> _completedIds = <String>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedItems();
  }

  Future<void> _loadCompletedItems() async {
    final validIds = widget.items.map((item) => item.id).toSet();
    final savedIds = await _service.loadCompleted(widget.shift);

    if (!mounted) return;
    setState(() {
      _completedIds = savedIds.where(validIds.contains).toSet();
      _isLoading = false;
    });
  }

  Future<void> _saveCompletedItems() {
    final orderedIds = widget.items
        .where((item) => _completedIds.contains(item.id))
        .map((item) => item.id);
    return _service.saveCompleted(widget.shift, orderedIds);
  }

  void _setItemCompleted(String id, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        _completedIds.add(id);
      } else {
        _completedIds.remove(id);
      }
    });
    _saveCompletedItems();
  }

  void _clearAll() {
    setState(_completedIds.clear);
    _service.clearCompleted(widget.shift);
  }

  void _completeAll() {
    setState(() {
      _completedIds = widget.items.map((item) => item.id).toSet();
    });
    _saveCompletedItems();
  }

  void _showSettingsNotice() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('체크리스트 설정은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NurseMateColors.background,
      appBar: AppBar(
        leading: IconButton(
          key: Key('${widget.keyPrefix}BackButton'),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            key: Key('${widget.keyPrefix}SettingsButton'),
            tooltip: '체크리스트 설정',
            onPressed: _showSettingsNotice,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: NurseMateSpacing.xs),
        ],
      ),
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
                  child: ChecklistProgressCard(
                    key: Key('${widget.keyPrefix}ProgressCard'),
                    keyPrefix: widget.keyPrefix,
                    completedCount: _completedIds.length,
                    totalCount: widget.items.length,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: NurseMateColors.primary,
                          ),
                        )
                      : ListView.separated(
                          key: Key('${widget.keyPrefix}List'),
                          padding: const EdgeInsets.fromLTRB(
                            NurseMateSpacing.page,
                            0,
                            NurseMateSpacing.page,
                            NurseMateSpacing.xl,
                          ),
                          itemCount: widget.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: NurseMateSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            final palette = _paletteFor(item.category);
                            return ChecklistTile(
                              key: Key('${widget.keyPrefix}Item-${item.id}'),
                              checkButtonKey: Key(
                                '${widget.keyPrefix}Check-${item.id}',
                              ),
                              item: item,
                              isCompleted: _completedIds.contains(item.id),
                              accentColor: palette.accent,
                              iconBackgroundColor: palette.soft,
                              onChanged: (isCompleted) =>
                                  _setItemCompleted(item.id, isCompleted),
                            );
                          },
                        ),
                ),
                _ChecklistBottomActions(
                  keyPrefix: widget.keyPrefix,
                  onClear: _isLoading ? null : _clearAll,
                  onComplete: _isLoading ? null : _completeAll,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistBottomActions extends StatelessWidget {
  const _ChecklistBottomActions({
    required this.keyPrefix,
    required this.onClear,
    required this.onComplete,
  });

  final String keyPrefix;
  final VoidCallback? onClear;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        NurseMateSpacing.page,
        NurseMateSpacing.sm,
        NurseMateSpacing.page,
        NurseMateSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: NurseMateColors.surface,
        border: Border(top: BorderSide(color: NurseMateColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F5D4DB2),
            blurRadius: 18,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: Key('${keyPrefix}ClearAllButton'),
              onPressed: onClear,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('전체 해제'),
            ),
          ),
          const SizedBox(width: NurseMateSpacing.sm),
          Expanded(
            child: NurseMatePrimaryButton(
              key: Key('${keyPrefix}CompleteAllButton'),
              label: '전체 완료',
              icon: Icons.done_all_rounded,
              onPressed: onComplete,
            ),
          ),
        ],
      ),
    );
  }
}

_ChecklistPalette _paletteFor(String? category) {
  return switch (category) {
    'blue' => const _ChecklistPalette(
      NurseMateColors.blue,
      NurseMateColors.blueSoft,
    ),
    'mint' => const _ChecklistPalette(
      NurseMateColors.mint,
      NurseMateColors.mintSoft,
    ),
    'pink' => const _ChecklistPalette(
      NurseMateColors.pink,
      NurseMateColors.pinkSoft,
    ),
    'error' => const _ChecklistPalette(
      NurseMateColors.error,
      NurseMateColors.pinkSoft,
    ),
    'orange' => const _ChecklistPalette(
      NurseMateColors.orange,
      NurseMateColors.orangeSoft,
    ),
    _ => const _ChecklistPalette(
      NurseMateColors.primary,
      NurseMateColors.primarySoft,
    ),
  };
}

class _ChecklistPalette {
  const _ChecklistPalette(this.accent, this.soft);

  final Color accent;
  final Color soft;
}
