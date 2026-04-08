import 'package:flutter/foundation.dart';

class Logger {
  static void log(String msg) {
    if (kDebugMode) {
      print(msg);
    }
  }
}
