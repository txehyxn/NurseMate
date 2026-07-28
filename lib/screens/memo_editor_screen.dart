import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../repositories/memo_repository.dart';

class MemoEditorScreen extends StatefulWidget {
  const MemoEditorScreen({super.key, required this.repository, this.memo});

  final MemoRepository repository;
  final Memo? memo;

  @override
  State<MemoEditorScreen> createState() => _MemoEditorScreenState();
}

class _MemoEditorScreenState extends State<MemoEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  bool get _isEditing => widget.memo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title);
    _contentController = TextEditingController(text: widget.memo?.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final existing = widget.memo;
    final memo = Memo(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await widget.repository.save(memo);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              key: const Key('cancelDeleteMemoButton'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              key: const Key('confirmDeleteMemoButton'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || widget.memo == null) return;

    await widget.repository.delete(widget.memo!.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          _isEditing ? '메모 수정' : '새 메모',
          style: const TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              key: const Key('deleteMemoButton'),
              tooltip: '메모 삭제',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            key: const Key('saveMemoButton'),
            onPressed: _isSaving ? null : _save,
            child: const Text(
              '저장',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
              child: Column(
                children: [
                  TextField(
                    key: const Key('memoTitleField'),
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      hintText: '제목',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: TextField(
                      key: const Key('memoContentField'),
                      controller: _contentController,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: '내용을 입력하세요.',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
