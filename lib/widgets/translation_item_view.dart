import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/translation_detail_pane.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mongol/mongol.dart';

class TranslationItemView extends StatefulWidget {
  final TranslationItem data;
  final bool showDelete;
  final Function(int)? onDelete;
  const TranslationItemView(
      {super.key, required this.data, this.showDelete = false, this.onDelete});

  @override
  State<StatefulWidget> createState() {
    return TranslationItemViewState();
  }
}

class TranslationItemViewState extends State<TranslationItemView> {
  static double defaultPannelSize = 0.5;
  static double maxPannelSize = 0.92;
  static double minPannelSize = 0.3;
  DraggableScrollableController panelController =
      DraggableScrollableController();

  @override
  void dispose() {
    panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(widget.data.time * 1000);
    var df = DateFormat('yyyy-MM-dd HH:mm').format(dt);
    return UiHelper.isVerticalUI()
        ? _buildVerticalItem(context, df)
        : _buildHorizontalItem(context, df);
  }

  Widget _buildVerticalItem(BuildContext context, String df) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 16.0),
      child: InkWell(
        onTap: () => {toTranslateDetail(widget.data)},
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MongolText(
              rotateCJK: false,
              widget.data.original,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 10),
            MongolText(
              maxLines: 2,
              rotateCJK: false,
              widget.data.result,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            VerticalDivider(
              thickness: 1,
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                //show delete means history list or favourite list
                //we don't show time for phrase book
                widget.showDelete
                    ? MongolText(
                        df,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSans',
                            color: Theme.of(context).colorScheme.onSecondary),
                      )
                    : Container(),
                const Spacer(),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: InkWell(
                      onTap: () => {copyText(widget.data)},
                      child: const Icon(
                          size: 16, CupertinoIcons.square_on_square)),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (widget.showDelete) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: InkWell(
                        onTap: () => {deleteItem(widget.data.id)},
                        child:
                            const Icon(size: 16, CupertinoIcons.delete_simple)),
                  ),
                  SizedBox(height: 20),
                ],
                SizedBox(
                  width: 20,
                  height: 20,
                  child: InkWell(
                      onTap: () => {addFavourite(widget.data.id)},
                      child: Icon(
                          size: 16,
                          widget.data.isFavourite
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star)),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildHorizontalItem(BuildContext context, String df) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: InkWell(
        onTap: () => {toTranslateDetail(widget.data)},
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.data.original,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              maxLines: 2,
              widget.data.result,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Divider(height: UiHelper.getDividerWidth(context)),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                //show delete means history list or favourite list
                //we don't show time for phrase book
                if (widget.showDelete)
                  Text(
                    df,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                const Spacer(),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: InkWell(
                      onTap: () => {copyText(widget.data)},
                      child: const Icon(
                          size: 16, CupertinoIcons.square_on_square)),
                ),
                const SizedBox(width: 20),
                if (widget.showDelete) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: InkWell(
                        onTap: () => {deleteItem(widget.data.id)},
                        child:
                            const Icon(size: 16, CupertinoIcons.delete_simple)),
                  ),
                  SizedBox(width: 20),
                ],
                SizedBox(
                  width: 20,
                  height: 20,
                  child: InkWell(
                      onTap: () => {addFavourite(widget.data.id)},
                      child: Icon(
                          size: 16,
                          widget.data.isFavourite
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star)),
                ),
                const SizedBox(width: 20),
              ],
            )
          ]),
        ),
      ),
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

  void toTranslateDetail(TranslationItem data) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    ValueNotifier<double>? heightFactorNotifier;

    if (isVerticalUI) {
      // Create ValueNotifier before showing modal to persist state
      heightFactorNotifier = ValueNotifier<double>(defaultPannelSize);
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: !isVerticalUI, // Enable drag only for horizontal UI
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        builder: (context) {
          if (isVerticalUI) {
            final notifier = heightFactorNotifier!;
            return ValueListenableBuilder<double>(
              valueListenable: notifier,
              builder: (context, heightFactor, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: MediaQuery.of(context).size.height * heightFactor,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: getChild(context, data, null, (expand) {
                    notifier.value = expand ? maxPannelSize : defaultPannelSize;
                  }),
                );
              },
            );
          }
          return DraggableScrollableSheet(
              initialChildSize: defaultPannelSize,
              minChildSize: minPannelSize,
              maxChildSize: maxPannelSize,
              expand: false,
              controller: panelController,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return getChild(context, data, scrollController, null);
              });
        }).whenComplete(() {
      // Dispose ValueNotifier when modal closes
      heightFactorNotifier?.dispose();
    });
  }

  Widget getChild(
      BuildContext context,
      TranslationItem data,
      ScrollController? scrollController,
      Function(bool)? verticalToggleExpanded) {
    return SafeArea(
        child: TranslationDetailPane(
      data: data,
      scrollController: scrollController ?? ScrollController(),
      toggleExpaned: (expand) {
        if (scrollController == null && verticalToggleExpanded != null) {
          // Vertical UI: use the callback from StatefulBuilder
          verticalToggleExpanded(expand);
        } else if (scrollController != null) {
          // Horizontal UI: use DraggableScrollableController
          if (panelController.isAttached) {
            panelController.jumpTo(expand ? maxPannelSize : defaultPannelSize);
          }
        }
      },
      onDelete: () {
        deleteItem(widget.data.id);
        Navigator.pop(context);
      },
    ));
  }

  void copyText(TranslationItem data) async {
    String copyToastMsg = AppLocalizations.of(context)!.toastTextCopied;
    await Clipboard.setData(ClipboardData(text: data.result));
    ToastHelper.show(copyToastMsg);
  }

  void deleteItem(int id) {
    if (widget.onDelete != null) {
      widget.onDelete!(id);
    }
  }
}
