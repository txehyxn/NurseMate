import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import '../repositories/memo_repository.dart';
import '../widgets/home/duty_calendar_card.dart';
import '../widgets/home/home_bottom_navigation.dart';
import '../widgets/home/home_feature_card.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_illustration.dart';
import '../widgets/home/home_quick_sections.dart';
import 'coming_soon_screen.dart';
import 'infusion_calculator_screen.dart';
import 'infusion_speed_check_screen.dart';
import 'memo_list_screen.dart';

final Uri kKpicDrugSearchUri = Uri.parse(
  'https://health.kr/searchDrug/search_detail.asp',
);

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, this.memoRepository});

  final MemoRepository? memoRepository;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _comingSoon(BuildContext context, String title, IconData icon) {
    _open(context, ComingSoonScreen(title: title, icon: icon));
  }

  Future<void> _openDrugSearch(BuildContext context) async {
    if (!await launchUrl(kKpicDrugSearchUri, webOnlyWindowName: '_self') &&
        context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('약학정보원 페이지를 열지 못했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAFE),
      bottomNavigationBar: HomeBottomNavigation(
        onHome: () {},
        onCalculation: () => _open(context, const InfusionCalculatorScreen()),
        onRecords: () =>
            _open(context, MemoListScreen(repository: memoRepository)),
        onKnowledge: () => _openDrugSearch(context),
        onProfile: () =>
            _comingSoon(context, '마이', Icons.person_outline_rounded),
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
                      onNotifications: () => _comingSoon(
                        context,
                        '알림',
                        Icons.notifications_none_rounded,
                      ),
                      onProfile: () => _comingSoon(
                        context,
                        '마이',
                        Icons.person_outline_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  DutyCalendarCard(
                    onManage: () => _comingSoon(
                      context,
                      '내 듀티 관리',
                      Icons.calendar_month_rounded,
                    ),
                    onSettings: () =>
                        _comingSoon(context, '듀티 설정', Icons.settings_outlined),
                  ),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    icon: Icons.auto_awesome_rounded,
                    title: '주요 기능',
                  ),
                  const SizedBox(height: 18),
                  _FeatureGrid(
                    memoRepository: memoRepository,
                    onOpen: (screen) => _open(context, screen),
                    onComingSoon: (title, icon) =>
                        _comingSoon(context, title, icon),
                  ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 720) {
                        return SizedBox(
                          height: 230,
                          child: HomeQuickSectionsWide(
                            onDropCalculation: () => _open(
                              context,
                              const InfusionSpeedCheckScreen(),
                            ),
                            onCcPerHour: () => _open(
                              context,
                              const InfusionCalculatorScreen(),
                            ),
                            onBmi: () => _comingSoon(
                              context,
                              'BMI 계산',
                              Icons.monitor_weight_outlined,
                            ),
                            onOther: () => _comingSoon(
                              context,
                              '기타 계산',
                              Icons.grid_view_rounded,
                            ),
                          ),
                        );
                      }
                      return HomeQuickSections(
                        onDropCalculation: () =>
                            _open(context, const InfusionSpeedCheckScreen()),
                        onCcPerHour: () =>
                            _open(context, const InfusionCalculatorScreen()),
                        onBmi: () => _comingSoon(
                          context,
                          'BMI 계산',
                          Icons.monitor_weight_outlined,
                        ),
                        onOther: () => _comingSoon(
                          context,
                          '기타 계산',
                          Icons.grid_view_rounded,
                        ),
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
    required this.onOpen,
    required this.onComingSoon,
  });

  final MemoRepository? memoRepository;
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
        onTap: () => onComingSoon('배액양상', Icons.water_outlined),
      ),
      HomeFeatureCard(
        key: const Key('dutyChecklistMenu'),
        icon: Icons.assignment_turned_in_outlined,
        illustration: const HomeIllustration(column: 2, row: 0),
        title: '듀티별 체크리스트',
        description: '듀티에 맞는 중요한\n업무를 챙겨보세요',
        background: const Color(0xFFF7F3FF),
        accent: const Color(0xFF7952CE),
        onTap: () =>
            onComingSoon('듀티별 체크리스트', Icons.assignment_turned_in_outlined),
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
        onTap: () => onComingSoon('질환별 검색', Icons.menu_book_outlined),
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
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        final ratio = columns == 3 ? 0.88 : 0.72;
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
