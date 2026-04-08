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
}
