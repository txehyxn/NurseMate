import 'package:flutter/material.dart';

import '../design_system/nursemate_tokens.dart';

Future<void> showAppearanceDetailSheet({
  required BuildContext context,
  required String koreanName,
  required String englishName,
  required String colorDescription,
  required String characteristics,
  required List<String> causes,
  required List<String> nursingInterventions,
  required Color topColor,
  required Color bottomColor,
  required Color borderColor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: NurseMateColors.navy.withValues(alpha: 0.28),
    builder: (context) => AppearanceDetailSheet(
      koreanName: koreanName,
      englishName: englishName,
      colorDescription: colorDescription,
      characteristics: characteristics,
      causes: causes,
      nursingInterventions: nursingInterventions,
      topColor: topColor,
      bottomColor: bottomColor,
      borderColor: borderColor,
    ),
  );
}

class AppearanceDetailSheet extends StatelessWidget {
  const AppearanceDetailSheet({
    super.key,
    required this.koreanName,
    required this.englishName,
    required this.colorDescription,
    required this.characteristics,
    required this.causes,
    required this.nursingInterventions,
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
  });

  final String koreanName;
  final String englishName;
  final String colorDescription;
  final String characteristics;
  final List<String> causes;
  final List<String> nursingInterventions;
  final Color topColor;
  final Color bottomColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      snap: true,
      snapSizes: const [0.82, 0.94],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: NurseMateColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(NurseMateRadii.panel),
            ),
            boxShadow: NurseMateShadows.floating,
          ),
          child: Column(
            children: [
              const SizedBox(height: NurseMateSpacing.sm),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: NurseMateColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: ListView(
                  key: const Key('appearanceDetailScrollView'),
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    NurseMateSpacing.page,
                    NurseMateSpacing.md,
                    NurseMateSpacing.page,
                    NurseMateSpacing.xl,
                  ),
                  children: [
                    _DetailHeader(
                      koreanName: koreanName,
                      englishName: englishName,
                      topColor: topColor,
                      bottomColor: bottomColor,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: NurseMateSpacing.lg),
                    _SummaryPanel(
                      colorDescription: colorDescription,
                      characteristics: characteristics,
                      topColor: topColor,
                      bottomColor: bottomColor,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: NurseMateSpacing.md),
                    _DetailListSection(
                      icon: Icons.search_rounded,
                      title: '주요 원인',
                      items: causes,
                    ),
                    const SizedBox(height: NurseMateSpacing.md),
                    _DetailListSection(
                      icon: Icons.health_and_safety_outlined,
                      title: '간호 중재',
                      items: nursingInterventions,
                      emphasized: true,
                    ),
                    const SizedBox(height: NurseMateSpacing.md),
                    const _SafetyNote(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.koreanName,
    required this.englishName,
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
  });

  final String koreanName;
  final String englishName;
  final Color topColor;
  final Color bottomColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ColorSwatch(
          size: 62,
          topColor: topColor,
          bottomColor: bottomColor,
          borderColor: borderColor,
          icon: Icons.water_drop_rounded,
        ),
        const SizedBox(width: NurseMateSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                koreanName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: NurseMateSpacing.xxs),
              Text(
                englishName,
                style: const TextStyle(
                  color: NurseMateColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: NurseMateSpacing.sm),
        Semantics(
          button: true,
          label: '상세 닫기',
          child: Material(
            color: NurseMateColors.surface,
            shape: const CircleBorder(
              side: BorderSide(color: NurseMateColors.border),
            ),
            child: InkWell(
              key: const Key('appearanceDetailCloseButton'),
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.close_rounded,
                  color: NurseMateColors.textSecondary,
                  size: 23,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.colorDescription,
    required this.characteristics,
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
  });

  final String colorDescription;
  final String characteristics;
  final Color topColor;
  final Color bottomColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      decoration: BoxDecoration(
        color: NurseMateColors.surface,
        borderRadius: BorderRadius.circular(NurseMateRadii.card),
        border: Border.all(color: NurseMateColors.border),
        boxShadow: NurseMateShadows.card,
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: '색상',
            child: Row(
              children: [
                _ColorSwatch(
                  size: 28,
                  topColor: topColor,
                  bottomColor: bottomColor,
                  borderColor: borderColor,
                ),
                const SizedBox(width: NurseMateSpacing.sm),
                Expanded(
                  child: Text(
                    colorDescription,
                    style: const TextStyle(
                      color: NurseMateColors.navy,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: NurseMateSpacing.md),
            child: Divider(height: 1, color: NurseMateColors.divider),
          ),
          _SummaryRow(
            label: '특징',
            child: Text(
              characteristics,
              style: const TextStyle(
                color: NurseMateColors.text,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              color: NurseMateColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _DetailListSection extends StatelessWidget {
  const _DetailListSection({
    required this.icon,
    required this.title,
    required this.items,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final accent = emphasized ? NurseMateColors.mint : NurseMateColors.primary;
    final background = emphasized
        ? NurseMateColors.mintSoft
        : NurseMateColors.primarySoft;
    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      decoration: BoxDecoration(
        color: NurseMateColors.surface,
        borderRadius: BorderRadius.circular(NurseMateRadii.card),
        border: Border.all(color: NurseMateColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(NurseMateRadii.small),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: NurseMateSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  color: NurseMateColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: NurseMateSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: NurseMateSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: NurseMateSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: NurseMateColors.text,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.md),
      decoration: BoxDecoration(
        color: NurseMateColors.surfaceMuted,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: NurseMateColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: NurseMateColors.textSecondary,
            size: 20,
          ),
          SizedBox(width: NurseMateSpacing.sm),
          Expanded(
            child: Text(
              '환자의 수술 종류와 처방, 기관 지침을 우선하며 갑작스러운 양상 또는 배액량 변화는 의료진에게 보고하세요.',
              style: TextStyle(
                color: NurseMateColors.textSecondary,
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.size,
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
    this.icon,
  });

  final double size;
  final Color topColor;
  final Color bottomColor;
  final Color borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [topColor, bottomColor],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F5D4DB2),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: icon == null
          ? null
          : Icon(icon, color: _foregroundFor(bottomColor), size: size * 0.48),
    );
  }

  Color _foregroundFor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white.withValues(alpha: 0.92)
        : NurseMateColors.navy.withValues(alpha: 0.7);
  }
}
