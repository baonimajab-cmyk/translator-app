import 'dart:io';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class TranslationDetailPane extends StatefulWidget {
  final TranslationItem data;
  final ScrollController scrollController;
  final Function(bool) toggleExpaned;
  final Function() onDelete;
  const TranslationDetailPane({
    super.key,
    required this.data,
    required this.scrollController,
    required this.toggleExpaned,
    required this.onDelete,
  });

  @override
  State<StatefulWidget> createState() {
    return TranslationDetailPaneState();
  }
}

class TranslationDetailPaneState extends State<TranslationDetailPane> {
  bool expand = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mixedLayout = true;
                // widget.data.from == 'mo' || widget.data.to == 'mo';
                if (mixedLayout) {
                  return _buildColumn(
                      context, true, constraints.maxHeight - 15);
                }
                // return SingleChildScrollView(
                //   controller: widget.scrollController,
                //   child: _buildColumn(context, false, null),
                // );
              },
            ),
          ),
        ),
        Divider(height: UiHelper.getDividerWidth(context)),
        Padding(
          padding:
              EdgeInsets.only(top: 16.0, bottom: Platform.isAndroid ? 32 : 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            InkWell(
              onTap: () async {
                String copyToastMsg =
                    AppLocalizations.of(context)!.toastTextCopied;
                await Clipboard.setData(
                    ClipboardData(text: widget.data.result));
                ToastHelper.show(copyToastMsg);
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  CupertinoIcons.square_on_square,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onDelete();
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  CupertinoIcons.delete,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GetIt.I<SystemSetting>().isDarkMode(context)
                    ? Theme.of(context).colorScheme.outline
                    : const Color.fromARGB(20, 255, 0, 0),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    size: 24,
                    CupertinoIcons.back,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                //toggle favourite
                addFavourite(widget.data.id);
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  widget.data.isFavourite
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  expand = !expand;
                });
                widget.toggleExpaned(expand);
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  expand
                      ? CupertinoIcons.fullscreen_exit
                      : CupertinoIcons.fullscreen,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ]),
        )
      ],
    );
  }

  Widget _buildSourceText(BuildContext context, {bool constrained = false}) {
    Widget content;
    if (widget.data.from == 'mo') {
      final scrollController = ScrollController();
      content = RawScrollbar(
        thickness: 4.0,
        padding: EdgeInsets.only(top: 4),
        thumbColor: Theme.of(context).colorScheme.outline,
        radius: Radius.circular(4.0),
        thumbVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: MongolText(widget.data.original,
              rotateCJK: false,
              softWrap: true,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NotoSans',
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.w600)),
        ),
      );
    } else {
      content = Text(
        widget.data.original,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'NotoSans',
          height: 1.4,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      );

      if (constrained) {
        return SingleChildScrollView(child: content);
      }
    }
    return content;
  }

  Widget _buildResultText(BuildContext context) {
    Widget content;
    if (widget.data.to == 'mo') {
      final scrollController = ScrollController();
      content = RawScrollbar(
        thickness: 4.0,
        padding: EdgeInsets.only(top: 4),
        thumbColor: Theme.of(context).colorScheme.outline,
        radius: Radius.circular(4.0),
        thumbVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: MongolText(widget.data.result,
              rotateCJK: false,
              softWrap: true,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NotoSans',
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600)),
        ),
      );
    } else {
      content = SingleChildScrollView(
        controller: widget.scrollController,
        child: Text(
          widget.data.result,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSans',
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600),
        ),
      );
    }
    return content;
  }

  Widget _buildColumn(BuildContext context, bool mixedLayout,
      [double? maxHeight]) {
    const dividerThickness = 1.0;
    if (mixedLayout && maxHeight != null && maxHeight.isFinite) {
      final halfHeight = (maxHeight - dividerThickness) / 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: halfHeight,
            child: _buildResultText(context),
          ),
          Divider(thickness: UiHelper.getDividerWidth(context)),
          SizedBox(
            height: halfHeight,
            child: _buildSourceText(context, constrained: true),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultText(context),
        Divider(thickness: UiHelper.getDividerWidth(context)),
        _buildSourceText(context),
      ],
    );
  }

  void addFavourite(int id) {
    HttpHelper<AddFavouriteResponse>(AddFavouriteResponse.new).post(
      apiAddFavourite,
      {
        'id': id,
        'add': !widget.data.isFavourite,
      },
      onResponse: (response) {
        setState(() {
          widget.data.isFavourite = response.favourite;
        });
      },
      onError: (et, em) {},
    );
  }
}
