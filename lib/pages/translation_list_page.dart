import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/icon_assets_helper.dart';
import 'package:abiya_translator/db/db_helper.dart';
import 'package:abiya_translator/db/history_model.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/translation_item_view.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mongol/mongol.dart';

class TranslationListPage extends StatefulWidget {
  static int typeHistory = 0;
  static int typeFavourite = 1;
  static int typePhrases = 2;

  final int listType;
  final int phraseCategoryId;
  final String phraseCategoryName;
  final String phraseCategoryIcon;
  final String from;
  final String to;
  const TranslationListPage(
      {super.key,
      required this.listType,
      this.phraseCategoryId = 0,
      this.phraseCategoryName = '',
      this.phraseCategoryIcon = '',
      this.from = 'en',
      this.to = 'zh'});

  @override
  State<StatefulWidget> createState() {
    return TranslationListPageState();
  }
}

class TranslationListPageState extends State<TranslationListPage> {
  static const _pageSize = 10;

  final PagingController<int, TranslationItem> _pagingController =
      PagingController(firstPageKey: 1);

  List<TranslationItem> items = [];
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      getHistoryList(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
        appBar: AbyAppBar(
          //to set the status bar color
          titleText: widget.listType == TranslationListPage.typePhrases
              ? widget.phraseCategoryName
              : (widget.listType == TranslationListPage.typeFavourite
                  ? AppLocalizations.of(context)!.textFavourite
                  : AppLocalizations.of(context)!.textHitory),
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              CupertinoIcons.arrow_left,
            ),
          ),
          actions: widget.listType == TranslationListPage.typeHistory
              ? [
                  IconButton(
                    onPressed: () => {showClearHistoryAlert()},
                    icon: const Icon(size: 18, CupertinoIcons.paintbrush),
                  ),
                ]
              : [],
        ),
        body: isVerticalUI
            ? Row(children: [
                _buildVerticalTitle(widget.listType),
                Expanded(child: _buildList(true)),
              ])
            : _buildList(isVerticalUI));
  }

  Widget _buildVerticalTitle(int listType) {
    if (listType == TranslationListPage.typePhrases) {
      return PhracebookTitle(
          text: widget.phraseCategoryName, icon: widget.phraseCategoryIcon);
    } else if (listType == TranslationListPage.typeFavourite) {
      return VerticalTitle(text: AppLocalizations.of(context)!.textFavourite);
    } else {
      return VerticalTitle(text: AppLocalizations.of(context)!.textHitory);
    }
  }

  Widget _buildList(bool isVerticalUI) {
    return PagedListView<int, TranslationItem>(
      scrollDirection: isVerticalUI ? Axis.horizontal : Axis.vertical,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<TranslationItem>(
        firstPageErrorIndicatorBuilder: (context) => const FirstPageErrorView(),
        itemBuilder: (context, item, index) => TranslationItemView(
            data: item,
            showDelete: widget.listType != TranslationListPage.typePhrases,
            onDelete: widget.listType != TranslationListPage.typePhrases
                ? (id) => {deleteHistoryItem(id)}
                : null),
        noItemsFoundIndicatorBuilder: (context) {
          String emptyString = '';
          if (widget.listType == TranslationListPage.typeHistory) {
            emptyString = AppLocalizations.of(context)!.textNoHistory;
          } else if (widget.listType == TranslationListPage.typeFavourite) {
            emptyString = AppLocalizations.of(context)!.textNoFavourites;
          } else {
            emptyString = AppLocalizations.of(context)!.textListEmpty;
          }
          return EmptyListIndicator(text: emptyString);
        },
        noMoreItemsIndicatorBuilder: (context) {
          return const SizedBox(
            height: 20,
          );
        },
      ),
    );
  }

  void getLocalHistoryList() async {
    DbHelper helper = DbHelper();
    List<History> historires = await helper.historyList();
    List<TranslationItem> items = [];
    for (History h in historires) {
      // Logger.log(h.toString());
      items.add(TranslationItem.fromLocal(
          h.id, h.source, h.target, h.time, h.from, h.to));
    }
    _pagingController.appendLastPage(items);
  }

  void getHistoryList(int page) {
    if (widget.listType == TranslationListPage.typePhrases) {
      HttpHelper<TranslationListResponse>(TranslationListResponse.new).post(
        apigetPhraseList,
        {
          'page': page,
          'limit': _pageSize,
          'category_id': widget.phraseCategoryId,
          'source': widget.from,
          'target': widget.to
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
    } else {
      UserManager manager = GetIt.I<UserManager>();
      UserInfo? user = manager.getCurrentUser();
      if (user == null) {
        //not logged in
        getLocalHistoryList();
      } else {
        HttpHelper<TranslationListResponse>(TranslationListResponse.new).post(
          apiHistoryList,
          {
            'page': page,
            'limit': _pageSize,
            'favourite': widget.listType == TranslationListPage.typeFavourite
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
            if (et >= 1000) {
              showLoginAlert();
              return;
            }
            _pagingController.error = em;
          },
        );
      }
    }
  }

  void showLoginAlert() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertLoginExpireTitle,
        AppLocalizations.of(context)!.alertLoginExpireMsg,
        AppLocalizations.of(context)!.textButtonOK,
        AppLocalizations.of(context)!.textButtonCancel, () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return const LoginRegisterPage();
        }),
      );
    }, onCancel: () {
      UserManager manager = GetIt.I<UserManager>();
      manager.logout();
      Navigator.pop(context); //back go home
    });
  }

  void showClearHistoryAlert() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.textClearHitory,
        AppLocalizations.of(context)!.textClearHitoryMsg,
        AppLocalizations.of(context)!.textButtonOK,
        AppLocalizations.of(context)!.textButtonCancel, () {
      clearHistory();
      Navigator.pop(context);
    });
  }

  void clearHistory() {
    DbHelper().clearHistory();
    HttpHelper<CommonReponse>(CommonReponse.new).post(
      apiClearHistory,
      {},
      onResponse: (response) {
        _pagingController.itemList!.clear();
        _pagingController.refresh();
      },
      onError: (et, em) {},
    );
  }

  void deleteHistoryItem(int id) {
    if (GetIt.I<UserManager>().getCurrentUser() == null) {
      //user not logged in
      DbHelper().deleteHistory(id);
      removeItemFromList(id);
      return;
    }
    HttpHelper<DeleteHistoryResponse>(DeleteHistoryResponse.new).post(
      apiDeleteTranslateHistory,
      {
        'id': id,
      },
      onResponse: (response) {
        if (response.success && _pagingController.itemList != null) {
          removeItemFromList(response.deletedID);
        }
      },
      onError: (et, em) {
        ToastHelper.show(em);
      },
    );
  }

  void removeItemFromList(int id) {
    if (_pagingController.itemList != null) {
      _pagingController.itemList =
          _pagingController.itemList!.where((item) => item.id != id).toList();
    }
  }
}

class PhracebookTitle extends StatelessWidget {
  final String text;
  final String icon;
  const PhracebookTitle({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(IconAssetsHelper.getIcon(icon))),
            const SizedBox(height: 16),
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
