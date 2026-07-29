import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../design_system/nursemate_design_system.dart';

class PriceText extends StatelessWidget {
  const PriceText(this.price, {super.key, this.style});

  final int price;
  final TextStyle? style;

  static final NumberFormat _formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: NurseMateColors.primary,
      fontWeight: FontWeight.w800,
    );

    return Text(
      '${_formatter.format(price)}원',
      style: defaultStyle?.merge(style) ?? style,
    );
  }
}
