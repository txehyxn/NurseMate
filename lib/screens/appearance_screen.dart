import 'package:flutter/material.dart';

import '../data/urine_data.dart';
import '../design_system/nursemate_tokens.dart';
import '../models/appearance_model.dart';
import 'appearance_detail_sheet.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _showsUrine = false;

  static const _appearances = <AppearanceItem>[
    AppearanceItem(
      id: 'serous',
      englishName: 'serous',
      koreanName: '장액성',
      description: '맑은 노란색 양상',
      colorDescription: '맑고 투명한 연노란색',
      causes: ['수술 후 정상적인 염증·회복 과정', '조직액 또는 장액의 배출', '장액종의 배액'],
      nursingInterventions: [
        '배액량, 색, 투명도와 냄새의 변화 추이를 기록해요.',
        '배액관의 꺾임, 막힘, 음압 유지 상태를 확인해요.',
        '갑작스러운 증가·감소 또는 혼탁해지는 변화는 보고해요.',
      ],
      topColor: Color(0xFFFFF4A3),
      bottomColor: Color(0xFFFFD638),
      borderColor: Color(0xFFFFD334),
    ),
    AppearanceItem(
      id: 'serosanguineous',
      englishName: 'serosanguineous',
      koreanName: '장액혈성',
      description: '노란빛에 연한 붉은빛이\n섞인 양상',
      colorDescription: '옅은 분홍색 또는 주황빛',
      causes: ['수술 직후 장액과 소량의 혈액이 섞임', '미세혈관의 경미한 출혈', '상처 회복 초기 단계'],
      nursingInterventions: [
        '시간대별 배액량과 색이 점차 옅어지는지 관찰해요.',
        '삽입 부위 출혈과 혈종, 통증 증가 여부를 확인해요.',
        '선홍색으로 진해지거나 배액량이 증가하면 즉시 보고해요.',
      ],
      topColor: Color(0xFFFFD49A),
      bottomColor: Color(0xFFFF9C4A),
      borderColor: Color(0xFFFF9A3C),
    ),
    AppearanceItem(
      id: 'sanguineous',
      englishName: 'sanguineous',
      koreanName: '혈성',
      description: '선홍빛 또는\n붉은빛 양상',
      colorDescription: '붉은색 또는 선홍색',
      causes: ['수술 직후의 혈액 배출', '수술 부위 또는 혈관의 출혈', '배액관에 의한 조직 자극'],
      nursingInterventions: [
        '활력징후와 출혈 증상, 배액량을 함께 확인해요.',
        '응고물로 인한 막힘과 배액관 연결 상태를 확인해요.',
        '선홍색 배액의 지속·증가나 혈압 저하가 있으면 즉시 보고해요.',
      ],
      topColor: Color(0xFFFFA29D),
      bottomColor: Color(0xFFFF5857),
      borderColor: Color(0xFFFF625E),
    ),
    AppearanceItem(
      id: 'bloody',
      englishName: 'bloody',
      koreanName: '혈액성',
      description: '혈액이 보이는\n붉은 색 양상',
      colorDescription: '혈액이 뚜렷한 진한 붉은색',
      causes: ['수술 부위의 지속적인 출혈', '혈종의 배출', '배액관 또는 주변 조직의 손상'],
      nursingInterventions: [
        '배액량을 짧은 간격으로 확인하고 누적량을 기록해요.',
        '창백, 빈맥, 저혈압, 식은땀 등 출혈 징후를 사정해요.',
        '갑작스러운 혈액성 배액은 즉시 의료진에게 보고해요.',
      ],
      topColor: Color(0xFFDA4042),
      bottomColor: Color(0xFFC41422),
      borderColor: Color(0xFFBB1420),
    ),
    AppearanceItem(
      id: 'fresh-bloody',
      englishName: 'fresh bloody',
      koreanName: '선홍 혈성',
      description: '새빨간 혈액 양상',
      colorDescription: '밝고 선명한 새빨간색',
      causes: ['활동성 출혈', '혈관 손상 또는 결찰 부위 출혈', '문합부 또는 수술 부위 출혈'],
      nursingInterventions: [
        '활력징후와 의식, 피부 상태를 즉시 확인해요.',
        '시간당 배액량과 갑작스러운 증가 여부를 확인해요.',
        '배액관을 임의로 잠그지 말고 즉시 의료진에게 보고해요.',
      ],
      topColor: Color(0xFFFF5550),
      bottomColor: Color(0xFFFF1718),
      borderColor: Color(0xFFFF2020),
    ),
    AppearanceItem(
      id: 'dark-old-bloody',
      englishName: 'dark(old) bloody',
      koreanName: '오래된 혈성',
      description: '검붉은 혈액 양상',
      colorDescription: '검붉은색 또는 암적색',
      causes: [
        '기존 혈종 또는 고여 있던 혈액의 배출',
        '수술 후 오래된 혈액의 배액',
        '응고된 혈액이 서서히 녹아 배출됨',
      ],
      nursingInterventions: [
        '색과 점도, 응고물 유무 및 배액량 추이를 기록해요.',
        '배액관이 응고물로 막히지 않았는지 확인해요.',
        '악취, 발열, 통증 증가나 선홍색 변화가 있으면 보고해요.',
      ],
      topColor: Color(0xFFB84C4C),
      bottomColor: Color(0xFF861F25),
      borderColor: Color(0xFF85252A),
    ),
    AppearanceItem(
      id: 'brownish',
      englishName: 'brownish',
      koreanName: '갈색 양상',
      description: '갈색빛 배액',
      colorDescription: '갈색 또는 탁한 황갈색',
      causes: ['오래된 혈액 또는 조직 잔여물', '괴사 조직이 섞인 배액', '감염성 또는 장 내용물 혼입 가능성'],
      nursingInterventions: [
        '탁도, 냄새, 점도와 배액량을 함께 관찰해요.',
        '발열, 발적, 압통 등 감염 징후를 확인해요.',
        '새롭게 나타난 갈색·악취성 배액은 의료진에게 보고해요.',
      ],
      topColor: Color(0xFFC2763D),
      bottomColor: Color(0xFF9B4617),
      borderColor: Color(0xFF914116),
    ),
    AppearanceItem(
      id: 'chyle',
      englishName: 'chyle',
      koreanName: '유미',
      description: '우유빛 양상\n(림프관 손상 시 유미액 누출)',
      colorDescription: '우유처럼 뿌연 흰색 또는 크림색',
      causes: ['흉관 또는 주요 림프관 손상', '경부·흉부·복부 림프절 수술 후 누출', '식이 재개 후 증가하는 유미 누출'],
      nursingInterventions: [
        '식이 전후 배액량과 유백색 변화 여부를 기록해요.',
        '체액 균형, 전해질 및 영양 상태를 관찰해요.',
        '유미 누출이 의심되면 임의로 식이를 변경하지 말고 보고해요.',
      ],
      topColor: Color(0xFFFFFFFF),
      bottomColor: Color(0xFFF2F2F2),
      borderColor: Color(0xFFDEDEDE),
    ),
    AppearanceItem(
      id: 'bile',
      englishName: 'bile',
      koreanName: '담즙',
      description: '녹색 배액 양상\n(PTGBD·PTBD 또는\n간담췌 수술 후 leakage 시)',
      colorDescription: '황록색, 녹색 또는 갈색의 담즙색',
      causes: ['담도 배액관을 통한 정상 담즙 배출', '간·담낭·담도 수술 후 담즙 누출', '담도 손상 또는 문합부 누출'],
      nursingInterventions: [
        '배액량과 색을 기록하고 배액관 위치·개방성을 확인해요.',
        '복통, 발열, 황달, 삽입 부위 누출 여부를 관찰해요.',
        '배액의 급격한 증감, 관 이탈 또는 전신 증상은 즉시 보고해요.',
      ],
      topColor: Color(0xFF76B54A),
      bottomColor: Color(0xFF4F8E27),
      borderColor: Color(0xFF4B8725),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: const _AppearanceBottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AppearanceHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  NurseMateSpacing.page,
                  8,
                  NurseMateSpacing.page,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AppearanceTabs(
                          showsUrine: _showsUrine,
                          onUrineSelected: () {
                            if (_showsUrine) return;
                            setState(() => _showsUrine = true);
                          },
                          onDrainageSelected: () {
                            if (!_showsUrine) return;
                            setState(() => _showsUrine = false);
                          },
                        ),
                        const SizedBox(height: 16),
                        AnimatedSize(
                          duration: NurseMateMotion.standard,
                          curve: NurseMateMotion.curve,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: NurseMateMotion.standard,
                            switchInCurve: NurseMateMotion.curve,
                            switchOutCurve: NurseMateMotion.curve,
                            transitionBuilder: (child, animation) {
                              final offset = Tween<Offset>(
                                begin: const Offset(0, 0.018),
                                end: Offset.zero,
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offset,
                                  child: child,
                                ),
                              );
                            },
                            child: _AppearanceContent(
                              key: ValueKey(_showsUrine),
                              showsUrine: _showsUrine,
                              items: _showsUrine
                                  ? urineAppearances
                                  : _appearances,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _ReferenceCard(),
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

class _AppearanceContent extends StatelessWidget {
  const _AppearanceContent({
    super.key,
    required this.showsUrine,
    required this.items,
  });

  final bool showsUrine;
  final List<AppearanceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GuideCard(showsUrine: showsUrine),
        const SizedBox(height: 20),
        _SectionTitle(showsUrine: showsUrine),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final cardWidth = (constraints.maxWidth - spacing * 2) / 3;
            final ratio = cardWidth > 190 ? 1.08 : 0.88;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: ratio,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _AppearanceTile(
                  item: item,
                  onTap: () => showAppearanceDetailSheet(
                    context: context,
                    koreanName: item.koreanName,
                    englishName: item.englishName,
                    colorDescription: item.colorDescription,
                    characteristics: item.description.replaceAll('\n', ' '),
                    causes: item.causes,
                    nursingInterventions: item.nursingInterventions,
                    topColor: item.topColor,
                    bottomColor: item.bottomColor,
                    borderColor: item.borderColor,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AppearanceHeader extends StatelessWidget {
  const _AppearanceHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 8,
            top: 14,
            child: IconButton(
              key: const Key('appearanceBackButton'),
              tooltip: '뒤로 가기',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: NurseMateColors.primary,
                size: 24,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '배액 양상',
                      style: TextStyle(
                        color: NurseMateColors.navy,
                        fontSize: 25,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(width: 10),
                    _MedicalHeartIcon(),
                  ],
                ),
                SizedBox(height: 7),
                Text(
                  '배액의 색, 상태를 확인해요',
                  style: TextStyle(
                    color: NurseMateColors.textSecondary,
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceTabs extends StatelessWidget {
  const _AppearanceTabs({
    required this.showsUrine,
    required this.onUrineSelected,
    required this.onDrainageSelected,
  });

  final bool showsUrine;
  final VoidCallback onUrineSelected;
  final VoidCallback onDrainageSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFF),
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: const Color(0xFFE5E1F7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AppearanceTab(
              key: const Key('urineAppearanceTab'),
              icon: Icons.water_drop_outlined,
              label: '소변 양상',
              selected: showsUrine,
              onTap: onUrineSelected,
            ),
          ),
          Expanded(
            child: _AppearanceTab(
              key: const Key('drainageAppearanceTab'),
              label: '배액관 양상',
              selected: !showsUrine,
              useDrainIcon: true,
              onTap: onDrainageSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceTab extends StatelessWidget {
  const _AppearanceTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.useDrainIcon = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool useDrainIcon;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? NurseMateColors.primary
        : NurseMateColors.textTertiary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: NurseMateMotion.standard,
        curve: NurseMateMotion.curve,
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? NurseMateColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
          border: Border.all(
            color: selected ? const Color(0xFF9B8AF2) : Colors.transparent,
            width: 1.35,
          ),
          boxShadow: selected ? NurseMateShadows.floating : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NurseMateRadii.input),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (useDrainIcon)
                  _DrainTubeIcon(
                    size: 29,
                    color: selected ? const Color(0xFF7462D6) : color,
                  )
                else
                  Icon(icon, size: 27, color: color),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.showsUrine});

  final bool showsUrine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFF),
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: const Color(0xFFEAE7F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: NurseMateColors.primary,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                '안내',
                style: TextStyle(
                  color: NurseMateColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.only(left: 27),
            child: Text(
              showsUrine
                  ? '소변의 색과 상태, 배뇨량을 함께 관찰하고,\n이상 소견이 있으면 의료진에게 보고하세요.'
                  : '배액의 색과 상태를 관찰하여 환자 상태를 평가하고,\n이상 소견이 있으면 의료진에게 보고하세요.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: NurseMateColors.text,
                fontSize: 14,
                height: 1.6,
                letterSpacing: -0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.showsUrine});

  final bool showsUrine;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showsUrine)
          const Icon(
            Icons.water_drop_outlined,
            color: NurseMateColors.primary,
            size: 27,
          )
        else
          const _DrainTubeIcon(size: 27),
        const SizedBox(width: 9),
        Text(
          showsUrine ? '소변 양상' : '배액관 양상',
          style: const TextStyle(
            color: NurseMateColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile({required this.item, required this.onTap});

  final AppearanceItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 150;
        final decoration = BoxDecoration(
          color: NurseMateColors.surface,
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
          border: Border.all(color: const Color(0xFFE8E6F3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x075D4DB2),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        );
        return Semantics(
          button: true,
          label: '${item.koreanName} 상세 보기',
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: decoration,
              child: InkWell(
                key: Key('appearanceCard-${item.id}'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(NurseMateRadii.input),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 3 : 8,
                    compact ? 8 : 12,
                    compact ? 3 : 8,
                    compact ? 6 : 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Droplet(
                        topColor: item.topColor,
                        bottomColor: item.bottomColor,
                        borderColor: item.borderColor,
                        size: compact ? const Size(28, 36) : const Size(37, 48),
                      ),
                      SizedBox(height: compact ? 5 : 7),
                      Text(
                        item.englishName,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NurseMateColors.primary,
                          fontSize: compact ? 10.5 : 15,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.25,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 5),
                      Text(
                        item.koreanName,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NurseMateColors.navy,
                          fontSize: compact ? 11.5 : 16,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.45,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        item.description,
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NurseMateColors.textSecondary,
                          fontSize: compact ? 8.5 : 12.5,
                          height: compact ? 1.3 : 1.42,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFF),
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: const Color(0xFFE8E5F7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF8274DD), size: 23),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '참고',
                  style: TextStyle(
                    color: NurseMateColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '배액 양상은 수술 부위, 감염 여부, 출혈 상태 등에 따라 달라질 수 있어요.',
                  style: TextStyle(
                    color: NurseMateColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceBottomNavigation extends StatelessWidget {
  const _AppearanceBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: NurseMateColors.surface,
          border: Border(top: BorderSide(color: NurseMateColors.divider)),
        ),
        child: Row(
          children: const [
            _BottomNavigationItem(icon: Icons.home_outlined, label: '홈'),
            _BottomNavigationItem(icon: Icons.calculate_outlined, label: '계산'),
            _BottomNavigationItem(icon: Icons.assignment_outlined, label: '기록'),
            _BottomNavigationItem(
              icon: Icons.auto_stories_rounded,
              label: '지식',
              selected: true,
            ),
            _BottomNavigationItem(
              icon: Icons.person_outline_rounded,
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? NurseMateColors.primary
        : NurseMateColors.textSecondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        label: label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? NurseMateColors.primarySoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(NurseMateRadii.input),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 25, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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

class _MedicalHeartIcon extends StatelessWidget {
  const _MedicalHeartIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 31,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.favorite_border_rounded,
              size: 30,
              color: NurseMateColors.primary,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              color: NurseMateColors.background,
              child: const Icon(
                Icons.add_rounded,
                size: 19,
                color: NurseMateColors.primary,
                weight: 800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrainTubeIcon extends StatelessWidget {
  const _DrainTubeIcon({
    required this.size,
    this.color = const Color(0xFF7462D6),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DrainTubePainter(color),
    );
  }
}

class _DrainTubePainter extends CustomPainter {
  const _DrainTubePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .072
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * .08, size.height * .38)
      ..cubicTo(
        size.width * .17,
        size.height * .18,
        size.width * .43,
        size.height * .16,
        size.width * .48,
        size.height * .38,
      )
      ..lineTo(size.width * .48, size.height * .71)
      ..cubicTo(
        size.width * .48,
        size.height * .9,
        size.width * .69,
        size.height * .92,
        size.width * .86,
        size.height * .92,
      );
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(size.width * .04, size.height * .31),
      Offset(size.width * .15, size.height * .31),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .04, size.height * .45),
      Offset(size.width * .15, size.height * .45),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DrainTubePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _Droplet extends StatelessWidget {
  const _Droplet({
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
    required this.size,
  });

  final Color topColor;
  final Color bottomColor;
  final Color borderColor;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _DropletPainter(
        topColor: topColor,
        bottomColor: bottomColor,
        borderColor: borderColor,
      ),
    );
  }
}

class _DropletPainter extends CustomPainter {
  const _DropletPainter({
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
  });

  final Color topColor;
  final Color bottomColor;
  final Color borderColor;

  Path _path(Size size) {
    return Path()
      ..moveTo(size.width / 2, 1)
      ..cubicTo(
        size.width * .42,
        size.height * .18,
        size.width * .08,
        size.height * .56,
        size.width * .08,
        size.height * .72,
      )
      ..cubicTo(
        size.width * .08,
        size.height * .94,
        size.width * .27,
        size.height,
        size.width / 2,
        size.height,
      )
      ..cubicTo(
        size.width * .73,
        size.height,
        size.width * .92,
        size.height * .94,
        size.width * .92,
        size.height * .72,
      )
      ..cubicTo(
        size.width * .92,
        size.height * .56,
        size.width * .58,
        size.height * .18,
        size.width / 2,
        1,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [topColor, bottomColor],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomColor != bottomColor ||
        oldDelegate.borderColor != borderColor;
  }
}
