import 'package:abiya_translator/utils/themes.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class Alert {
  static void showInput(BuildContext context, String title, String msg,
      String textConfirm, String textCancel, Function(String) onConfirm,
      {String hint = '', bool obsecure = false}) {
    FocusNode focusNode = FocusNode();
    TextEditingController controller = TextEditingController();
    TextField tf = TextField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obsecure,
      style: TextStyle(color: Theme.of(context).textSelectionTheme.cursorColor),
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onSubmitted: (value) => {onConfirm(controller.text)},
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      ),
    );
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getContentText(context, msg),
        const SizedBox(
          height: 20,
        ),
        tf,
      ],
    );
    _show(context, title, textConfirm, textCancel, content, () {
      if (controller.text.isEmpty) {
        return;
      }
      onConfirm(controller.text);
    });
  }

  static void show(BuildContext context, String title, String msg,
      String textConfirm, String textCancel, Function() onConfirm,
      {Function()? onCancel}) {
    _show(context, title, textConfirm, textCancel,
        _getContentText(context, msg), onConfirm,
        onCancel: onCancel);
  }

  static void showContent(BuildContext context, String title, Widget content,
      String textConfirm, String textCancel, Function() onConfirm,
      {Function()? onCancel}) {
    _show(context, title, textConfirm, textCancel, content, onConfirm,
        onCancel: onCancel);
  }

  static Widget _getContentText(BuildContext context, String text) {
    if (UiHelper.isVerticalUI()) {
      return MongolText(
        text,
        style: TextStyle(
            fontFamily: 'NotoSans',
            color: Theme.of(context).colorScheme.onSurface),
      );
    }
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  static Future<void> _showVertical(
      BuildContext context,
      String title,
      String textConfirm,
      String textCancel,
      Widget content,
      Function() onConfirm,
      {Function()? onCancel}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          constraints: BoxConstraints(
              minWidth: 80, maxWidth: 240, minHeight: 200, maxHeight: 420),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MongolText(
                  title,
                  style: TextStyle(
                      fontFamily: 'NotoSans',
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                content,
                Spacer(),
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  MongolFilledButton(
                      onPressed: textConfirm.isNotEmpty ? onConfirm : null,
                      child: Transform.translate(
                        offset: Offset(2, 0),
                        child: MongolText(
                          textConfirm,
                          style: TextStyle(
                              fontFamily: 'NotoSans', color: Colors.white),
                        ),
                      )),
                  const SizedBox(height: 10),
                  MongolFilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Themes.greyButtonBackgroundColor),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) {
                          onCancel();
                        }
                      },
                      child: Transform.translate(
                        offset: Offset(2, 0),
                        child: MongolText(
                          textCancel,
                          style: const TextStyle(
                              fontFamily: 'NotoSans', color: Colors.red),
                        ),
                      )),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _show(
      BuildContext context,
      String title,
      String textConfirm,
      String textCancel,
      Widget content,
      Function() onConfirm,
      {Function()? onCancel}) {
    if (UiHelper.isVerticalUI()) {
      return _showVertical(
          context, title, textConfirm, textCancel, content, onConfirm,
          onCancel: onCancel);
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding:
              const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          actionsAlignment: textCancel.isEmpty
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.onSurface,
          title: Text(title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
          content: content,
          actions: <Widget>[
            if (textCancel.isNotEmpty)
              GreyRoundedButton(
                label: textCancel,
                fill: true,
                loading: false,
                onClick: () {
                  Navigator.pop(context);
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                backgroundColor: Themes.greyButtonBackgroundColor,
                forgroundColor: Colors.red,
              ),
            RedRoundedButton(
              label: textConfirm,
              loading: false,
              onClick: onConfirm,
              fill: true,
            ),
          ],
        );
      },
    );
  }
}
