import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/memo.dart';
import 'memo_repository.dart';

class SupabaseMemoRepository implements MemoRepository {
  SupabaseMemoRepository(this._client, this._userId);

  static const _bucket = 'memo-images';

  final SupabaseClient _client;
  final String _userId;

  @override
  Future<List<Memo>> getAll() async {
    final rows = await _client
        .from('memos')
        .select()
        .eq('owner_id', _userId)
        .order('updated_at', ascending: false);
    final memos = <Memo>[];
    for (final rawRow in rows) {
      final row = (rawRow as Map).cast<String, dynamic>();
      memos.add(await _memoFromRow(row));
    }
    return memos;
  }

  @override
  Future<void> save(Memo memo) async {
    final previous = await _client
        .from('memos')
        .select('photos')
        .eq('owner_id', _userId)
        .eq('id', memo.id)
        .maybeSingle();
    final previousPaths = _photoPaths(previous?['photos']);
    final photos = <Map<String, Object>>[];

    for (final photo in memo.photos) {
      final path =
          '$_userId/${memo.id}/${photo.id}.${_extension(photo.mimeType)}';
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            photo.bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: photo.mimeType,
              cacheControl: '3600',
            ),
          );
      photos.add({
        'id': photo.id,
        'mimeType': photo.mimeType,
        'storagePath': path,
      });
    }

    final currentPaths = photos
        .map((photo) => photo['storagePath']! as String)
        .toSet();
    final removedPaths = previousPaths.difference(currentPaths).toList();
    if (removedPaths.isNotEmpty) {
      await _client.storage.from(_bucket).remove(removedPaths);
    }

    await _client.from('memos').upsert({
      'owner_id': _userId,
      'id': memo.id,
      'title': memo.title,
      'content': memo.content,
      'created_at': memo.createdAt.toUtc().toIso8601String(),
      'updated_at': memo.updatedAt.toUtc().toIso8601String(),
      'highlights': memo.highlights
          .map((highlight) => highlight.toJson())
          .toList(),
      'photos': photos,
      'is_favorite': memo.isFavorite,
    }, onConflict: 'owner_id,id');
  }

  @override
  Future<void> delete(String id) async {
    final row = await _client
        .from('memos')
        .select('photos')
        .eq('owner_id', _userId)
        .eq('id', id)
        .maybeSingle();
    final paths = _photoPaths(row?['photos']).toList();
    if (paths.isNotEmpty) {
      await _client.storage.from(_bucket).remove(paths);
    }
    await _client.from('memos').delete().eq('owner_id', _userId).eq('id', id);
  }

  Future<Memo> _memoFromRow(Map<String, dynamic> row) async {
    final photos = <MemoPhoto>[];
    for (final rawPhoto in _jsonList(row['photos'])) {
      final path = rawPhoto['storagePath'] as String?;
      if (path == null || path.isEmpty) continue;
      try {
        final bytes = await _client.storage.from(_bucket).download(path);
        photos.add(
          MemoPhoto(
            id: rawPhoto['id']! as String,
            mimeType: (rawPhoto['mimeType'] as String?) ?? 'image/jpeg',
            base64Data: base64Encode(bytes),
          ),
        );
      } on StorageException {
        // A missing image must not prevent the rest of the memo from loading.
      }
    }

    final content = (row['content'] as String?) ?? '';
    return Memo(
      id: row['id']! as String,
      title: (row['title'] as String?) ?? '',
      content: content,
      createdAt: DateTime.parse(row['created_at']! as String).toLocal(),
      updatedAt: DateTime.parse(row['updated_at']! as String).toLocal(),
      highlights: _jsonList(row['highlights'])
          .map(MemoHighlight.fromJson)
          .where((highlight) => highlight.isValidFor(content))
          .toList(),
      photos: photos,
      isFavorite: (row['is_favorite'] as bool?) ?? false,
    );
  }

  Set<String> _photoPaths(Object? value) {
    return _jsonList(value)
        .map((photo) => photo['storagePath'] as String?)
        .whereType<String>()
        .toSet();
  }
}

class SyncedMemoRepository implements MemoRepository {
  SyncedMemoRepository({required this.local, required this.cloud});

  final MemoRepository local;
  final MemoRepository cloud;

  @override
  Future<List<Memo>> getAll() async {
    final localMemos = await local.getAll();
    try {
      final cloudMemos = await cloud.getAll();
      final merged = <String, Memo>{
        for (final memo in localMemos) memo.id: memo,
      };
      for (final cloudMemo in cloudMemos) {
        final localMemo = merged[cloudMemo.id];
        if (localMemo == null ||
            cloudMemo.updatedAt.isAfter(localMemo.updatedAt)) {
          merged[cloudMemo.id] = cloudMemo;
          await local.save(cloudMemo);
        }
      }
      for (final localMemo in localMemos) {
        final cloudMemo = cloudMemos
            .where((memo) => memo.id == localMemo.id)
            .firstOrNull;
        if (cloudMemo == null ||
            localMemo.updatedAt.isAfter(cloudMemo.updatedAt)) {
          await cloud.save(localMemo);
        }
      }
      final result = merged.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return result;
    } on Object {
      return localMemos;
    }
  }

  @override
  Future<void> save(Memo memo) async {
    await local.save(memo);
    try {
      await cloud.save(memo);
    } on Object {
      // The local copy remains available and is retried on the next sync.
    }
  }

  @override
  Future<void> delete(String id) async {
    await local.delete(id);
    try {
      await cloud.delete(id);
    } on Object {
      // Keep the app usable offline. A later sync can retry cloud work.
    }
  }
}

List<Map<String, Object?>> _jsonList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, Object?>())
      .toList();
}

String _extension(String mimeType) {
  return switch (mimeType.toLowerCase()) {
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
    _ => 'jpg',
  };
}
