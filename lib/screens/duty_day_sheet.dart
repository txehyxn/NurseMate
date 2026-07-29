import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/duty_schedule.dart';
import '../models/duty_type.dart';
import '../widgets/home/duty_calendar_card.dart';

class DutyDayEditResult {
  const DutyDayEditResult({required this.duty, required this.schedule});

  final DutyType? duty;
  final DutyDaySchedule schedule;
}

Future<DutyDayEditResult?> showDutyDaySheet({
  required BuildContext context,
  required DateTime date,
  required DutyType? duty,
  required DutyDaySchedule schedule,
}) {
  return showModalBottomSheet<DutyDayEditResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _DutyDaySheet(date: date, initialDuty: duty, initialSchedule: schedule),
  );
}

class _DutyDaySheet extends StatefulWidget {
  const _DutyDaySheet({
    required this.date,
    required this.initialDuty,
    required this.initialSchedule,
  });

  final DateTime date;
  final DutyType? initialDuty;
  final DutyDaySchedule initialSchedule;

  @override
  State<_DutyDaySheet> createState() => _DutyDaySheetState();
}

class _DutyDaySheetState extends State<_DutyDaySheet> {
  DutyType? _duty;
  bool _hasGathering = false;
  late final TextEditingController _gatheringTime;
  late final TextEditingController _gatheringMemo;
  final List<_AppointmentDraft> _appointments = [];
  bool _showTitleError = false;

  @override
  void initState() {
    super.initState();
    _duty = widget.initialDuty;
    final gathering = widget.initialSchedule.items
        .where((item) => item.type == DutyScheduleType.gathering)
        .firstOrNull;
    _hasGathering = gathering != null;
    _gatheringTime = TextEditingController(text: gathering?.time);
    _gatheringMemo = TextEditingController(text: gathering?.memo);
    _appointments.addAll(
      widget.initialSchedule.items
          .where((item) => item.type == DutyScheduleType.appointment)
          .map(_AppointmentDraft.fromItem),
    );
  }

  @override
  void dispose() {
    _gatheringTime.dispose();
    _gatheringMemo.dispose();
    for (final draft in _appointments) {
      draft.dispose();
    }
    super.dispose();
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    final hasInvalidTitle = _appointments.any(
      (draft) => draft.title.text.trim().isEmpty,
    );
    if (hasInvalidTitle) {
      setState(() => _showTitleError = true);
      return;
    }
    final items = <DutyScheduleItem>[
      if (_hasGathering)
        DutyScheduleItem(
          id: 'gathering',
          type: DutyScheduleType.gathering,
          title: '회식',
          time: _optional(_gatheringTime.text),
          memo: _optional(_gatheringMemo.text),
        ),
      for (final draft in _appointments)
        DutyScheduleItem(
          id: draft.id,
          type: DutyScheduleType.appointment,
          title: draft.title.text.trim(),
          time: _optional(draft.time.text),
          memo: _optional(draft.memo.text),
        ),
    ];
    Navigator.of(context).pop(
      DutyDayEditResult(
        duty: _duty,
        schedule: DutyDaySchedule(items: items),
      ),
    );
  }

  void _deleteAll() {
    Navigator.of(context).pop(
      const DutyDayEditResult(duty: null, schedule: DutyDaySchedule()),
    );
  }

  void _addAppointment() {
    setState(() {
      _appointments.add(
        _AppointmentDraft(id: DateTime.now().microsecondsSinceEpoch.toString()),
      );
      _showTitleError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: const BoxDecoration(
          color: NurseMateColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NurseMateRadii.panel),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: NurseMateColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.date.year}.${widget.date.month.toString().padLeft(2, '0')}.${widget.date.day.toString().padLeft(2, '0')} 일정',
                      style: const TextStyle(
                        color: NurseMateColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SheetSection(
                          title: '듀티 설정',
                          icon: Icons.badge_outlined,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _DutyChoice(
                                key: const Key('dutyChoice_none'),
                                label: '없음',
                                selected: _duty == null,
                                onTap: () => setState(() => _duty = null),
                              ),
                              for (final type in DutyType.values)
                                _DutyChoice(
                                  key: Key('dutyChoice_${type.name}'),
                                  label: type.label,
                                  badge: DutyBadge(type: type, compact: true),
                                  selected: _duty == type,
                                  onTap: () => setState(() => _duty = type),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NurseMateSpacing.md),
                        _SheetSection(
                          title: '🍻 회식',
                          icon: Icons.celebration_outlined,
                          trailing: Switch.adaptive(
                            key: const Key('gatheringSwitch'),
                            value: _hasGathering,
                            activeTrackColor: NurseMateColors.primary,
                            onChanged: (value) =>
                                setState(() => _hasGathering = value),
                          ),
                          child: AnimatedSwitcher(
                            duration: NurseMateMotion.standard,
                            child: !_hasGathering
                                ? const Text(
                                    '스위치를 켜면 회식 시간과 메모를 입력할 수 있어요.',
                                    key: Key('gatheringEmpty'),
                                    style: TextStyle(
                                      color: NurseMateColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  )
                                : Column(
                                    key: const Key('gatheringFields'),
                                    children: [
                                      NurseMateTextField(
                                        key: const Key('gatheringTimeField'),
                                        controller: _gatheringTime,
                                        label: '시간 (선택)',
                                        hintText: '예: 19:00',
                                        keyboardType: TextInputType.datetime,
                                      ),
                                      const SizedBox(
                                        height: NurseMateSpacing.sm,
                                      ),
                                      NurseMateTextField(
                                        key: const Key('gatheringMemoField'),
                                        controller: _gatheringMemo,
                                        label: '메모 (선택)',
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: NurseMateSpacing.md),
                        _SheetSection(
                          title: '📅 약속',
                          icon: Icons.event_outlined,
                          trailing: IconButton.filledTonal(
                            key: const Key('addAppointmentButton'),
                            tooltip: '약속 추가',
                            onPressed: _addAppointment,
                            icon: const Icon(Icons.add_rounded),
                          ),
                          child: _appointments.isEmpty
                              ? const Text(
                                  '약속을 추가하면 제목, 시간과 메모를 기록할 수 있어요.',
                                  style: TextStyle(
                                    color: NurseMateColors.textSecondary,
                                    height: 1.5,
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < _appointments.length;
                                      index++
                                    )
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              index == _appointments.length - 1
                                              ? 0
                                              : NurseMateSpacing.md,
                                        ),
                                        child: _AppointmentEditor(
                                          key: Key(
                                            'appointmentEditor_$index',
                                          ),
                                          index: index,
                                          draft: _appointments[index],
                                          showTitleError: _showTitleError,
                                          onRemove: () {
                                            final removed = _appointments
                                                .removeAt(index);
                                            removed.dispose();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: NurseMateSpacing.lg),
                        NurseMatePrimaryButton(
                          key: const Key('saveDutyDayButton'),
                          label: '저장',
                          icon: Icons.check_rounded,
                          onPressed: _save,
                        ),
                        const SizedBox(height: NurseMateSpacing.sm),
                        TextButton.icon(
                          key: const Key('deleteDutyDayButton'),
                          onPressed: _deleteAll,
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: NurseMateColors.error,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            '이 날짜의 모든 정보 삭제',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return NurseMateCard(
      radius: NurseMateRadii.card,
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NurseMateSectionTitle(title: title, icon: icon, trailing: trailing),
          const SizedBox(height: NurseMateSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _DutyChoice extends StatelessWidget {
  const _DutyChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? NurseMateColors.primarySoft : NurseMateColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NurseMateRadii.small),
        side: BorderSide(
          color: selected ? NurseMateColors.primary : NurseMateColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NurseMateRadii.small),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null) ...[
                  badge!,
                  const SizedBox(width: 7),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? NurseMateColors.primary
                        : NurseMateColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentDraft {
  _AppointmentDraft({
    required this.id,
    String title = '',
    String time = '',
    String memo = '',
  }) : title = TextEditingController(text: title),
       time = TextEditingController(text: time),
       memo = TextEditingController(text: memo);

  factory _AppointmentDraft.fromItem(DutyScheduleItem item) {
    return _AppointmentDraft(
      id: item.id,
      title: item.title,
      time: item.time ?? '',
      memo: item.memo ?? '',
    );
  }

  final String id;
  final TextEditingController title;
  final TextEditingController time;
  final TextEditingController memo;

  void dispose() {
    title.dispose();
    time.dispose();
    memo.dispose();
  }
}

class _AppointmentEditor extends StatelessWidget {
  const _AppointmentEditor({
    super.key,
    required this.index,
    required this.draft,
    required this.showTitleError,
    required this.onRemove,
  });

  final int index;
  final _AppointmentDraft draft;
  final bool showTitleError;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.md),
      decoration: BoxDecoration(
        color: NurseMateColors.surfaceMuted,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: NurseMateColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '약속 ${index + 1}',
                  style: const TextStyle(
                    color: NurseMateColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: '약속 삭제',
                onPressed: onRemove,
                color: NurseMateColors.error,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          NurseMateTextField(
            key: Key('appointmentTitleField_$index'),
            controller: draft.title,
            label: '제목',
            hintText: '예: 치과 예약',
            errorText:
                showTitleError && draft.title.text.trim().isEmpty
                ? '제목을 입력해주세요.'
                : null,
          ),
          const SizedBox(height: NurseMateSpacing.sm),
          NurseMateTextField(
            key: Key('appointmentTimeField_$index'),
            controller: draft.time,
            label: '시간 (선택)',
            hintText: '예: 15:00',
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: NurseMateSpacing.sm),
          NurseMateTextField(
            key: Key('appointmentMemoField_$index'),
            controller: draft.memo,
            label: '메모 (선택)',
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
