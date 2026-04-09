import 'package:abiya_translator/utils/system_setting.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UiHelper {
  static bool isVerticalUI() {
    return GetIt.I<SystemSetting>().localeName == 'mo';
  }

  static double getDividerWidth(BuildContext context) {
    return 1 / MediaQuery.of(context).devicePixelRatio;
  }

  /// 与主页 AppBar 一致的底部分割线（主题色 + 设备像素对齐宽度）
  static ShapeBorder appBarBottomBorder(BuildContext context) {
    return Border(
      bottom: BorderSide(
        width: getDividerWidth(context),
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
