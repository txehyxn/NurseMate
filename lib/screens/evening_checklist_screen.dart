import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist_item.dart';
import '../services/checklist_service.dart';
import 'checklist_screen.dart';

export '../services/checklist_service.dart' show eveningChecklistCompletedKey;

class EveningChecklistScreen extends StatelessWidget {
  const EveningChecklistScreen({super.key, this.preferences});

  final SharedPreferences? preferences;

  @override
  Widget build(BuildContext context) {
    return ChecklistScreen(
      shift: ChecklistShift.evening,
      title: 'EVENING 체크리스트',
      items: eveningChecklistItems,
      service: ChecklistService(preferences),
      keyPrefix: 'eveningChecklist',
    );
  }
}

const eveningChecklistItems = <ChecklistItem>[
  ChecklistItem(
    id: 'inj_3pm',
    title: '3PM Inj.',
    icon: Icons.vaccines_outlined,
  ),
  ChecklistItem(
    id: 'po_before_5pm',
    title: '5PM 식전 PO',
    icon: Icons.medication_outlined,
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
    id: 'inj_6pm',
    title: '6PM Inj.',
    icon: Icons.vaccines_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'po_after_6pm',
    title: '6PM 식후 PO',
    icon: Icons.medication_liquid_outlined,
    category: 'blue',
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
    id: 'next_day_diet',
    title: '익일 식이신청',
    icon: Icons.restaurant_menu_outlined,
    category: 'mint',
  ),
  ChecklistItem(
    id: 'regular_inj_final',
    title: '정규 Inj. & Final 준비',
    icon: Icons.fact_check_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'intake_output',
    title: 'I&O (13시~21시)',
    icon: Icons.water_drop_outlined,
    category: 'blue',
  ),
];
