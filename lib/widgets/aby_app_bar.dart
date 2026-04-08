import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/material.dart';

/// A custom AppBar that automatically displays titles vertically for traditional Mongolian
/// and horizontally for other languages
class AbyAppBar extends AppBar {
  AbyAppBar({
    super.key,
    String? titleText,
    Widget? title,
    super.leading,
    super.actions,
    super.bottom,
    super.flexibleSpace,
    super.backgroundColor,
    super.foregroundColor,
    super.elevation,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary,
    super.centerTitle,
    super.excludeHeaderSemantics,
    super.titleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    super.toolbarHeight,
    super.leadingWidth,
    super.automaticallyImplyLeading,
    super.shape,
    super.clipBehavior,
    super.forceMaterialTransparency,
    super.systemOverlayStyle,
  }) : super(
          title: _buildTitle(titleText, title),
        );

  static Widget? _buildTitle(String? titleText, Widget? title) {
    // If a custom title widget is provided, use it
    if (title != null) {
      return title;
    }

    final bool isVerticalUI = UiHelper.isVerticalUI();

    if (isVerticalUI) {
      // For vertical UI, display the logo image like in home.dart
      return SizedBox(
        width: 20,
        height: 30,
        child: Image.asset('assets/images/app_bar_logo.png'),
      );
    } else {
      // For horizontal UI, use regular Text if titleText is provided
      if (titleText == null || titleText.isEmpty) {
        return null;
      }
      return Text(titleText);
    }
  }
}
