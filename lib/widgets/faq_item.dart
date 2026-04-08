import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class FaqItem extends StatefulWidget {
  final int id;
  final String title;
  final String text;
  const FaqItem({
    super.key,
    required this.id,
    required this.title,
    required this.text,
  });

  @override
  State<StatefulWidget> createState() {
    return FaqItemState();
  }
}

class FaqItemState extends State<FaqItem> {
  bool expend = false;
  @override
  Widget build(BuildContext context) {
    return UiHelper.isVerticalUI()
        ? _buildVerticalLayout(context)
        : _buildHorizontalLayout(context);
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
                vertical: BorderSide(
                    width: UiHelper.getDividerWidth(context),
                    color: Theme.of(context).colorScheme.outline))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: MongolText.rich(TextSpan(
                    style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: '${widget.id}. ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      TextSpan(
                          text: widget.title,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expend = !expend;
                    });
                  },
                  child: RotatedBox(
                    quarterTurns: expend ? 0 : 3,
                    child: Icon(
                      size: 20,
                      CupertinoIcons.back,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            MongolText(
              maxLines: expend ? null : 2,
              widget.text,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
                horizontal: BorderSide(
                    width: UiHelper.getDividerWidth(context),
                    color: Theme.of(context).colorScheme.outline))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: RichText(
                      text: TextSpan(
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: '${widget.id}. ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      TextSpan(
                          text: widget.title,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16)),
                    ],
                  )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expend = !expend;
                    });
                  },
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: RotatedBox(
                      quarterTurns: expend ? 1 : 2,
                      child: Icon(
                        CupertinoIcons.back,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              maxLines: expend ? null : 2,
              widget.text,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
