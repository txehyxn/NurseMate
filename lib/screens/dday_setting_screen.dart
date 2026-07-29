import 'package:flutter/material.dart';

import '../design_system/nursemate_components.dart';
import '../design_system/nursemate_tokens.dart';
import '../models/dday_setting.dart';
import '../services/dday_settings_service.dart';
import '../widgets/home/home_quick_sections.dart';

class DDaySettingScreen extends StatefulWidget {
  const DDaySettingScreen({
    super.key,
    this.initialSetting,
    this.settingsService,
    this.today,
  });

  final DDaySetting? initialSetting;
  final DDaySettingsService? settingsService;
  final DateTime? today;

  @override
  State<DDaySettingScreen> createState() => _DDaySettingScreenState();
}

class _DDaySettingScreenState extends State<DDaySettingScreen> {
  late final TextEditingController _titleController;
  late DateTime _selectedDate;
  late DDayCalculationMode _calculationMode;
  late DDayCardColor _cardColor;
  DDaySettingsService? _settingsService;
  String? _titleError;
  bool _isSaving = false;

  DateTime get _today => widget.today ?? DateTime.now();

  DDaySetting get _previewSetting {
    final title = _titleController.text.trim();
    return DDaySetting(
      title: title.isEmpty ? '제목을 입력하세요' : title,
      date: _selectedDate,
      calculationMode: _calculationMode,
      cardColor: _cardColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _settingsService = widget.settingsService;
    final initial =
        widget.initialSetting ??
        widget.settingsService?.load(today: _today) ??
        DDaySetting.defaultFor(_today);
    _titleController = TextEditingController(text: initial.title);
    _selectedDate = initial.date;
    _calculationMode = initial.calculationMode;
    _cardColor = initial.cardColor;
    if (widget.initialSetting == null && widget.settingsService == null) {
      _loadSavedSetting();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedSetting() async {
    final service = await DDaySettingsService.open();
    final setting = service.load(today: _today);
    if (!mounted) return;
    setState(() {
      _settingsService = service;
      _titleController.text = setting.title;
      _selectedDate = setting.date;
      _calculationMode = setting.calculationMode;
      _cardColor = setting.cardColor;
    });
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_today.year - 100),
      lastDate: DateTime(_today.year + 100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: NurseMateColors.primary,
              surface: NurseMateColors.surface,
              onSurface: NurseMateColors.navy,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: NurseMateColors.surface,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: NurseMateColors.primarySoft,
              headerForegroundColor: NurseMateColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NurseMateRadii.panel),
                side: const BorderSide(color: NurseMateColors.border),
              ),
              dayShape: WidgetStateProperty.all(const CircleBorder()),
              todayBorder: const BorderSide(color: NurseMateColors.primary),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: NurseMateColors.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NurseMateRadii.panel),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null || !mounted) return;
    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '제목을 입력해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
      _titleError = null;
    });

    try {
      final service = _settingsService ?? await DDaySettingsService.open();
      final setting = DDaySetting(
        title: title,
        date: _selectedDate,
        calculationMode: _calculationMode,
        cardColor: _cardColor,
      );
      final didSave = await service.save(setting);
      if (!didSave) {
        throw StateError('D-Day 설정을 저장하지 못했습니다.');
      }
      if (!mounted) return;
      Navigator.pop(context, setting);
    } on Object {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('D-Day 설정을 저장하지 못했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          key: const Key('ddayBackButton'),
          tooltip: '뒤로 가기',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        ),
        title: const Text('D-Day 설정'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: NurseMateSpacing.xs),
            child: TextButton(
              key: const Key('ddaySaveButton'),
              onPressed: _isSaving ? null : _save,
              style: TextButton.styleFrom(
                minimumSize: const Size(54, 44),
                foregroundColor: NurseMateColors.primary,
                disabledForegroundColor: NurseMateColors.textTertiary,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NurseMateRadii.small),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: NurseMateColors.primary,
                      ),
                    )
                  : const Text('저장'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            NurseMateSpacing.page,
            NurseMateSpacing.lg,
            NurseMateSpacing.page,
            NurseMateSpacing.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingSection(
                    title: '제목',
                    icon: Icons.edit_note_rounded,
                    child: NurseMateTextField(
                      controller: _titleController,
                      hintText: '예: 입사일, 시험일, 기념일',
                      errorText: _titleError,
                      onChanged: (_) {
                        setState(() => _titleError = null);
                      },
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  _SettingSection(
                    title: '날짜',
                    icon: Icons.calendar_month_rounded,
                    child: _DateSelector(
                      date: _selectedDate,
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  _SettingSection(
                    title: '계산 방식',
                    icon: Icons.calculate_outlined,
                    child: _CalculationModeSelector(
                      selectedMode: _calculationMode,
                      onSelected: (mode) {
                        setState(() => _calculationMode = mode);
                      },
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  _SettingSection(
                    title: '카드 색상',
                    icon: Icons.palette_outlined,
                    child: _CardColorSelector(
                      selectedColor: _cardColor,
                      onSelected: (color) {
                        setState(() => _cardColor = color);
                      },
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  const NurseMateSectionTitle(
                    title: '미리보기',
                    icon: Icons.visibility_outlined,
                  ),
                  const SizedBox(height: NurseMateSpacing.md),
                  SizedBox(
                    height: 205,
                    child: DDayCard(
                      key: const Key('ddayPreviewCard'),
                      setting: _previewSetting,
                      today: _today,
                      compact: false,
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

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NurseMateSectionTitle(title: title, icon: icon),
        const SizedBox(height: NurseMateSpacing.md),
        child,
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 58,
        decoration: BoxDecoration(
          color: NurseMateColors.surface,
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
          border: Border.all(color: NurseMateColors.border),
        ),
        child: InkWell(
          key: const Key('ddayDateSelector'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NurseMateSpacing.lg,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  color: NurseMateColors.primary,
                  size: 23,
                ),
                const SizedBox(width: NurseMateSpacing.sm),
                Expanded(
                  child: Text(
                    '${date.year}년 ${date.month}월 ${date.day}일',
                    style: const TextStyle(
                      color: NurseMateColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NurseMateColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculationModeSelector extends StatelessWidget {
  const _CalculationModeSelector({
    required this.selectedMode,
    required this.onSelected,
  });

  final DDayCalculationMode selectedMode;
  final ValueChanged<DDayCalculationMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NurseMateColors.surfaceMuted,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: NurseMateColors.border),
      ),
      child: Row(
        children: DDayCalculationMode.values.map((mode) {
          final selected = mode == selectedMode;
          return Expanded(
            child: AnimatedContainer(
              duration: NurseMateMotion.standard,
              curve: NurseMateMotion.curve,
              decoration: BoxDecoration(
                color: selected ? NurseMateColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(NurseMateRadii.small),
                border: Border.all(
                  color: selected
                      ? NurseMateColors.primary.withValues(alpha: 0.32)
                      : Colors.transparent,
                ),
                boxShadow: selected ? NurseMateShadows.card : const [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: Key('ddayMode-${mode.name}'),
                  onTap: () => onSelected(mode),
                  borderRadius: BorderRadius.circular(NurseMateRadii.small),
                  child: Center(
                    child: Text(
                      mode.label,
                      style: TextStyle(
                        color: selected
                            ? NurseMateColors.primary
                            : NurseMateColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CardColorSelector extends StatelessWidget {
  const _CardColorSelector({
    required this.selectedColor,
    required this.onSelected,
  });

  final DDayCardColor selectedColor;
  final ValueChanged<DDayCardColor> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: NurseMateSpacing.sm,
      runSpacing: NurseMateSpacing.md,
      children: DDayCardColor.values.map((color) {
        final selected = color == selectedColor;
        return Semantics(
          selected: selected,
          button: true,
          label: '${color.label} 카드 색상',
          child: InkWell(
            key: Key('ddayColor-${color.name}'),
            onTap: () => onSelected(color),
            borderRadius: BorderRadius.circular(NurseMateRadii.input),
            child: SizedBox(
              width: 58,
              height: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: NurseMateMotion.standard,
                    curve: NurseMateMotion.curve,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? NurseMateColors.navy
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? NurseMateShadows.floating
                          : const [],
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 23,
                          )
                        : null,
                  ),
                  const SizedBox(height: NurseMateSpacing.xs),
                  Text(
                    color.label,
                    style: TextStyle(
                      color: selected
                          ? NurseMateColors.navy
                          : NurseMateColors.textSecondary,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
