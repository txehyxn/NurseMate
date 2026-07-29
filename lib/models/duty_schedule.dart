import 'dart:convert';

enum DutyScheduleType { gathering, appointment }

class DutyScheduleItem {
  const DutyScheduleItem({
    required this.id,
    required this.type,
    required this.title,
    this.time,
    this.memo,
  });

  final String id;
  final DutyScheduleType type;
  final String title;
  final String? time;
  final String? memo;

  String get icon => type == DutyScheduleType.gathering ? '🍻' : '📅';

  DutyScheduleItem copyWith({String? title, String? time, String? memo}) {
    return DutyScheduleItem(
      id: id,
      type: type,
      title: title ?? this.title,
      time: time,
      memo: memo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    if (time != null) 'time': time,
    if (memo != null) 'memo': memo,
  };

  static DutyScheduleItem? fromJson(Object? value) {
    if (value is! Map) return null;
    final json = value.cast<String, dynamic>();
    final id = json['id'];
    final title = json['title'];
    final typeName = json['type'];
    if (id is! String || title is! String || typeName is! String) return null;
    final type = DutyScheduleType.values
        .where((candidate) => candidate.name == typeName)
        .firstOrNull;
    if (type == null) return null;
    return DutyScheduleItem(
      id: id,
      type: type,
      title: title,
      time: json['time'] as String?,
      memo: json['memo'] as String?,
    );
  }
}

class DutyDaySchedule {
  const DutyDaySchedule({this.items = const []});

  final List<DutyScheduleItem> items;

  bool get hasGathering =>
      items.any((item) => item.type == DutyScheduleType.gathering);
  bool get hasAppointment =>
      items.any((item) => item.type == DutyScheduleType.appointment);
  bool get isEmpty => items.isEmpty;

  List<Map<String, dynamic>> toJson() =>
      items.map((item) => item.toJson()).toList();

  static DutyDaySchedule fromJson(Object? value) {
    if (value is! List) return const DutyDaySchedule();
    return DutyDaySchedule(
      items: value
          .map(DutyScheduleItem.fromJson)
          .whereType<DutyScheduleItem>()
          .toList(growable: false),
    );
  }
}

Map<String, DutyDaySchedule> decodeDutySchedules(String? source) {
  if (source == null || source.isEmpty) return const {};
  try {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return const {};
    return {
      for (final entry in decoded.entries)
        if (entry.key is String)
          entry.key as String: DutyDaySchedule.fromJson(entry.value),
    };
  } on FormatException {
    return const {};
  }
}

String encodeDutySchedules(Map<String, DutyDaySchedule> schedules) {
  return jsonEncode({
    for (final entry in schedules.entries)
      if (!entry.value.isEmpty) entry.key: entry.value.toJson(),
  });
}
