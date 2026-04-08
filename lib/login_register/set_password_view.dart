import 'dart:convert';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/err_msg_view.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:abiya_translator/pages/web_view.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class SetPasswordView extends StatefulWidget {
  final bool changePassword;
  final bool deleteAccount;
  final String email;
  final Function(bool success) callback;
  final bool forgotPassword;
  const SetPasswordView({
    super.key,
    required this.changePassword,
    required this.deleteAccount,
    required this.email,
    required this.callback,
    this.forgotPassword = false,
  });
  @override
  State<StatefulWidget> createState() {
    return _SetPasswordViewState();
  }
}

class _SetPasswordViewState extends State<SetPasswordView> {
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  String errMsg = '';

  bool agreementChecked = false;

  bool obsecure = true;

  @override
  Widget build(BuildContext context) {
    final isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI ? _buildVerticalUI() : _buildHorizontalUI();
  }

  Widget _buildVerticalUI() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 60),
        MongolTextField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          focusNode: passwordFocusNode,
          controller: passwordController,
          obscureText: obsecure,
          style: TextStyle(
              height: 1.4,
              fontSize: 14,
              color: Theme.of(context).textSelectionTheme.cursorColor),
          onSubmitted: (value) => {submit()},
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.hintPassword,
            hintStyle: TextStyle(fontFamily: 'NotoSans'),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obsecure = !obsecure;
                });
              },
              icon: Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).textSelectionTheme.cursorColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        widget.changePassword || widget.deleteAccount
            ? Container()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                        shape: const CircleBorder(),
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.primary;
                          }
                          return Colors.white12;
                        }),
                        side: BorderSide(
                            width: UiHelper.getDividerWidth(context)),
                        value: agreementChecked,
                        onChanged: (checked) {
                          setState(() {
                            agreementChecked = checked!;
                          });
                        }),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: MongolText.rich(
                      style: TextStyle(fontFamily: 'NotoSans'),
                      TextSpan(
                          text: AppLocalizations.of(context)!
                              .textSignInAgreementPrefix,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 48, 48, 48),
                              fontSize: 14),
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textUserAgreement,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const WebView(
                                                  url:
                                                      'https://abiya-tech.com/app/user_agreement',
                                                )));
                                  },
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            TextSpan(
                                text: AppLocalizations.of(context)!.textAnd),
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textPrivacyStatement,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const WebView(
                                                  url:
                                                      'https://abiya-tech.com/app/privacy_statement',
                                                )));
                                  },
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textSignInAgreementSuffix),
                          ]),
                    ),
                  ),
                ],
              ),
        Align(
          alignment: Alignment.bottomRight,
          child: RedRoundedButton(
              label: widget.changePassword
                  ? AppLocalizations.of(context)!.textButtonSubmit
                  : widget.deleteAccount
                      ? AppLocalizations.of(context)!.textButtonDeleteAccount
                      : AppLocalizations.of(context)!.textButtonSignUp,
              fill: true,
              loading: loading,
              onClick: () {
                submit();
              }),
        ),
      ],
    );
  }

  Widget _buildHorizontalUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          focusNode: passwordFocusNode,
          controller: passwordController,
          obscureText: obsecure,
          style: TextStyle(
              height: 1.4,
              fontSize: 14,
              color: Theme.of(context).textSelectionTheme.cursorColor),
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onSubmitted: (value) => {submit()},
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.hintPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obsecure = !obsecure;
                });
              },
              icon: Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).textSelectionTheme.cursorColor,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        errMsg.isEmpty ? Container() : ErrMsgView(errMsg: errMsg),
        const Spacer(),
        widget.changePassword || widget.deleteAccount
            ? Container()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                        shape: const CircleBorder(),
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.primary;
                          }
                          return Colors.white12;
                        }),
                        side: BorderSide(
                            width: UiHelper.getDividerWidth(context)),
                        value: agreementChecked,
                        onChanged: (checked) {
                          setState(() {
                            agreementChecked = checked!;
                          });
                        }),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                          text: AppLocalizations.of(context)!
                              .textSignInAgreementPrefix,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 48, 48, 48),
                              fontSize: 14),
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textUserAgreement,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const WebView(
                                                  url:
                                                      'https://abiya-tech.com/app/user_agreement',
                                                )));
                                  },
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            TextSpan(
                                text: AppLocalizations.of(context)!.textAnd),
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textPrivacyStatement,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const WebView(
                                                  url:
                                                      'https://abiya-tech.com/app/privacy_statement',
                                                )));
                                  },
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .textSignInAgreementSuffix),
                          ]),
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 20),
        RedRoundedButton(
            label: widget.changePassword
                ? AppLocalizations.of(context)!.textButtonSubmit
                : widget.deleteAccount
                    ? AppLocalizations.of(context)!.textButtonDeleteAccount
                    : AppLocalizations.of(context)!.textButtonSignUp,
            fill: true,
            loading: loading,
            onClick: () {
              submit();
            }),
        const SizedBox(height: 34)
      ],
    );
  }

  void submit() async {
    if (!agreementChecked && !widget.changePassword && !widget.deleteAccount) {
      showAgreementDialog();
      return;
    }
    var pw = passwordController.value.text.trim();
    if (pw.isEmpty) {
      return;
    }
    if (pw.length < 6) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.textPasswordLengthNotEnough;
      });
      return;
    }
    setState(() {
      loading = true;
      errMsg = '';
    });
    if (widget.deleteAccount) {
      String passwordMd5 = md5.convert(utf8.encode(pw)).toString();
      HttpHelper<CommonReponse>(CommonReponse.new).post(
          apiDeleteAccount, {'password': passwordMd5}, onResponse: (reponse) {
        UserManager manager = GetIt.I<UserManager>();
        manager.logout();
        showAccountDeletedDialog();
      }, onError: (et, em) {
        setState(() {
          loading = false;
          errMsg = em;
        });
      });
    } else if (widget.forgotPassword) {
      HttpHelper<CommonReponse>(CommonReponse.new).post(
        apiFogotPassword,
        {
          'email': widget.email,
          'password': pw,
        },
        onResponse: (response) {
          widget.callback(true);
        },
        onError: (et, em) {
          setState(() {
            errMsg = em;
            loading = false;
          });
        },
      );
    } else {
      HttpHelper<LoginRegisterResponse>(LoginRegisterResponse.new).post(
        widget.changePassword ? apiChangePassword : apiRegister,
        {
          'email': widget.email,
          'password': pw,
        },
        onResponse: (response) {
          UserManager manager = GetIt.I<UserManager>();
          UserInfo info = response.info;
          manager.saveUser(info);
          widget.callback(true);
        },
        onError: (et, em) {
          setState(() {
            errMsg = em;
            loading = false;
          });
        },
      );
    }
  }

  void showAccountDeletedDialog() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertAccountDeletedTitle,
        AppLocalizations.of(context)!.alertAccountDeleted,
        AppLocalizations.of(context)!.textButtonOK,
        '', () {
      Navigator.pop(context); //to dismiss the alert dialog
      Navigator.pop(context); //to dismiss the login page
      Navigator.pop(context); // to dismiss the personal info page
    });
  }

  void showAgreementDialog() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertCheckAgreementTitle,
        AppLocalizations.of(context)!.alertCheckAgreement,
        AppLocalizations.of(context)!.textButtonAgree,
        AppLocalizations.of(context)!.textButtonCancel, () {
      Navigator.pop(context);
      setState(() {
        agreementChecked = true;
      });
    });
  }
}
