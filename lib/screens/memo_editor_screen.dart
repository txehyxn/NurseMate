import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/highlighting_text_editing_controller.dart';
import '../models/memo.dart';
import '../repositories/memo_repository.dart';

typedef MemoPhotoPicker = Future<MemoPhoto?> Function();

Future<MemoPhoto?> pickMemoPhotoFromGallery() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 78,
    requestFullMetadata: false,
  );
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  return MemoPhoto(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    base64Data: base64Encode(bytes),
    mimeType: file.mimeType ?? _mimeTypeFromName(file.name),
  );
}

String _mimeTypeFromName(String name) {
  final lowerName = name.toLowerCase();
  if (lowerName.endsWith('.png')) return 'image/png';
  if (lowerName.endsWith('.gif')) return 'image/gif';
  if (lowerName.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

class MemoEditorScreen extends StatefulWidget {
  const MemoEditorScreen({
    super.key,
    required this.repository,
    this.memo,
    this.photoPicker = pickMemoPhotoFromGallery,
  });

  final MemoRepository repository;
  final Memo? memo;
  final MemoPhotoPicker photoPicker;

  @override
  State<MemoEditorScreen> createState() => _MemoEditorScreenState();
}

class _MemoEditorScreenState extends State<MemoEditorScreen> {
  late final TextEditingController _titleController;
  late final HighlightingTextEditingController _contentController;
  late final List<MemoPhoto> _photos;
  bool _isSaving = false;
  bool _isPickingPhoto = false;

  bool get _isEditing => widget.memo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title);
    _contentController = HighlightingTextEditingController(
      text: widget.memo?.content,
      highlights: widget.memo?.highlights ?? const [],
    );
    _photos = [...?widget.memo?.photos];
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
      content: _contentController.text,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      highlights: _contentController.highlights,
      photos: [..._photos],
    );
    await widget.repository.save(memo);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _addPhoto() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);
    try {
      final photo = await widget.photoPicker();
      if (photo != null && mounted) {
        setState(() => _photos.add(photo));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진을 불러오지 못했습니다. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  void _applyHighlight() {
    final didApply = _contentController.highlightSelection();
    if (!didApply) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('형광펜으로 강조할 문장을 먼저 선택해주세요.')));
    }
  }

  void _clearHighlight() {
    final didClear = _contentController.clearHighlightFromSelection();
    if (!didClear) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('형광펜을 지울 문장을 먼저 선택해주세요.')));
    }
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
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
                _MemoToolbar(
                  isPickingPhoto: _isPickingPhoto,
                  onAddPhoto: _addPhoto,
                  onApplyHighlight: _applyHighlight,
                  onClearHighlight: _clearHighlight,
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('memoContentField'),
                  controller: _contentController,
                  minLines: 12,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요.',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_photos.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('첨부 사진', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _PhotoGallery(
                    photos: _photos,
                    onRemove: (photo) {
                      setState(() => _photos.remove(photo));
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoToolbar extends StatelessWidget {
  const _MemoToolbar({
    required this.isPickingPhoto,
    required this.onAddPhoto,
    required this.onApplyHighlight,
    required this.onClearHighlight,
  });

  final bool isPickingPhoto;
  final VoidCallback onAddPhoto;
  final VoidCallback onApplyHighlight;
  final VoidCallback onClearHighlight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          key: const Key('addMemoPhotoButton'),
          onPressed: isPickingPhoto ? null : onAddPhoto,
          icon: isPickingPhoto
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('사진 추가'),
        ),
        FilledButton.tonalIcon(
          key: const Key('applyMemoHighlightButton'),
          onPressed: onApplyHighlight,
          icon: const Icon(Icons.border_color_outlined),
          label: const Text('형광펜'),
        ),
        TextButton.icon(
          key: const Key('clearMemoHighlightButton'),
          onPressed: onClearHighlight,
          icon: const Icon(Icons.format_color_reset_outlined),
          label: const Text('강조 지우기'),
        ),
      ],
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.photos, required this.onRemove});

  final List<MemoPhoto> photos;
  final ValueChanged<MemoPhoto> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final photo in photos)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  photo.bytes,
                  key: Key('memoPhoto_${photo.id}'),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 150,
                    height: 150,
                    child: ColoredBox(
                      color: Color(0xFFF0F3F7),
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filled(
                  key: Key('removeMemoPhoto_${photo.id}'),
                  tooltip: '사진 삭제',
                  onPressed: () => onRemove(photo),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
