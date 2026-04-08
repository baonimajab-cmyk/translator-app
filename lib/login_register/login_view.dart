import 'dart:convert';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/err_msg_view.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/utils/device_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class LoginView extends StatefulWidget {
  final String email;
  final Function(bool success) callback;
  final Function() onForgotPassword;
  final Function() onRegisterNewAccount;
  const LoginView(
      {super.key,
      this.email = '',
      required this.callback,
      required this.onForgotPassword,
      required this.onRegisterNewAccount});

  @override
  State<StatefulWidget> createState() {
    return _LoginViewState();
  }
}

class _LoginViewState extends State<LoginView> {
  FocusNode focusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  bool obsecure = true;
  bool enableButton = false;
  bool loading = false;
  String errMsg = '';

  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();

  bool showClearButton = false;
  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      validateForms();
    });
    passwordController.addListener(() {
      validateForms();
    });
  }

  void validateForms() {
    setState(() {
      enableButton =
          emailController.text.isNotEmpty && passwordController.text.length > 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI ? _buildVerticalUI() : _buildHorizontalUI();
  }

  Widget _buildVerticalUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MongolTextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    focusNode: emailFocusNode,
                    cursorColor:
                        Theme.of(context).textSelectionTheme.cursorColor,
                    style: TextStyle(
                        height: 1.4,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    controller: emailController,
                    onSubmitted: (value) => onSubmit(),
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.hintEmail,
                        hintStyle: TextStyle(fontFamily: 'NotoSans'),
                        suffixIcon: IconButton(
                          onPressed: emailController.clear,
                          icon: Icon(
                            Icons.clear,
                            color: showClearButton
                                ? Theme.of(context)
                                    .textSelectionTheme
                                    .cursorColor
                                : Colors.transparent,
                          ),
                        )),
                  ),
                  const SizedBox(width: 20),
                  MongolTextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    focusNode: focusNode,
                    controller: passwordController,
                    obscureText: obsecure,
                    style: TextStyle(
                        height: 1.4,
                        fontSize: 14,
                        color:
                            Theme.of(context).textSelectionTheme.cursorColor),
                    onSubmitted: (value) => onSubmit(),
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
                          color:
                              Theme.of(context).textSelectionTheme.cursorColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      widget.onForgotPassword();
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: MongolText(
                        AppLocalizations.of(context)!.textForgotPassword,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSans',
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RedRoundedButton(
                  width: 60,
                  label: AppLocalizations.of(context)!.textButtonLogin,
                  loading: loading,
                  onClick: () => onSubmit(),
                  fill: true,
                ),
                const SizedBox(width: 20),
                GreyRoundedButton(
                  label: AppLocalizations.of(context)!.textRegisterNewAccount,
                  width: 60,
                  loading: false,
                  onClick: () {
                    widget.onRegisterNewAccount();
                  },
                  fill: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          focusNode: emailFocusNode,
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          style: TextStyle(
              height: 1.4,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface),
          controller: emailController,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onSubmitted: (value) => onSubmit(),
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.hintEmail,
              suffixIcon: IconButton(
                onPressed: emailController.clear,
                icon: Icon(
                  Icons.clear,
                  color: showClearButton
                      ? Theme.of(context).textSelectionTheme.cursorColor
                      : Colors.transparent,
                ),
              )),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          focusNode: focusNode,
          controller: passwordController,
          obscureText: obsecure,
          style: TextStyle(
              height: 1.4,
              fontSize: 14,
              color: Theme.of(context).textSelectionTheme.cursorColor),
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onSubmitted: (value) => onSubmit(),
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
        InkWell(
          onTap: () {
            widget.onForgotPassword();
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppLocalizations.of(context)!.textForgotPassword,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        errMsg.isEmpty ? Container() : ErrMsgView(errMsg: errMsg),
        const Spacer(),
        RedRoundedButton(
          label: AppLocalizations.of(context)!.textButtonLogin,
          loading: loading,
          onClick: () => onSubmit(),
          fill: true,
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            widget.onRegisterNewAccount();
          },
          child: Text(
            AppLocalizations.of(context)!.textRegisterNewAccount,
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
          ),
        )
      ],
    );
  }

  void onSubmit() {
    var email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.hintEmailInvalid;
      });
      return;
    }
    var pw = passwordController.text.trim();
    if (pw.isEmpty || pw.length < 6) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.textPasswordInvalid;
      });
      return;
    }
    setState(() {
      loading = true;
      errMsg = '';
    });
    login(email, pw);
  }

  void login(String email, String password) async {
    String passwordMd5 = md5.convert(utf8.encode(password)).toString();
    DeviceHelper helper = GetIt.I<DeviceHelper>();
    await helper.loadDeviceInfo();
    HttpHelper<LoginRegisterResponse>(LoginRegisterResponse.new).post(
      apiLogin,
      {
        'email': email,
        'password': passwordMd5,
        'device': helper.getJsonParam()
      },
      onResponse: (response) {
        setState(() {
          loading = false;
        });
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
        widget.callback(false);
      },
    );
  }
}
