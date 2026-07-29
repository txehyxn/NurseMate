import 'duty_type.dart';
import 'duty_schedule.dart';

class DutyCalendarDay {
  const DutyCalendarDay({
    required this.date,
    required this.isCurrentMonth,
    this.duty,
    this.schedule = const DutyDaySchedule(),
  });

  final DateTime date;
  final bool isCurrentMonth;
  final DutyType? duty;
  final DutyDaySchedule schedule;

  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}

List<DutyCalendarDay> buildDutyCalendarDays({
  required DateTime month,
  required Map<String, DutyType> duties,
  Map<String, DutyDaySchedule> schedules = const {},
}) {
  final normalizedMonth = DateTime(month.year, month.month);
  final leadingDays = normalizedMonth.weekday % DateTime.daysPerWeek;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final occupiedCells = leadingDays + daysInMonth;
  final cellCount =
      ((occupiedCells + DateTime.daysPerWeek - 1) ~/ DateTime.daysPerWeek) *
      DateTime.daysPerWeek;
  final firstVisibleDate = normalizedMonth.subtract(
    Duration(days: leadingDays),
  );

  return List.generate(cellCount, (index) {
    final date = firstVisibleDate.add(Duration(days: index));
    return DutyCalendarDay(
      date: date,
      isCurrentMonth: date.month == normalizedMonth.month,
      duty: duties[dutyDateKey(date)],
      schedule: schedules[dutyDateKey(date)] ?? const DutyDaySchedule(),
    );
  });
}

String dutyDateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

String dutyMonthLabel(DateTime month) => '${month.year}년 ${month.month}월';
