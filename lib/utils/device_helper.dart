import 'dart:io';

import 'package:abiya_translator/utils/system_setting.dart';
import 'package:app_set_id/app_set_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHelper {
  late DeviceType type;
  late String? deviceID;
  late String language;
  late String model;
  late String appVersion;
  late String systemVersion;
  DeviceHelper();

  Future<void> loadDeviceInfo() async {
    language = GetIt.I<SystemSetting>().localeName;
    type = kIsWeb
        ? DeviceType.web
        : Platform.isAndroid
            ? DeviceType.android
            : Platform.isIOS
                ? DeviceType.iOS
                : DeviceType.unknown;
    deviceID = await AppSetId().getIdentifier();
    deviceID ??= '';
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (type == DeviceType.android) {
      AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
      model = androidDeviceInfo.model;
      systemVersion = androidDeviceInfo.version.sdkInt.toString();
    } else if (type == DeviceType.iOS) {
      IosDeviceInfo iosDeviceInfo = await info.iosInfo;
      model = iosDeviceInfo.utsname.machine;
      systemVersion = iosDeviceInfo.systemVersion;
    } else if (type == DeviceType.web) {
      WebBrowserInfo webBrowserInfo = await info.webBrowserInfo;
      model = webBrowserInfo.browserName.name;
      systemVersion = webBrowserInfo.platform ?? '';
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }

  Map<String, dynamic> getJsonParam() {
    return {
      'type': type == DeviceType.iOS
          ? 1
          : type == DeviceType.android
              ? 2
              : type == DeviceType.web
                  ? 3
                  : 4, //unknown
      'device_id': deviceID,
      'language': language,
      'app_version': appVersion,
      'model': model,
      'system_version': systemVersion
    };
  }
}

enum DeviceType { android, iOS, web, unknown }
