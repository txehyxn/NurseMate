import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/highlighting_text_editing_controller.dart';
import '../design_system/nursemate_tokens.dart';
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
  Color _selectedHighlightColor =
      HighlightingTextEditingController.highlightColor;
  late bool _isFavorite;
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
    _isFavorite = widget.memo?.isFavorite ?? false;
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
      isFavorite: _isFavorite,
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
    final didApply = _contentController.highlightSelection(
      color: _selectedHighlightColor,
    );
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
          IconButton(
            key: const Key('toggleMemoFavoriteButton'),
            tooltip: _isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(_isFavorite),
                color: _isFavorite
                    ? NurseMateColors.orange
                    : NurseMateColors.textSecondary,
              ),
            ),
          ),
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
                  selectedHighlightColor: _selectedHighlightColor,
                  onAddPhoto: _addPhoto,
                  onApplyHighlight: _applyHighlight,
                  onClearHighlight: _clearHighlight,
                  onHighlightColorChanged: (color) {
                    setState(() => _selectedHighlightColor = color);
                  },
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
                  _MemoBodyImages(
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
    required this.selectedHighlightColor,
    required this.onAddPhoto,
    required this.onApplyHighlight,
    required this.onClearHighlight,
    required this.onHighlightColorChanged,
  });

  final bool isPickingPhoto;
  final Color selectedHighlightColor;
  final VoidCallback onAddPhoto;
  final VoidCallback onApplyHighlight;
  final VoidCallback onClearHighlight;
  final ValueChanged<Color> onHighlightColorChanged;

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
          label: const Text('본문에 사진 넣기'),
        ),
        _HighlightColorPicker(
          selectedColor: selectedHighlightColor,
          onChanged: onHighlightColorChanged,
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

class _HighlightColorPicker extends StatelessWidget {
  const _HighlightColorPicker({
    required this.selectedColor,
    required this.onChanged,
  });

  static const _labels = ['노랑', '민트', '분홍', '파랑', '보라'];

  final Color selectedColor;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('memoHighlightColorPicker'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NurseMateColors.surface,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: NurseMateColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (
            var index = 0;
            index < HighlightingTextEditingController.highlightColors.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(width: 5),
            _HighlightColorButton(
              color: HighlightingTextEditingController.highlightColors[index],
              label: _labels[index],
              isSelected:
                  selectedColor.toARGB32() ==
                  HighlightingTextEditingController.highlightColors[index]
                      .toARGB32(),
              onTap: () => onChanged(
                HighlightingTextEditingController.highlightColors[index],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HighlightColorButton extends StatelessWidget {
  const _HighlightColorButton({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label 형광펜',
      child: Tooltip(
        message: '$label 형광펜',
        child: InkWell(
          key: Key('memoHighlightColor_$label'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 30,
            height: 30,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? NurseMateColors.primarySoft
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? NurseMateColors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: NurseMateColors.navy,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoBodyImages extends StatelessWidget {
  const _MemoBodyImages({required this.photos, required this.onRemove});

  final List<MemoPhoto> photos;
  final ValueChanged<MemoPhoto> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final photo in photos)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: NurseMateColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(NurseMateRadii.input),
                    border: Border.all(color: NurseMateColors.border),
                  ),
                  child: Image.memory(
                    photo.bytes,
                    key: Key('memoPhoto_${photo.id}'),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ColoredBox(
                        color: NurseMateColors.surfaceMuted,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
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
          ),
      ],
    );
  }
}
