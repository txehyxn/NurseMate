import 'package:flutter/material.dart';

import '../models/drug.dart';

class DrugImage extends StatelessWidget {
  const DrugImage({super.key, required this.drug, required this.size});

  final Drug drug;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = drug.imageUrl;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? Icon(
              drug.dosageForm.contains('주사')
                  ? Icons.vaccines_outlined
                  : Icons.medication_outlined,
              color: const Color(0xFF2166D1),
              size: size * 0.44,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFF7D90A3),
              ),
            ),
    );
  }
}
