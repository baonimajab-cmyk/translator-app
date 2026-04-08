import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class GetCodeButton extends StatelessWidget {
  final Function() onClick;
  final String label;
  final bool boldText;
  final Color color;
  final bool loading;
  const GetCodeButton({
    super.key,
    required this.label,
    required this.onClick,
    this.boldText = true,
    this.color = const Color.fromARGB(255, 255, 0, 0),
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    final double defaultHeight = isVerticalUI ? 120 : 60;
    final double defaultWidth = isVerticalUI ? 60 : 120;
    return InkWell(
      onTap: onClick,
      child: Container(
        height: defaultHeight,
        width: defaultWidth,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: color,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: loading
            ? Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Center(
                child: isVerticalUI
                    ? MongolText(
                        label,
                        textAlign: MongolTextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontFamily: 'NotoSans',
                            fontWeight:
                                boldText ? FontWeight.bold : FontWeight.normal),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight:
                                boldText ? FontWeight.bold : FontWeight.normal),
                      ),
              ),
      ),
    );
  }
}
