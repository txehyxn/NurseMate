import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/memo.dart';

abstract interface class MemoRepository {
  Future<List<Memo>> getAll();

  Future<void> save(Memo memo);

  Future<void> delete(String id);
}

class HiveMemoRepository implements MemoRepository {
  HiveMemoRepository._(this._box);

  static const String _boxName = 'nurseMateMemos';

  final Box<String> _box;

  static Future<HiveMemoRepository> open() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
    }
    final box = await Hive.openBox<String>(_boxName);
    return HiveMemoRepository._(box);
  }

  @override
  Future<List<Memo>> getAll() async {
    final memos = _box.values
        .map(
          (value) =>
              Memo.fromJson((jsonDecode(value) as Map).cast<String, Object?>()),
        )
        .toList();
    memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return memos;
  }

  @override
  Future<void> save(Memo memo) async {
    await _box.put(memo.id, jsonEncode(memo.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
