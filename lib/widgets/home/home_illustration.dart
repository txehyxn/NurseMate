import 'package:flutter/material.dart';

class HomeIllustration extends StatelessWidget {
  const HomeIllustration({super.key, required this.column, required this.row})
    : assert(column >= 0 && column < 4),
      assert(row >= 0 && row < 2);

  final int column;
  final int row;

  static const assetPath = 'assets/home/home-illustrations.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.biggest.shortestSide;
        return Center(
          child: SizedBox.square(
            dimension: cellSize,
            child: ClipRect(
              child: Transform.scale(
                scale: 1.025,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: cellSize * 4,
                  maxWidth: cellSize * 4,
                  minHeight: cellSize * 2,
                  maxHeight: cellSize * 2,
                  child: Transform.translate(
                    offset: Offset(-column * cellSize, -row * cellSize),
                    child: Image.asset(
                      assetPath,
                      width: cellSize * 4,
                      height: cellSize * 2,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
