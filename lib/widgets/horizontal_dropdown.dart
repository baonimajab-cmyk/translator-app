import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class HorizontalDropdownItem<T> {
  final T value;
  final String label;

  const HorizontalDropdownItem({required this.value, required this.label});
}

class HorizontalDropdown<T> extends StatefulWidget {
  final T? value;
  final String? hint;
  final List<HorizontalDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? icon;
  final double? width;
  final double? height;

  const HorizontalDropdown({
    super.key,
    this.value,
    this.hint,
    required this.items,
    this.onChanged,
    this.icon,
    this.width,
    this.height,
  });

  @override
  HorizontalDropdownState<T> createState() => HorizontalDropdownState<T>();
}

class HorizontalDropdownState<T> extends State<HorizontalDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _overlayEntry?.remove();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() => _isOpen = !_isOpen);
  }

  void _selectItem(T? value) {
    widget.onChanged?.call(value);
    _toggleDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final buttonHeight = size.height;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 200, // Width of your horizontal menu
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          // Offset: Move it to the right of the button
          offset: Offset(size.width + 5, 0),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: buttonHeight,
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                // Row makes the options horizontal
                mainAxisSize: MainAxisSize.min,
                children:
                    widget.items.map((item) => _buildOption(item)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(HorizontalDropdownItem<T> item) {
    return Expanded(
      child: InkWell(
        onTap: () => _selectItem(item.value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.topCenter,
          child: MongolText(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'NotoSans',
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (widget.value != null) {
      final selectedItem = widget.items.firstWhere(
        (item) => item.value == widget.value,
        orElse: () => widget.items.first,
      );
      return selectedItem.label;
    }
    return widget.hint ?? '';
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          width: widget.width ?? 48,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
                vertical: BorderSide(
                    width: UiHelper.getDividerWidth(context),
                    color: Theme.of(context).colorScheme.outline)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: MongolText(
                    _getDisplayText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSans',
                      color: widget.value != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(height: 8),
                widget.icon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
