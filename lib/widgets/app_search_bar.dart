import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
    this.searchBarKey,
  });

  final String text;
  final String hintText;
  final ValueChanged<String> onChanged;
  final Key? searchBarKey;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SearchBar(
      key: widget.searchBarKey,
      controller: _controller,
      onChanged: widget.onChanged,
      hintText: widget.hintText,
      leading: const Icon(Icons.search_rounded),
      backgroundColor: WidgetStatePropertyAll(colors.surface),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? NurseMateColors.primary
              : colors.outline,
          width: states.contains(WidgetState.focused) ? 1.5 : 1,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: NurseMateSpacing.md),
      ),
      constraints: const BoxConstraints(minHeight: 56),
      textStyle: WidgetStatePropertyAll(theme.textTheme.bodyLarge),
      hintStyle: WidgetStatePropertyAll(
        theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}
