import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';

class QuickMenuPlaceholderScreen extends StatelessWidget {
  const QuickMenuPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NurseMateSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: isDark
                          ? NurseMateColors.primary.withValues(alpha: 0.18)
                          : NurseMateColors.primarySoft,
                      shape: BoxShape.circle,
                      boxShadow: isDark
                          ? const <BoxShadow>[]
                          : NurseMateShadows.card,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 54, color: NurseMateColors.primary),
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: NurseMateSpacing.sm),
                  Text(
                    '준비 중입니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: NurseMateSpacing.xs),
                  Text(
                    '추후 업데이트될 기능입니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
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
