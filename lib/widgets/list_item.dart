import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class AdaptiveListView extends StatelessWidget {
  final List<Widget> children;

  const AdaptiveListView({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return SingleChildScrollView(
      padding: isVerticalUI
          ? const EdgeInsets.symmetric(horizontal: 20)
          : const EdgeInsets.symmetric(vertical: 20),
      scrollDirection: isVerticalUI ? Axis.horizontal : Axis.vertical,
      child: isVerticalUI
          ? Container(
              decoration: BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(
                          width: UiHelper.getDividerWidth(context),
                          color: Theme.of(context).dividerColor))),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: children.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return children[index];
                },
                separatorBuilder: (context, index) {
                  return AdaptiveDivider(isVerticalUI: true);
                },
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(
                          width: UiHelper.getDividerWidth(context),
                          color: Theme.of(context).dividerColor))),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return children[index];
                },
                separatorBuilder: (context, index) {
                  return AdaptiveDivider(isVerticalUI: false);
                },
                itemCount: children.length,
              ),
            ),
    );
  }
}

class AdaptiveDivider extends StatelessWidget {
  final bool isVerticalUI;
  final double indent;
  const AdaptiveDivider(
      {super.key, required this.isVerticalUI, this.indent = 0});
  @override
  Widget build(BuildContext context) {
    return isVerticalUI
        ? Container(
            padding: EdgeInsets.only(top: indent),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
                width: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor),
          )
        : Container(
            padding: EdgeInsets.only(left: indent),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
                height: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor));
  }
}

class ListGroup extends StatelessWidget {
  final List<Widget?> children;
  final double dividerMargin;
  const ListGroup(
      {super.key, required this.children, this.dividerMargin = 36.0});
  @override
  Widget build(BuildContext context) {
    final bool isVerticalUI = UiHelper.isVerticalUI();

    // Use ListView.builder for scrollable list
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: isVerticalUI ? Axis.horizontal : Axis.vertical,
      itemCount: children.length, //+2 for the first and last separator
      itemBuilder: (context, index) {
        return children[index];
      },
      separatorBuilder: (BuildContext context, int index) {
        return AdaptiveDivider(
            isVerticalUI: isVerticalUI, indent: dividerMargin);
      },
    );
  }
}

class ListGap extends StatelessWidget {
  final bool isVertical;
  ListGap({super.key}) : isVertical = UiHelper.isVerticalUI();
  @override
  Widget build(BuildContext context) {
    return isVertical ? SizedBox(width: 20) : SizedBox(height: 20);
  }
}

class VerticalTitle extends StatelessWidget {
  final String text;
  const VerticalTitle({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(4, 0),
              child: MongolText(
                text,
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final String icon;
  final String text;
  final String extra;
  final Function()? onClick;
  final bool isVertical;
  ListItem(
      {super.key,
      required this.icon,
      required this.text,
      this.onClick,
      this.extra = ''})
      : isVertical = UiHelper.isVerticalUI();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: isVertical
          ? _buildVerticalItem(context)
          : _buildHorizongalItem(context),
    );
  }

  Widget _buildVerticalItem(BuildContext context) {
    return Container(
      width: 46,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon.isEmpty
                ? Container()
                : SizedBox(height: 30, width: 30, child: Image.asset(icon)),
            icon.isEmpty ? Container() : const SizedBox(height: 16),
            Transform.translate(
              offset: Offset(4, 0),
              child: MongolText(
                text,
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16),
              ),
            ),
            const Spacer(),
            extra.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Transform.translate(
                      offset: Offset(2, 0),
                      child: MongolText(
                        extra,
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 14,
                            color: Theme.of(context).hintColor),
                      ),
                    ),
                  )
                : Container(),
            onClick == null
                ? Container()
                : RotatedBox(
                    quarterTurns: 3,
                    child: Icon(
                      size: 18,
                      CupertinoIcons.back,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizongalItem(BuildContext context) {
    return Container(
      height: 46,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon.isEmpty
                ? Container()
                : SizedBox(height: 30, width: 30, child: Image.asset(icon)),
            icon.isEmpty
                ? Container()
                : const SizedBox(
                    width: 16,
                  ),
            Text(
              text,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
            const Spacer(),
            extra.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      extra,
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).hintColor),
                    ),
                  )
                : Container(),
            onClick == null
                ? Container()
                : RotatedBox(
                    quarterTurns: 2,
                    child: Icon(
                      size: 18,
                      CupertinoIcons.back,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class FirstPageErrorView extends StatelessWidget {
  const FirstPageErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: UiHelper.isVerticalUI()
            ? MongolText(
                AppLocalizations.of(context)!.textListEmpty,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSecondary),
              )
            : Text(
                AppLocalizations.of(context)!.textListEmpty,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary),
              ));
  }
}

class EmptyListIndicator extends StatelessWidget {
  final String text;
  const EmptyListIndicator({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: UiHelper.isVerticalUI()
            ? MongolText(
                text,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSecondary),
              )
            : Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary),
              ));
  }
}
