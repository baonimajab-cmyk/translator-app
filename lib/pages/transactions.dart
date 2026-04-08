import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              for (TransactionItem item in transactions)
                TransactionItemView(data: item)
            ]),
          ),
        ));
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
