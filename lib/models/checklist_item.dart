import 'package:flutter/material.dart';

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.category,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? category;
}
