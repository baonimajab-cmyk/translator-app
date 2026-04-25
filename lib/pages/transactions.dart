import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/transaction_item.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TransactionListState();
  }
}

class _TransactionListState extends State<TransactionList> {
  List<TransactionItem> transactions = [];
  @override
  Widget build(BuildContext context) {
    final bool isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
        appBar: AbyAppBar(
          titleText: AppLocalizations.of(context)!.textPurchaseHistory,
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              CupertinoIcons.arrow_left,
            ),
          ),
        ),
        body: Container(
          child: isVerticalUI
              ? Row(
                  children: [
                    VerticalTitle(
                        text:
                            AppLocalizations.of(context)!.textPurchaseHistory),
                    Expanded(child: _buildScrollableList(true)),
                  ],
                )
              : _buildScrollableList(false),
        ));
  }

  /// 竖排传统蒙文：横向滚动 + [Row]；横排：纵向滚动 + [Column]。
  Widget _buildScrollableList(bool isVerticalUI) {
    return SingleChildScrollView(
      scrollDirection: isVerticalUI ? Axis.horizontal : Axis.vertical,
      padding: isVerticalUI
          ? const EdgeInsets.only(right: 20)
          : const EdgeInsets.only(bottom: 20),
      child: isVerticalUI
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (TransactionItem item in transactions)
                  TransactionItemView(data: item)
              ],
            )
          : Column(
              children: [
                for (TransactionItem item in transactions)
                  TransactionItemView(data: item)
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    getTransactions();
  }

  void getTransactions() {
    HttpHelper<TransactionListResponse>(TransactionListResponse.new).post(
      apiGetTransactions,
      {
        'type': 0,
        'page': 0,
        'limit': 0,
      },
      onResponse: (response) {
        setState(() {
          transactions = response.list;
        });
      },
      onError: (et, em) {
        if (et >= 1000) {
          showLoginAlert();
        }
      },
    );
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
    });
  }
}
