import 'package:flutter/material.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.background,
    required this.accent,
    required this.onTap,
    this.secondaryIcon,
    this.illustration,
  });

  final IconData icon;
  final IconData? secondaryIcon;
  final Widget? illustration;
  final String title;
  final String description;
  final Color background;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 170;
        final theme = Theme.of(context);
        final cardBackground = theme.brightness == Brightness.dark
            ? Color.alphaBlend(
                accent.withValues(alpha: 0.10),
                theme.colorScheme.surface,
              )
            : background;
        return Material(
          color: cardBackground,
          borderRadius: BorderRadius.circular(compact ? 20 : 26),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(compact ? 20 : 26),
            child: Container(
              padding: compact
                  ? const EdgeInsets.fromLTRB(8, 10, 8, 10)
                  : const EdgeInsets.fromLTRB(18, 22, 18, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(compact ? 20 : 26),
                border: Border.all(color: accent.withValues(alpha: 0.10)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A3E3568),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: compact ? 4 : 5,
                    child: Center(
                      child: _FeatureIllustration(
                        icon: icon,
                        secondaryIcon: secondaryIcon,
                        accent: accent,
                        illustration: illustration,
                        compact: compact,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: compact ? 13 : 18,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? -0.4 : -0.6,
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  Expanded(
                    flex: compact ? 2 : 3,
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onSurfaceVariant
                            : const Color(0xFF67697A),
                        fontSize: compact ? 9.5 : 13,
                        height: compact ? 1.3 : 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 5 : 10),
                  Container(
                    width: compact ? 28 : 38,
                    height: compact ? 28 : 38,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.24),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: compact ? 19 : 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureIllustration extends StatelessWidget {
  const _FeatureIllustration({
    required this.icon,
    required this.secondaryIcon,
    required this.accent,
    required this.illustration,
    required this.compact,
  });

  final IconData icon;
  final IconData? secondaryIcon;
  final Color accent;
  final Widget? illustration;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (illustration != null) {
      return SizedBox(
        width: compact ? 66 : 106,
        height: compact ? 60 : 96,
        child: illustration,
      );
    }
    return SizedBox(
      width: compact ? 62 : 96,
      height: compact ? 56 : 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 3,
            right: 4,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 5,
            bottom: 4,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Icon(icon, color: accent, size: compact ? 44 : 66),
          if (secondaryIcon != null)
            Positioned(
              right: 4,
              bottom: 3,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Icon(secondaryIcon, color: accent, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
