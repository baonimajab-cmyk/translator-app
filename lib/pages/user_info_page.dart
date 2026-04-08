import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/pages/profession_selection_page.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserInfoPageState();
  }
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserManager manager = GetIt.I<UserManager>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.titleUserInfo,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(
            CupertinoIcons.arrow_left,
          ),
        ),
      ),
      body: ValueListenableBuilder<UserInfo?>(
          valueListenable: manager.notifier,
          builder: (context, info, child) {
            if (info == null) {
              return Container();
            }
            return UiHelper.isVerticalUI()
                ? Row(
                    children: [
                      VerticalTitle(
                          text: AppLocalizations.of(context)!.titleUserInfo),
                      Expanded(child: _buldList(info)),
                    ],
                  )
                : _buldList(info);
          }),
    );
  }

  Widget _buldList(UserInfo info) {
    return AdaptiveListView(children: [
      ListGroup(dividerMargin: 16, children: [
        ListItem(
          icon: '',
          text: AppLocalizations.of(context)!.textUserName,
          extra: info.name,
        ),
        if (info.email.isNotEmpty)
          ListItem(
              icon: '',
              text: AppLocalizations.of(context)!.hintEmail,
              extra: info.email),
        ListItem(
            icon: '',
            text: AppLocalizations.of(context)!.textProfessionSelection,
            extra: '',
            onClick: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfessionSelectionPage()));
            }),
      ]),
      ListGap(),
      ListGroup(dividerMargin: 16, children: [
        ListItem(
          icon: '',
          text: AppLocalizations.of(context)!.textChangePassword,
          extra: '',
          onClick: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginRegisterPage(
                          changePassword: true,
                        )));
          },
        ),
        ListItem(
          icon: '',
          text: AppLocalizations.of(context)!.textDeleteAccount,
          extra: '',
          onClick: () => showDeleteAccountAlert(),
        ),
        ListItem(
          icon: '',
          text: AppLocalizations.of(context)!.textLogout,
          extra: '',
          onClick: () => logout(),
        ),
      ]),
    ]);
  }

  void logout() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertLogoutTitle,
        AppLocalizations.of(context)!.alertLogoutMsg,
        AppLocalizations.of(context)!.textButtonOK,
        AppLocalizations.of(context)!.textButtonCancel, () {
      manager.logout();
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void showDeleteAccountAlert() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertAccountDeletionTitle,
        AppLocalizations.of(context)!.alertAccountDeletionMsg,
        AppLocalizations.of(context)!.textButtonOK,
        AppLocalizations.of(context)!.textButtonCancel, () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginRegisterPage(
                  deleteAccount: true,
                )),
      );
    });
  }

  void showUserNameInput() {
    Alert.showInput(
        context,
        AppLocalizations.of(context)!.alertInputPasswordTitle,
        AppLocalizations.of(context)!.alertInputPasswordMsg,
        AppLocalizations.of(context)!.textButtonOK,
        AppLocalizations.of(context)!.textButtonCancel, (value) {
      Navigator.pop(context);
    }, hint: AppLocalizations.of(context)!.hintUserName);
  }

  // showVerificationCodeInputPrompt() {
  //   Alert.showInput(
  //       context,
  //       AppLocalizations.of(context)!.alertInputPasswordTitle,
  //       AppLocalizations.of(context)!.alertInputPasswordMsg,
  //       AppLocalizations.of(context)!.textButtonOK,
  //       AppLocalizations.of(context)!.textButtonCancel, (value) {
  //     Navigator.pop(context);
  //     deleteAccount(value);
  //   }, obsecure: true, hint: AppLocalizations.of(context)!.hintPassword);
  // }
}
