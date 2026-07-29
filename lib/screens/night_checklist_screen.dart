import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist_item.dart';
import '../services/checklist_service.dart';
import 'checklist_screen.dart';

export '../services/checklist_service.dart' show nightChecklistCompletedKey;

class NightChecklistScreen extends StatelessWidget {
  const NightChecklistScreen({super.key, this.preferences});

  final SharedPreferences? preferences;

  @override
  Widget build(BuildContext context) {
    return ChecklistScreen(
      shift: ChecklistShift.night,
      title: 'NIGHT 체크리스트',
      items: nightChecklistItems,
      service: ChecklistService(preferences),
      keyPrefix: 'nightChecklist',
    );
  }
}

const nightChecklistItems = <ChecklistItem>[
  ChecklistItem(
    id: 'inj_9pm',
    title: '9PM Inj.',
    icon: Icons.vaccines_outlined,
  ),
  ChecklistItem(
    id: 'po_hs_9pm',
    title: '9PM HS PO',
    icon: Icons.bedtime_outlined,
    category: 'blue',
  ),
  ChecklistItem(
    id: 'regular',
    title: '정규',
    icon: Icons.assignment_outlined,
    category: 'mint',
  ),
  ChecklistItem(
    id: 'vital_sign',
    title: 'V/S',
    icon: Icons.monitor_heart_outlined,
    category: 'pink',
  ),
  ChecklistItem(
    id: 'bst',
    title: 'BST',
    icon: Icons.bloodtype_outlined,
    category: 'error',
  ),
  ChecklistItem(
    id: 'fall',
    title: '낙상',
    icon: Icons.health_and_safety_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'pressure_injury',
    title: '욕창',
    icon: Icons.healing_outlined,
    category: 'mint',
  ),
  ChecklistItem(
    id: 'pain',
    title: '통증',
    icon: Icons.bolt_outlined,
    category: 'pink',
  ),
  ChecklistItem(
    id: 'bundle',
    title: '번들',
    icon: Icons.all_inbox_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'nursing_activity',
    title: '간호활동',
    icon: Icons.medical_services_outlined,
    category: 'mint',
  ),
  ChecklistItem(
    id: 'inj_6am',
    title: '6AM Inj.',
    icon: Icons.vaccines_outlined,
  ),
  ChecklistItem(
    id: 'po_6am',
    title: '6AM PO',
    icon: Icons.medication_outlined,
    category: 'blue',
  ),
  ChecklistItem(
    id: 'morning_care',
    title: 'Morning Care',
    icon: Icons.cleaning_services_outlined,
    category: 'mint',
  ),
  ChecklistItem(
    id: 'blood_test_preparation',
    title: '혈액검사 준비',
    icon: Icons.science_outlined,
    category: 'error',
  ),
  ChecklistItem(
    id: 'intake_output',
    title: 'I&O (21시~06시)',
    icon: Icons.water_drop_outlined,
    category: 'blue',
  ),
  ChecklistItem(
    id: 'handover_preparation',
    title: '인계 준비',
    icon: Icons.assignment_turned_in_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'charting_review',
    title: '차팅 확인',
    icon: Icons.rule_outlined,
  ),
];
