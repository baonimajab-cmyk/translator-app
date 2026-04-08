import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class RoundedButton extends StatelessWidget {
  final Function() onClick;
  final bool loading;
  final bool fill;
  final String label;
  final Color backgroundColor;
  final Color forgroundColor;
  final bool boldText;
  final double? width;
  final double? height;
  const RoundedButton(
      {super.key,
      required this.label,
      required this.loading,
      required this.onClick,
      this.fill = false,
      this.boldText = true,
      required this.backgroundColor,
      required this.forgroundColor,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    final bool isVerticalUI = UiHelper.isVerticalUI();
    final double defaultWidth = isVerticalUI ? width ?? 40 : width ?? 120;
    final double defaultHeight = isVerticalUI ? height ?? 120 : height ?? 40;
    final radius = isVerticalUI ? defaultWidth / 2 : defaultHeight / 2;
    return InkWell(
      onTap: onClick,
      child: Container(
        width: defaultWidth,
        height: defaultHeight,
        decoration: BoxDecoration(
            color: fill ? backgroundColor : Colors.transparent,
            border: Border.all(
              color: fill ? Colors.transparent : backgroundColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        child: loading
            ? Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: fill ? forgroundColor : backgroundColor,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Center(
                child: isVerticalUI
                    ? MongolText(
                        label,
                        style: TextStyle(
                            color: fill ? forgroundColor : backgroundColor,
                            fontSize: 12,
                            fontFamily: 'NotoSans',
                            fontWeight:
                                boldText ? FontWeight.bold : FontWeight.normal),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: fill ? forgroundColor : backgroundColor,
                            fontSize: 12,
                            fontWeight:
                                boldText ? FontWeight.bold : FontWeight.normal),
                      ),
              ),
      ),
    );
  }
}

class RedRoundedButton extends RoundedButton {
  const RedRoundedButton(
      {super.key,
      required super.label,
      required super.loading,
      required super.onClick,
      super.fill = false,
      super.boldText = true,
      super.backgroundColor = const Color.fromARGB(255, 255, 0, 0),
      super.forgroundColor = Colors.white,
      super.width,
      super.height});
}

class GreyRoundedButton extends RoundedButton {
  const GreyRoundedButton(
      {super.key,
      required super.label,
      required super.loading,
      required super.onClick,
      super.fill = false,
      super.boldText = false,
      super.backgroundColor = const Color.fromARGB(255, 242, 242, 247),
      super.forgroundColor = Colors.black87,
      super.width,
      super.height});
}
