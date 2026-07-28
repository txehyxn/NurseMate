import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/cloud_duty_repository.dart';
import '../repositories/cloud_memo_repository.dart';
import '../repositories/duty_repository.dart';
import '../repositories/memo_repository.dart';
import 'cloud_service.dart';

abstract final class RepositoryService {
  static const _memoImportOwnerKey = 'cloudMemoImportOwner';
  static const _dutyImportOwnerKey = 'cloudDutyImportOwner';

  static Future<MemoRepository> openMemoRepository() async {
    final client = CloudService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return HiveMemoRepository.open();
    }
    final local = await HiveMemoRepository.open(namespace: user.id);
    final synced = SyncedMemoRepository(
      local: local,
      cloud: SupabaseMemoRepository(client, user.id),
    );
    await _importGuestMemosOnce(synced, user.id);
    return synced;
  }

  static Future<DutyRepository> openDutyRepository() async {
    final client = CloudService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return HiveDutyRepository.open();
    }
    final local = await HiveDutyRepository.open(namespace: user.id);
    final synced = SyncedDutyRepository(
      local: local,
      cloud: SupabaseDutyRepository(client, user.id),
    );
    await _importGuestDutiesOnce(synced, user.id);
    return synced;
  }

  static Future<void> _importGuestMemosOnce(
    MemoRepository target,
    String userId,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_memoImportOwnerKey) != null) return;
    final guest = await HiveMemoRepository.open();
    for (final memo in await guest.getAll()) {
      await target.save(memo);
    }
    await preferences.setString(_memoImportOwnerKey, userId);
  }

  static Future<void> _importGuestDutiesOnce(
    DutyRepository target,
    String userId,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_dutyImportOwnerKey) != null) return;
    final guest = await HiveDutyRepository.open();
    for (final entry in (await guest.getAll()).entries) {
      await target.save(DateTime.parse(entry.key), entry.value);
    }
    await preferences.setString(_dutyImportOwnerKey, userId);
  }
}
