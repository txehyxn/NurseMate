import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/duty_calendar_day.dart';
import '../models/duty_schedule.dart';
import '../models/duty_type.dart';
import '../repositories/duty_repository.dart';
import '../services/duty_schedule_service.dart';
import '../widgets/home/duty_calendar_card.dart';
import 'duty_day_sheet.dart';

class DutyManageScreen extends StatefulWidget {
  const DutyManageScreen({
    super.key,
    required this.repository,
    required this.initialMonth,
    this.today,
    this.scheduleService,
  });

  final DutyRepository repository;
  final DateTime initialMonth;
  final DateTime? today;
  final DutyScheduleService? scheduleService;

  @override
  State<DutyManageScreen> createState() => _DutyManageScreenState();
}

class _DutyManageScreenState extends State<DutyManageScreen> {
  late DateTime _month;
  DutyType _selectedType = DutyType.day;
  Map<String, DutyType> _duties = const {};
  Map<String, DutyDaySchedule> _schedules = const {};
  DutyScheduleService? _scheduleService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
    _scheduleService = widget.scheduleService;
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    _scheduleService ??= await DutyScheduleService.open();
    final duties = await widget.repository.getForMonth(_month);
    final schedules = _scheduleService!.loadMonth(_month);
    if (!mounted) return;
    setState(() {
      _duties = duties;
      _schedules = schedules;
      _isLoading = false;
    });
  }

  Future<void> _moveMonth(int offset) async {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset);
      _isLoading = true;
    });
    await _loadMonth();
  }

  Future<void> _editDay(DateTime date) async {
    if (date.year != _month.year || date.month != _month.month) return;
    final key = dutyDateKey(date);
    final result = await showDutyDaySheet(
      context: context,
      date: date,
      duty: _duties[key] ?? _selectedType,
      schedule: _schedules[key] ?? const DutyDaySchedule(),
    );
    if (result == null) return;
    if (result.duty == null) {
      await widget.repository.delete(date);
    } else {
      await widget.repository.save(date, result.duty!);
    }
    await _scheduleService!.save(date, result.schedule);
    await _loadMonth();
  }

  void _showSettingsMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('듀티 설정은 다음 업데이트에서 제공됩니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 듀티 관리')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      DutyCalendarCard(
                        month: _month,
                        duties: _duties,
                        schedules: _schedules,
                        today: widget.today,
                        onPreviousMonth: () => _moveMonth(-1),
                        onNextMonth: () => _moveMonth(1),
                        onManage: () {},
                        onSettings: _showSettingsMessage,
                        onDateTap: _editDay,
                        showManageButton: false,
                      ),
                      if (_isLoading)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: ColoredBox(
                              color: Color(0x33FFFFFF),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  NurseMateCard(
                    radius: NurseMateRadii.panel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const NurseMateSectionTitle(
                          title: '근무 선택',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        const SizedBox(height: NurseMateSpacing.xl),
                        DutySelector(
                          selectedType: _selectedType,
                          onSelected: (type) {
                            setState(() => _selectedType = type);
                          },
                        ),
                        const SizedBox(height: NurseMateSpacing.lg),
                        const Text(
                          '근무를 선택한 뒤 날짜를 눌러 달력에 표시하세요.\n'
                          '같은 근무가 지정된 날짜를 다시 누르면 삭제됩니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NurseMateColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: NurseMateSpacing.lg),
                        Container(
                          key: const Key('selectedDutySummary'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: NurseMateSpacing.lg,
                            vertical: NurseMateSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: NurseMateColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(
                              NurseMateRadii.input,
                            ),
                            border: Border.all(color: NurseMateColors.border),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '선택 근무:',
                                style: TextStyle(
                                  color: NurseMateColors.navy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: NurseMateSpacing.md),
                              DutyBadge(type: _selectedType),
                              const SizedBox(width: NurseMateSpacing.sm),
                              Text(
                                _selectedType.label,
                                style: const TextStyle(
                                  color: NurseMateColors.navy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NurseMateSpacing.lg),
                        NurseMatePrimaryButton(
                          key: const Key('saveDutyButton'),
                          label: '저장하고 홈으로',
                          icon: Icons.check_rounded,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
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

class DutySelector extends StatelessWidget {
  const DutySelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final DutyType selectedType;
  final ValueChanged<DutyType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 5 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: columns == 5 ? 1.25 : 1.4,
          children: [
            for (final type in DutyType.values)
              _DutySelectorCard(
                key: Key('dutySelector_${type.name}'),
                type: type,
                isSelected: selectedType == type,
                onTap: () => onSelected(type),
              ),
          ],
        );
      },
    );
  }
}

class _DutySelectorCard extends StatelessWidget {
  const _DutySelectorCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final DutyType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1 : 0.97,
      duration: NurseMateMotion.fast,
      curve: NurseMateMotion.curve,
      child: AnimatedContainer(
        duration: NurseMateMotion.standard,
        curve: NurseMateMotion.curve,
        decoration: BoxDecoration(
          color: type.background.withValues(alpha: isSelected ? 0.95 : 0.48),
          borderRadius: BorderRadius.circular(NurseMateRadii.card),
          border: Border.all(
            color: isSelected ? NurseMateColors.primary : type.background,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected ? NurseMateShadows.card : const [],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NurseMateRadii.card),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.label,
                style: TextStyle(
                  color: type.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type.code,
                style: TextStyle(
                  color: type.foreground,
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
