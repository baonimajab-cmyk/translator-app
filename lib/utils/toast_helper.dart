import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void show(String msg) {
    final isVerticalUI = UiHelper.isVerticalUI();
    toastification.showCustom(
      alignment: Alignment.center,
      autoCloseDuration: const Duration(seconds: 3),
      animationBuilder: (
        context,
        animation,
        alignment,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      builder: (BuildContext context, ToastificationItem holder) {
        return Center(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: isVerticalUI
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: MongolText(msg,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                          )),
                    )
                  : Text(msg, textAlign: TextAlign.center)),
        );
      },
    );
  }
}
