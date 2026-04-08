import 'dart:async';
import 'dart:convert';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/logger.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class HttpHelper<T extends CommonReponse> {
  T Function(dynamic) creator;
  int retryCount = 0;
  final int maxRetries = 3;
  HttpHelper(
    this.creator,
  );
  Future<bool> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // This condition is for demo purposes only to explain every connection type.
// Use conditions which work for your requirements.
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      return false;
    }
    return false;
  }

  void post(String url, Object? data,
      {required Function(T response) onResponse,
      required Function(int et, String em) onError}) async {
    if (!await checkNetwork()) {
      return null;
    }
    url = host + url;
    Logger.log("$url << ${data == null ? '' : data.toString()}");
    final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10)));
    while (retryCount < maxRetries) {
      try {
        await _post(dio, url, data, onResponse: onResponse, onError: onError);
        return;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          Logger.log("DioException: ${e.type}, retrying $url $retryCount time");
          retryCount++;
          if (retryCount >= maxRetries) {
            Logger.log("Giving up $url");
            onError(-1, 'Network Error');
          }
        }
      }
    }
  }

  Future<void> _post(Dio dio, String url, Object? data,
      {required Function(T response) onResponse,
      required Function(int et, String em) onError}) async {
    UserManager manager = GetIt.I<UserManager>();
    UserInfo? info = manager.getCurrentUser();
    String localName = GetIt.I<SystemSetting>().localeName;
    try {
      final response = await dio.post(url,
          data: data,
          options: Options(headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Token': info != null ? info.token : '',
            'User': info != null ? info.name : '',
            'Language': localName
          }));
      if (response.statusCode == 200) {
        CommonReponse cr = CommonReponse(jsonDecode(response.data));
        if (cr.errCode == 0) {
          Logger.log("$url >> ${response.data}");
          // return creator(jsonDecode(response.data));
          onResponse(creator(jsonDecode(response.data)));
        } else {
          //todo alert somehow
          Logger.log("$url >>[${cr.errCode}] ${cr.errMsg}");
          onError(cr.errCode, cr.errMsg);
        }
      } else {
        //todo alert for network error
        Logger.log("$url >> ${response.statusCode} - ${response.data}");
        onError(response.statusCode!, response.data);
      }
    } catch (e) {
      rethrow;
    }
  }
}
