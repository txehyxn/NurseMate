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
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
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
                flex: 5,
                child: Center(
                  child: _FeatureIllustration(
                    icon: icon,
                    secondaryIcon: secondaryIcon,
                    accent: accent,
                    illustration: illustration,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF67697A),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 38,
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
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureIllustration extends StatelessWidget {
  const _FeatureIllustration({
    required this.icon,
    required this.secondaryIcon,
    required this.accent,
    required this.illustration,
  });

  final IconData icon;
  final IconData? secondaryIcon;
  final Color accent;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    if (illustration != null) {
      return SizedBox(width: 106, height: 96, child: illustration);
    }
    return SizedBox(
      width: 96,
      height: 88,
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
          Icon(icon, color: accent, size: 66),
          if (secondaryIcon != null)
            Positioned(
              right: 4,
              bottom: 3,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
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
