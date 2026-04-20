import 'dart:io';

enum AppPlatform {
  apple,
  google,
  china,
}

class PlatformConfig {
  static AppPlatform get current {
    if (Platform.isIOS) return AppPlatform.apple;

    if (Platform.isAndroid) {
      const channel = String.fromEnvironment('CHANNEL');

      if (channel == 'china') {
        return AppPlatform.china;
      }
      return AppPlatform.google;
    }

    return AppPlatform.google;
  }
}
