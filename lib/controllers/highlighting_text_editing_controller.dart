import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/memo.dart';

class HighlightingTextEditingController extends TextEditingController {
  HighlightingTextEditingController({
    super.text,
    List<MemoHighlight> highlights = const [],
  }) : _highlights = [...highlights],
       _previousText = text ?? '' {
    _normalizeHighlights();
    addListener(_handleTextChange);
  }

  static const Color highlightColor = Color(0xFFFFF59D);

  final List<MemoHighlight> _highlights;
  String _previousText;

  List<MemoHighlight> get highlights => List.unmodifiable(_highlights);

  bool highlightSelection() {
    final selection = this.selection;
    if (!selection.isValid || selection.isCollapsed) return false;

    final start = math.min(selection.start, selection.end);
    final end = math.max(selection.start, selection.end);
    _highlights.add(MemoHighlight(start: start, end: end));
    _normalizeHighlights();
    notifyListeners();
    return true;
  }

  bool clearHighlightFromSelection() {
    final selection = this.selection;
    if (!selection.isValid || selection.isCollapsed) return false;

    final start = math.min(selection.start, selection.end);
    final end = math.max(selection.start, selection.end);
    final updated = <MemoHighlight>[];
    var didChange = false;

    for (final highlight in _highlights) {
      if (highlight.end <= start || highlight.start >= end) {
        updated.add(highlight);
        continue;
      }
      didChange = true;
      if (highlight.start < start) {
        updated.add(MemoHighlight(start: highlight.start, end: start));
      }
      if (highlight.end > end) {
        updated.add(MemoHighlight(start: end, end: highlight.end));
      }
    }

    if (!didChange) return false;
    _highlights
      ..clear()
      ..addAll(updated);
    notifyListeners();
    return true;
  }

  void _handleTextChange() {
    final currentText = text;
    if (currentText == _previousText) return;

    var prefixLength = 0;
    final shortestLength = math.min(_previousText.length, currentText.length);
    while (prefixLength < shortestLength &&
        _previousText.codeUnitAt(prefixLength) ==
            currentText.codeUnitAt(prefixLength)) {
      prefixLength++;
    }

    var suffixLength = 0;
    while (suffixLength < shortestLength - prefixLength &&
        _previousText.codeUnitAt(_previousText.length - 1 - suffixLength) ==
            currentText.codeUnitAt(currentText.length - 1 - suffixLength)) {
      suffixLength++;
    }

    final oldEditEnd = _previousText.length - suffixLength;
    final newEditEnd = currentText.length - suffixLength;
    final delta = newEditEnd - oldEditEnd;
    final updated = <MemoHighlight>[];

    for (final highlight in _highlights) {
      if (highlight.end <= prefixLength) {
        updated.add(highlight);
      } else if (highlight.start >= oldEditEnd) {
        updated.add(
          MemoHighlight(
            start: highlight.start + delta,
            end: highlight.end + delta,
          ),
        );
      }
    }

    _highlights
      ..clear()
      ..addAll(updated);
    _previousText = currentText;
    _normalizeHighlights();
  }

  void _normalizeHighlights() {
    final valid =
        _highlights.where((highlight) => highlight.isValidFor(text)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final merged = <MemoHighlight>[];
    for (final highlight in valid) {
      if (merged.isEmpty || highlight.start > merged.last.end) {
        merged.add(highlight);
      } else {
        final previous = merged.removeLast();
        merged.add(
          MemoHighlight(
            start: previous.start,
            end: math.max(previous.end, highlight.end),
          ),
        );
      }
    }
    _highlights
      ..clear()
      ..addAll(merged);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final boundaries = <int>{0, text.length};
    for (final highlight in _highlights) {
      boundaries
        ..add(highlight.start)
        ..add(highlight.end);
    }
    final composing = value.composing;
    if (withComposing && composing.isValid && !composing.isCollapsed) {
      boundaries
        ..add(composing.start)
        ..add(composing.end);
    }
    final sorted = boundaries.toList()..sort();

    return TextSpan(
      style: style,
      children: [
        for (var index = 0; index < sorted.length - 1; index++)
          _spanForRange(
            sorted[index],
            sorted[index + 1],
            style,
            withComposing ? composing : TextRange.empty,
          ),
      ],
    );
  }

  TextSpan _spanForRange(
    int start,
    int end,
    TextStyle? baseStyle,
    TextRange composing,
  ) {
    final isHighlighted = _highlights.any(
      (highlight) => highlight.start < end && highlight.end > start,
    );
    final isComposing =
        composing.isValid &&
        !composing.isCollapsed &&
        composing.start < end &&
        composing.end > start;

    return TextSpan(
      text: text.substring(start, end),
      style: (baseStyle ?? const TextStyle()).copyWith(
        backgroundColor: isHighlighted ? highlightColor : null,
        decoration: isComposing ? TextDecoration.underline : null,
      ),
    );
  }

  @override
  void dispose() {
    removeListener(_handleTextChange);
    super.dispose();
  }
}
