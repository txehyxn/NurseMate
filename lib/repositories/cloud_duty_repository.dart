import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/duty_calendar_day.dart';
import '../models/duty_type.dart';
import 'duty_repository.dart';

class SupabaseDutyRepository implements DutyRepository {
  SupabaseDutyRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async {
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    final rows = await _client
        .from('duties')
        .select('duty_date,duty_type')
        .eq('owner_id', _userId)
        .gte('duty_date', dutyDateKey(first))
        .lte('duty_date', dutyDateKey(last));
    final result = <String, DutyType>{};
    for (final rawRow in rows) {
      final row = (rawRow as Map).cast<String, dynamic>();
      final type = DutyType.fromStorage(row['duty_type']! as String);
      if (type != null) result[row['duty_date']! as String] = type;
    }
    return result;
  }

  @override
  Future<void> save(DateTime date, DutyType type) async {
    await _client.from('duties').upsert({
      'owner_id': _userId,
      'duty_date': dutyDateKey(date),
      'duty_type': type.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'owner_id,duty_date');
  }

  @override
  Future<void> delete(DateTime date) async {
    await _client
        .from('duties')
        .delete()
        .eq('owner_id', _userId)
        .eq('duty_date', dutyDateKey(date));
  }
}

class SyncedDutyRepository implements DutyRepository {
  SyncedDutyRepository({required this.local, required this.cloud});

  final DutyRepository local;
  final DutyRepository cloud;

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async {
    final localDuties = await local.getForMonth(month);
    try {
      final cloudDuties = await cloud.getForMonth(month);
      if (cloudDuties.isEmpty && localDuties.isNotEmpty) {
        for (final entry in localDuties.entries) {
          await cloud.save(DateTime.parse(entry.key), entry.value);
        }
        return localDuties;
      }
      for (final entry in cloudDuties.entries) {
        await local.save(DateTime.parse(entry.key), entry.value);
      }
      return cloudDuties;
    } on Object {
      return localDuties;
    }
  }

  @override
  Future<void> save(DateTime date, DutyType type) async {
    await local.save(date, type);
    try {
      await cloud.save(date, type);
    } on Object {
      // The local duty remains usable while the network is unavailable.
    }
  }

  @override
  Future<void> delete(DateTime date) async {
    await local.delete(date);
    try {
      await cloud.delete(date);
    } on Object {
      // Keep local duty management available offline.
    }
  }
}
