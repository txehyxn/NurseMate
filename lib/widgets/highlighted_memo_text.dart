import 'package:flutter/material.dart';

import '../models/memo.dart';

class HighlightedMemoText extends StatelessWidget {
  const HighlightedMemoText({
    super.key,
    required this.text,
    required this.highlights,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.style,
  });

  final String text;
  final List<MemoHighlight> highlights;
  final int? maxLines;
  final TextOverflow overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final validHighlights =
        highlights.where((highlight) => highlight.isValidFor(text)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final spans = <InlineSpan>[];
    var position = 0;

    for (final highlight in validHighlights) {
      if (highlight.start > position) {
        spans.add(TextSpan(text: text.substring(position, highlight.start)));
      }
      final start = highlight.start < position ? position : highlight.start;
      if (highlight.end > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, highlight.end),
            style: TextStyle(backgroundColor: Color(highlight.colorValue)),
          ),
        );
      }
      position = position < highlight.end ? highlight.end : position;
    }
    if (position < text.length) {
      spans.add(TextSpan(text: text.substring(position)));
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
  }
}
