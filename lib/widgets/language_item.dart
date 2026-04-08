import 'dart:io';

import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class LanguageItemView extends StatelessWidget {
  final Function(int id) onClick;
  final bool selected;
  final LanguageItem data;
  final bool forceClickable;
  const LanguageItemView(
      {super.key,
      required this.data,
      required this.selected,
      required this.onClick,
      this.forceClickable = false});

  @override
  Widget build(BuildContext context) {
    bool support = data.support;
    if (forceClickable) {
      support = true;
    }
    String displayName = data.name +
        (support
            ? ''
            : '   ${AppLocalizations.of(context)!.textNotSupportedYet}');
    return InkWell(
      onTap: () {
        if (support) {
          onClick(data.id);
        } else {
          ToastHelper.show(
              AppLocalizations.of(context)!.alertModelNotSupported);
        }
      },
      child: Padding(
        padding: UiHelper.isVerticalUI()
            ? const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0)
            : const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
        child: UiHelper.isVerticalUI()
            ? _buildVerticalItem(context, support, displayName)
            : _buildHorizontalItem(context, support, displayName),
      ),
    );
  }

  Widget _buildVerticalItem(
      BuildContext context, bool support, String displayName) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: getColor(support ? data.id : 0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: getIcon(data.id)),
        ),
        const SizedBox(height: 10),
        MongolText(
          displayName,
          style: TextStyle(
              color: support
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).hintColor,
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        selected
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary),
                child: const Icon(
                    size: 16, color: Colors.white, CupertinoIcons.check_mark),
              )
            : Container()
      ],
    );
  }

  Widget _buildHorizontalItem(
      BuildContext context, bool support, String displayName) {
    return Row(children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: getColor(support ? data.id : 0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: getIcon(data.id)),
      ),
      const SizedBox(width: 10),
      Text(
        displayName,
        style: TextStyle(
            color: support
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).hintColor,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
      const Spacer(),
      selected
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary),
              child: const Icon(
                  size: 16, color: Colors.white, CupertinoIcons.check_mark),
            )
          : Container()
    ]);
  }

  Color getColor(int id) {
    if (id == 1) {
      return Colors.black;
    } else if (id == 2) {
      return const Color.fromARGB(255, 255, 0, 0);
    } else if (id == 3) {
      return Colors.green;
    } else if (id == 4) {
      return Colors.purple;
    } else if (id == 5) {
      return Colors.blueAccent;
    } else {
      return Colors.grey;
    }
  }

  Widget getIcon(int id) {
    String name = '';
    double margin = 0;
    if (id == 1) {
      name = 'E';
    } else if (id == 2) {
      name = '中';
    } else if (id == 3) {
      name = 'К';
    } else if (id == 4) {
      name = '日';
    } else if (id == 5) {
      name = 'ᠮᠣ᠋';
      margin = Platform.isIOS ? 3 : 0; //fix mongonlian font issue on iOS
    }
    var t = Text(
      name,
      style: const TextStyle(
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
    );
    if (id == 5) {
      return Transform.translate(
        offset: Offset(margin, 0),
        child: RotatedBox(
          quarterTurns: 1,
          child: t,
        ),
      );
    } else {
      return t;
    }
  }
}
