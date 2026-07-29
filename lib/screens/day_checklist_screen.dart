import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist_item.dart';
import '../services/checklist_service.dart';
import 'checklist_screen.dart';

export '../services/checklist_service.dart' show dayChecklistCompletedKey;

class DayChecklistScreen extends StatelessWidget {
  const DayChecklistScreen({super.key, this.preferences});

  final SharedPreferences? preferences;

  @override
  Widget build(BuildContext context) {
    return ChecklistScreen(
      shift: ChecklistShift.day,
      title: 'DAY 체크리스트',
      items: dayChecklistItems,
      service: ChecklistService(preferences),
      keyPrefix: 'dayChecklist',
    );
  }
}

const dayChecklistItems = <ChecklistItem>[
  ChecklistItem(
    id: 'inj_9am',
    title: '9AM Inj.',
    icon: Icons.vaccines_outlined,
  ),
  ChecklistItem(
    id: 'po_8am',
    title: '8AM PO',
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
    id: 'md_inj',
    title: 'MD Inj.',
    icon: Icons.vaccines_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'po_before_lunch',
    title: '12시 식전 PO',
    icon: Icons.medication_outlined,
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
    id: 'po_after_lunch',
    title: '12시 식후 PO',
    icon: Icons.medication_liquid_outlined,
  ),
  ChecklistItem(
    id: 'pain',
    title: '통증',
    icon: Icons.bolt_outlined,
    category: 'pink',
  ),
  ChecklistItem(
    id: 'pick_up',
    title: 'PICK UP',
    icon: Icons.inventory_2_outlined,
    category: 'blue',
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
    id: 'inj_2pm',
    title: '2PM Inj.',
    icon: Icons.vaccines_outlined,
  ),
  ChecklistItem(
    id: 'discharge_medication',
    title: '퇴원약(퇴원약 & 자가약 확인)',
    icon: Icons.home_work_outlined,
    category: 'blue',
  ),
  ChecklistItem(
    id: 'soapie_charting',
    title: 'SOAPIE 차팅',
    icon: Icons.edit_note_rounded,
  ),
  ChecklistItem(
    id: 'md_final',
    title: 'MD Final 준비',
    icon: Icons.fact_check_outlined,
    category: 'orange',
  ),
  ChecklistItem(
    id: 'intake_output',
    title: 'I&O (06시~13시)',
    icon: Icons.water_drop_outlined,
    category: 'blue',
  ),
];
