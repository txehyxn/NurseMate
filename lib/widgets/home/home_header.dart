import 'package:flutter/material.dart';

import 'home_illustration.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onNotifications,
    required this.onProfile,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _HeartLogo(),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NurseMate',
                style: TextStyle(
                  color: Color(0xFF6554C0),
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '간호사의 하루를 더 쉽게',
                style: TextStyle(
                  color: Color(0xFF74758A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: '알림',
              onPressed: onNotifications,
              iconSize: 29,
              color: const Color(0xFF4E5063),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const Positioned(
              right: 8,
              top: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFF5B76),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 9, height: 9),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
          key: const Key('homeProfileButton'),
          onTap: onProfile,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x145D4DB2),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: HomeIllustration(column: 3, row: 0),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeartLogo extends StatelessWidget {
  const _HeartLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFF7160CF),
            size: 61,
          ),
          Positioned(
            top: 14,
            left: 24,
            child: Icon(
              Icons.add_rounded,
              color: const Color(0xFF7160CF).withValues(alpha: 0.45),
              size: 19,
            ),
          ),
          Positioned(
            right: 4,
            bottom: 1,
            child: Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Color(0xFF7160CF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
