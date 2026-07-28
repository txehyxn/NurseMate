import 'package:flutter/material.dart';

import 'nursemate_tokens.dart';

class NurseMateCard extends StatelessWidget {
  const NurseMateCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NurseMateSpacing.xl),
    this.backgroundColor = NurseMateColors.surface,
    this.radius = NurseMateRadii.card,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: NurseMateColors.border),
      boxShadow: NurseMateShadows.card,
    );
    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class NurseMatePrimaryButton extends StatelessWidget {
  const NurseMatePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NurseMateColors.blue, Color(0xFF7B61F2)],
        ),
        borderRadius: BorderRadius.circular(NurseMateRadii.button),
        boxShadow: NurseMateShadows.floating,
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(label),
      ),
    );
    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

class NurseMateSectionTitle extends StatelessWidget {
  const NurseMateSectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: NurseMateColors.primary, size: 25),
          const SizedBox(width: NurseMateSpacing.sm),
        ],
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    );
  }
}

class NurseMateTextField extends StatelessWidget {
  const NurseMateTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.suffixText,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: NurseMateColors.navy,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        errorText: errorText,
      ),
    );
  }
}

class NurseMateInfoCard extends StatelessWidget {
  const NurseMateInfoCard({
    super.key,
    required this.child,
    this.icon = Icons.info_outline_rounded,
    this.accent = NurseMateColors.blue,
    this.background = NurseMateColors.blueSoft,
  });

  final Widget child;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: NurseMateSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class NurseMatePageHeader extends StatelessWidget {
  const NurseMatePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: NurseMateSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: NurseMateSpacing.xs),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: NurseMateSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
