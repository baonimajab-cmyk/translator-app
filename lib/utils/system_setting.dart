import 'dart:io';

import 'package:abiya_translator/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemSetting with ChangeNotifier {
  String themeKey = "theme";
  String localeKey = "locale";
  ThemeMode themeMode = ThemeMode.system;
  String localeName = 'en';
  SystemSetting() {
    loadThemeSetting();
    loadLocaleSetting();
  }

  void loadLocaleSetting() async {
    // print('locale: ${Platform.localeName}');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? localeString = preferences.getString(localeKey);
    if (localeString == null) {
      localeString = Platform.localeName;
      localeString = localeString.split('_')[0];
      setLocaleSetting(localeString);
    } else {
      localeName = localeString;
      notifyListeners();
    }
    Logger.log("locale: $localeName");
  }

  void setLocaleSetting(String locale) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (locale != 'zh' &&
        locale != 'mn' &&
        locale != 'mo' &&
        locale != 'jp' &&
        locale != 'ja') {
      locale = 'en';
    }
    if (locale == 'jp') {
      locale = 'ja';
    }
    preferences.setString(localeKey, locale);
    localeName = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int mode;
    switch (value) {
      case ThemeMode.light:
        mode = 1;
        themeMode = ThemeMode.light;
        break;
      case ThemeMode.dark:
        themeMode = ThemeMode.dark;
        mode = 2;
        break;
      default:
        themeMode = ThemeMode.system;
        mode = 0;
        break;
    }
    preferences.setInt(themeKey, mode);
    notifyListeners();
  }

  void loadThemeSetting() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int mode = preferences.getInt(themeKey) ?? 0;
    switch (mode) {
      case 1:
        themeMode = ThemeMode.light;
        break;
      case 2:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    return themeMode;
  }

  bool isDarkMode(BuildContext context) {
    return themeMode == ThemeMode.dark ||
        themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  Locale getLocale() {
    return Locale(localeName);
  }
}
