import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/faq_item.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FaqList extends StatefulWidget {
  static int typeSystem = 0;
  static int typeMembership = 1;
  final int type;
  const FaqList({super.key, required this.type});

  @override
  State<StatefulWidget> createState() {
    return FaqListState();
  }
}

class FaqListState extends State<FaqList> {
  static const _pageSize = 10;
  int page = 1;

  final PagingController<int, FaqItemData> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
        appBar: AbyAppBar(
          titleText: AppLocalizations.of(context)!.titleFaq,
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              CupertinoIcons.arrow_left,
            ),
          ),
        ),
        body: isVerticalUI
            ? Row(
                children: [
                  VerticalTitle(text: AppLocalizations.of(context)!.titleFaq),
                  Expanded(child: _buildListView(isVerticalUI)),
                ],
              )
            : _buildListView(isVerticalUI));
  }

  Widget _buildListView(bool isVerticalUI) {
    return PagedListView<int, FaqItemData>(
      pagingController: _pagingController,
      padding: isVerticalUI
          ? const EdgeInsets.only(right: 20)
          : const EdgeInsets.only(bottom: 20),
      scrollDirection: isVerticalUI ? Axis.horizontal : Axis.vertical,
      builderDelegate: PagedChildBuilderDelegate<FaqItemData>(
          firstPageErrorIndicatorBuilder: (context) {
        return const FirstPageErrorView();
      }, noItemsFoundIndicatorBuilder: (context) {
        return EmptyListIndicator(
            text: AppLocalizations.of(context)!.textListEmpty);
      }, itemBuilder: (context, item, index) {
        return FaqItem(id: index + 1, title: item.title, text: item.content);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      getFaqList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void getFaqList() {
    HttpHelper<FaqListResponse>(FaqListResponse.new).post(
      apigetFaqList,
      {
        'type': widget.type,
        'page': page,
        'limit': _pageSize,
      },
      onResponse: (response) {
        if (response.more) {
          final nextPageKey = page + 1;
          _pagingController.appendPage(response.list, nextPageKey);
        } else {
          _pagingController.appendLastPage(response.list);
        }
      },
      onError: (et, em) {
        //todo check
        _pagingController.error = em;
      },
    );
  }
}
