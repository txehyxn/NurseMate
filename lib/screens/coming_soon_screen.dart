import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF24263D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EDFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 52, color: const Color(0xFF6554C0)),
              ),
              const SizedBox(height: 24),
              Text(
                '$title 준비 중',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF24263D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '더 좋은 기능으로 곧 찾아올게요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF77798D), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
