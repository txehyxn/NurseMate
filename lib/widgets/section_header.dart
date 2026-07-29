import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return NurseMateSectionTitle(title: title, icon: icon);
  }
}
