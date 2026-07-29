import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/duty_type.dart';
import '../models/duty_calendar_day.dart';
import '../models/duty_schedule.dart';
import '../models/dday_setting.dart';
import '../repositories/duty_repository.dart';
import '../repositories/memo_repository.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import '../services/dday_settings_service.dart';
import '../services/duty_schedule_service.dart';
import '../services/repository_service.dart';
import '../widgets/home/duty_calendar_card.dart';
import '../widgets/home/home_bottom_navigation.dart';
import '../widgets/home/home_feature_card.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_illustration.dart';
import '../widgets/home/home_quick_sections.dart';
import 'appearance_screen.dart';
import 'checklist_home_screen.dart';
import 'coming_soon_screen.dart';
import 'dday_setting_screen.dart';
import 'duty_day_sheet.dart';
import 'duty_manage_screen.dart';
import 'infusion_calculator_screen.dart';
import 'infusion_speed_check_screen.dart';
import 'memo_list_screen.dart';
import 'my_page_screen.dart';

final Uri kKpicDrugSearchUri = Uri.parse(
  'https://health.kr/searchDrug/search_detail.asp',
);
final Uri kAsanDiseaseEncyclopediaUri = Uri.parse(
  'https://www.amc.seoul.kr/asan/main.do',
);

typedef ExternalUrlLauncher =
    Future<bool> Function(Uri uri, LaunchMode mode);

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({
    super.key,
    this.memoRepository,
    this.dutyRepository,
    this.initialDutyMonth,
    this.dutyToday,
    this.authService,
    this.dDaySettingsService,
    this.dDayToday,
    this.initialDDaySetting,
    this.dutyScheduleService,
    this.diseaseUrlLauncher,
  });

  final MemoRepository? memoRepository;
  final DutyRepository? dutyRepository;
  final DateTime? initialDutyMonth;
  final DateTime? dutyToday;
  final AuthService? authService;
  final DDaySettingsService? dDaySettingsService;
  final DateTime? dDayToday;
  final DDaySetting? initialDDaySetting;
  final DutyScheduleService? dutyScheduleService;
  final ExternalUrlLauncher? diseaseUrlLauncher;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  DutyRepository? _dutyRepository;
  MemoRepository? _memoRepository;
  late DateTime _dutyMonth;
  Map<String, DutyType> _duties = const {};
  Map<String, DutyDaySchedule> _dutySchedules = const {};
  DutyScheduleService? _dutyScheduleService;
  DDaySettingsService? _dDaySettingsService;
  late DDaySetting _dDaySetting;

  DateTime get _dDayToday => widget.dDayToday ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final initialMonth = widget.initialDutyMonth ?? DateTime.now();
    _dutyMonth = DateTime(initialMonth.year, initialMonth.month);
    _dutyRepository = widget.dutyRepository;
    _memoRepository = widget.memoRepository;
    _dutyScheduleService = widget.dutyScheduleService;
    _dDaySettingsService = widget.dDaySettingsService;
    _dDaySetting =
        widget.initialDDaySetting ?? DDaySetting.defaultFor(_dDayToday);
    _initializeRepositories();
    if (widget.initialDDaySetting == null) {
      _initializeDDay();
    }
  }

  Future<void> _initializeRepositories() async {
    _dutyRepository ??= await RepositoryService.openDutyRepository();
    _memoRepository ??= await RepositoryService.openMemoRepository();
    _dutyScheduleService ??= await DutyScheduleService.open();
    await _loadDuties();
  }

  Future<void> _initializeDDay() async {
    try {
      final service = _dDaySettingsService ?? await DDaySettingsService.open();
      final setting = service.load(today: _dDayToday);
      if (!mounted) return;
      setState(() {
        _dDaySettingsService = service;
        _dDaySetting = setting;
      });
    } on Object {
      // Local storage failures must not prevent the home screen from loading.
    }
  }

  Future<void> _loadDuties() async {
    final repository = _dutyRepository;
    if (repository == null) return;
    final duties = await repository.getForMonth(_dutyMonth);
    final schedules =
        _dutyScheduleService?.loadMonth(_dutyMonth) ??
        <String, DutyDaySchedule>{};
    if (!mounted) return;
    setState(() {
      _duties = duties;
      _dutySchedules = schedules;
    });
  }

  Future<void> _moveDutyMonth(int offset) async {
    setState(() {
      _dutyMonth = DateTime(_dutyMonth.year, _dutyMonth.month + offset);
      _duties = const {};
      _dutySchedules = const {};
    });
    await _loadDuties();
  }

  Future<void> _openDutyManager() async {
    final repository = _dutyRepository;
    if (repository == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DutyManageScreen(
          repository: repository,
          initialMonth: _dutyMonth,
          today: widget.dutyToday,
          scheduleService: _dutyScheduleService,
        ),
      ),
    );
    await _loadDuties();
  }

  Future<void> _editDutyDay(DateTime date) async {
    final repository = _dutyRepository;
    final scheduleService = _dutyScheduleService;
    if (repository == null ||
        scheduleService == null ||
        date.year != _dutyMonth.year ||
        date.month != _dutyMonth.month) {
      return;
    }
    final key = dutyDateKey(date);
    final result = await showDutyDaySheet(
      context: context,
      date: date,
      duty: _duties[key],
      schedule: _dutySchedules[key] ?? const DutyDaySchedule(),
    );
    if (result == null) return;
    if (result.duty == null) {
      await repository.delete(date);
    } else {
      await repository.save(date, result.duty!);
    }
    await scheduleService.save(date, result.schedule);
    await _loadDuties();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _comingSoon(String title, IconData icon) {
    _open(ComingSoonScreen(title: title, icon: icon));
  }

  void _openProfile() {
    _open(MyPageScreen(authService: widget.authService ?? CloudService.auth));
  }

  Future<void> _openDDaySettings() async {
    final service = _dDaySettingsService ?? await DDaySettingsService.open();
    if (!mounted) return;
    _dDaySettingsService = service;
    final setting = await Navigator.of(context).push<DDaySetting>(
      MaterialPageRoute<DDaySetting>(
        builder: (_) => DDaySettingScreen(
          initialSetting: _dDaySetting,
          settingsService: service,
          today: _dDayToday,
        ),
      ),
    );
    if (setting == null || !mounted) return;
    setState(() => _dDaySetting = setting);
  }

  Future<void> _openDrugSearch() async {
    if (!await launchUrl(kKpicDrugSearchUri, webOnlyWindowName: '_self') &&
        mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('약학정보원 페이지를 열지 못했습니다.')));
    }
  }

  Future<void> _openDiseaseEncyclopedia() async {
    final launcher =
        widget.diseaseUrlLauncher ??
        (uri, mode) => launchUrl(uri, mode: mode);
    if (!await launcher(
          kAsanDiseaseEncyclopediaUri,
          LaunchMode.externalApplication,
        ) &&
        mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('질환백과 페이지를 열지 못했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAFE),
      bottomNavigationBar: HomeBottomNavigation(
        onHome: () {},
        onCalculation: () => _open(const InfusionCalculatorScreen()),
        onRecords: () => _open(MemoListScreen(repository: _memoRepository)),
        onKnowledge: _openDrugSearch,
        onProfile: _openProfile,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: HomeHeader(
                      onNotifications: () =>
                          _comingSoon('알림', Icons.notifications_none_rounded),
                      onProfile: _openProfile,
                    ),
                  ),
                  const SizedBox(height: 28),
                  DutyCalendarCard(
                    month: _dutyMonth,
                    duties: _duties,
                    schedules: _dutySchedules,
                    today: widget.dutyToday,
                    onPreviousMonth: () => _moveDutyMonth(-1),
                    onNextMonth: () => _moveDutyMonth(1),
                    onManage: _openDutyManager,
                    onSettings: () =>
                        _comingSoon('듀티 설정', Icons.settings_outlined),
                    onDateTap: _editDutyDay,
                  ),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    icon: Icons.auto_awesome_rounded,
                    title: '주요 기능',
                  ),
                  const SizedBox(height: 18),
                  _FeatureGrid(
                    memoRepository: _memoRepository,
                    onDiseaseSearch: _openDiseaseEncyclopedia,
                    onOpen: _open,
                    onComingSoon: _comingSoon,
                  ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 720) {
                        return SizedBox(
                          height: 230,
                          child: HomeQuickSectionsWide(
                            onDropCalculation: () =>
                                _open(const InfusionSpeedCheckScreen()),
                            onCcPerHour: () =>
                                _open(const InfusionCalculatorScreen()),
                            onBmi: () => _comingSoon(
                              'BMI 계산',
                              Icons.monitor_weight_outlined,
                            ),
                            onOther: () =>
                                _comingSoon('기타 계산', Icons.grid_view_rounded),
                            dDaySetting: _dDaySetting,
                            dDayToday: _dDayToday,
                            onDDayTap: _openDDaySettings,
                          ),
                        );
                      }
                      return HomeQuickSections(
                        onDropCalculation: () =>
                            _open(const InfusionSpeedCheckScreen()),
                        onCcPerHour: () =>
                            _open(const InfusionCalculatorScreen()),
                        onBmi: () => _comingSoon(
                          'BMI 계산',
                          Icons.monitor_weight_outlined,
                        ),
                        onOther: () =>
                            _comingSoon('기타 계산', Icons.grid_view_rounded),
                        dDaySetting: _dDaySetting,
                        dDayToday: _dDayToday,
                        onDDayTap: _openDDaySettings,
                      );
                    },
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.memoRepository,
    required this.onDiseaseSearch,
    required this.onOpen,
    required this.onComingSoon,
  });

  final MemoRepository? memoRepository;
  final VoidCallback onDiseaseSearch;
  final ValueChanged<Widget> onOpen;
  final void Function(String, IconData) onComingSoon;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      HomeFeatureCard(
        key: const Key('infusionCalculatorMenu'),
        icon: Icons.bloodtype_outlined,
        secondaryIcon: Icons.water_drop_rounded,
        illustration: const HomeIllustration(column: 0, row: 0),
        title: '수액속도 계산',
        description: '수액, 주입 속도\n쉽고 빠르게 계산',
        background: const Color(0xFFF1FBFA),
        accent: const Color(0xFF24A994),
        onTap: () => onOpen(const InfusionCalculatorScreen()),
      ),
      HomeFeatureCard(
        key: const Key('drainagePatternMenu'),
        icon: Icons.water_outlined,
        secondaryIcon: Icons.medical_services_outlined,
        illustration: const HomeIllustration(column: 1, row: 0),
        title: '배액양상',
        description: '배액의 특성 및 관리\n기록을 도와드려요',
        background: const Color(0xFFF1F7FF),
        accent: const Color(0xFF438DDD),
        onTap: () => onOpen(const AppearanceScreen()),
      ),
      HomeFeatureCard(
        key: const Key('dutyChecklistMenu'),
        icon: Icons.assignment_turned_in_outlined,
        illustration: const HomeIllustration(column: 2, row: 0),
        title: '듀티별 체크리스트',
        description: '듀티에 맞는 중요한\n업무를 챙겨보세요',
        background: const Color(0xFFF7F3FF),
        accent: const Color(0xFF7952CE),
        onTap: () => onOpen(const ChecklistHomeScreen()),
      ),
      Link(
        uri: kKpicDrugSearchUri,
        target: LinkTarget.self,
        builder: (context, followLink) => HomeFeatureCard(
          key: const Key('drugSearchMenu'),
          icon: Icons.medication_outlined,
          secondaryIcon: Icons.circle_outlined,
          illustration: const HomeIllustration(column: 0, row: 1),
          title: '약 검색',
          description: '약물 정보, 효능, 용법을\n빠르게 검색',
          background: const Color(0xFFFFF2F6),
          accent: const Color(0xFFF04478),
          onTap:
              followLink ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('약학정보원 페이지를 열지 못했습니다.')),
                );
              },
        ),
      ),
      HomeFeatureCard(
        key: const Key('diseaseSearchMenu'),
        icon: Icons.menu_book_outlined,
        secondaryIcon: Icons.search_rounded,
        illustration: const HomeIllustration(column: 1, row: 1),
        title: '질환별 검색',
        description: '질환 정보와 간호 중재를\n한눈에 확인',
        background: const Color(0xFFFFF8EC),
        accent: const Color(0xFFF3A32F),
        onTap: onDiseaseSearch,
      ),
      HomeFeatureCard(
        key: const Key('memoMenu'),
        icon: Icons.edit_note_rounded,
        illustration: const HomeIllustration(column: 2, row: 1),
        title: '메모장',
        description: '간호 중 필요한 내용을\n자유롭게 메모',
        background: const Color(0xFFF0FAFC),
        accent: const Color(0xFF25A5AE),
        onTap: () => onOpen(MemoListScreen(repository: memoRepository)),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 350 ? 3 : 2;
        final ratio = constraints.maxWidth >= 760 ? 0.88 : 0.70;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7564D4), size: 26),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF242539),
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}
