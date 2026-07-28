import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.onHome,
    required this.onCalculation,
    required this.onRecords,
    required this.onKnowledge,
    required this.onProfile,
  });

  final VoidCallback onHome;
  final VoidCallback onCalculation;
  final VoidCallback onRecords;
  final VoidCallback onKnowledge;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0EFF6))),
          boxShadow: [
            BoxShadow(
              color: Color(0x125D4DB2),
              blurRadius: 22,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Row(
              children: [
                Expanded(
                  child: _BottomItem(
                    icon: Icons.home_rounded,
                    label: '홈',
                    selected: true,
                    onTap: onHome,
                  ),
                ),
                Expanded(
                  child: _BottomItem(
                    icon: Icons.calculate_outlined,
                    label: '계산',
                    onTap: onCalculation,
                  ),
                ),
                Expanded(
                  child: _BottomItem(
                    icon: Icons.assignment_outlined,
                    label: '기록',
                    onTap: onRecords,
                  ),
                ),
                Expanded(
                  child: _BottomItem(
                    icon: Icons.auto_stories_outlined,
                    label: '지식',
                    onTap: onKnowledge,
                  ),
                ),
                Expanded(
                  child: _BottomItem(
                    icon: Icons.person_outline_rounded,
                    label: '마이',
                    onTap: onProfile,
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

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF6554C0) : const Color(0xFF77788A);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF2EFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
