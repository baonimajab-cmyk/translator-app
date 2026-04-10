import 'dart:async';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/err_msg_view.dart';
import 'package:abiya_translator/widgets/get_code_button.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;
  final String action;
  final Function(String email, bool success) callback;

  const VerifyEmailView({
    super.key,
    required this.callback,
    required this.action,
    this.email = '',
  });

  @override
  State<StatefulWidget> createState() {
    return _VerifyCodeView();
  }
}

class _VerifyCodeView extends State<VerifyEmailView> {
  bool loading = false;
  bool getCodeLoading = false;
  FocusNode focusNode = FocusNode();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  bool showClearButton = false;
  int countDownSeconds = 0;
  String errMsg = '';
  String email = '';

  Timer? timer;
  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    emailController.addListener(() {
      setState(() {
        showClearButton =
            emailController.text.isNotEmpty && widget.email.isEmpty;
      });
    });
    emailFocusNode.addListener(() {
      if (emailFocusNode.hasFocus) {
        setState(() {
          errMsg = '';
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI ? _buildVerticalUI() : _buildHorizontalUI();
  }

  Widget _buildVerticalUI() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MongolTextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              readOnly: widget.email.isNotEmpty,
              focusNode: emailFocusNode,
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              style: TextStyle(
                  height: 1.4,
                  fontSize: 14,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onSurface),
              controller: emailController,
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
            const SizedBox(width: 20),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: MongolTextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    focusNode: focusNode,
                    controller: codeController,
                    style: TextStyle(
                        height: 1.4,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    onSubmitted: (value) =>
                        {getVerificationCode(emailController.text.trim())},
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.hintVerificationCode,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GetCodeButton(
                      label: countDownSeconds > 0
                          ? '${countDownSeconds}s'
                          : AppLocalizations.of(context)!
                              .textButtonGetVerificationCode,
                      color: countDownSeconds > 0
                          ? GetIt.I<SystemSetting>().isDarkMode(context)
                              ? Colors.white10
                              : Theme.of(context).hintColor
                          : Theme.of(context).colorScheme.primary,
                      boldText: countDownSeconds > 0 ? false : true,
                      loading: getCodeLoading,
                      onClick: () {
                        if (countDownSeconds == 0) {
                          getVerificationCode(emailController.text.trim());
                        }
                      }),
                )
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: RedRoundedButton(
            label: AppLocalizations.of(context)!.textButtonVerify,
            loading: loading,
            onClick: () => verifyCode(),
            fill: true,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          readOnly: widget.email.isNotEmpty,
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
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: codeController,
                style: TextStyle(
                    height: 1.4,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onSubmitted: (value) =>
                    {getVerificationCode(emailController.text.trim())},
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.hintVerificationCode,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: GetCodeButton(
                  label: countDownSeconds > 0
                      ? '${countDownSeconds}s'
                      : AppLocalizations.of(context)!
                          .textButtonGetVerificationCode,
                  color: countDownSeconds > 0
                      ? GetIt.I<SystemSetting>().isDarkMode(context)
                          ? Colors.white10
                          : Theme.of(context).hintColor
                      : Theme.of(context).colorScheme.primary,
                  boldText: countDownSeconds > 0 ? false : true,
                  loading: getCodeLoading,
                  onClick: () {
                    if (countDownSeconds == 0) {
                      getVerificationCode(emailController.text.trim());
                    }
                  }),
            )
          ],
        ),
        const SizedBox(height: 20),
        errMsg.isEmpty ? Container() : ErrMsgView(errMsg: errMsg),
        const Spacer(),
        RedRoundedButton(
          label: AppLocalizations.of(context)!.textButtonVerify,
          loading: loading,
          onClick: () => verifyCode(),
          fill: true,
        ),
        const SizedBox(
          height: 34,
        )
      ],
    );
  }

  void verifyCode() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.hintEmailInvalid;
      });
      return;
    }
    String code = codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.textVerificationCodeEmpty;
      });
      return;
    }
    setState(() {
      loading = true;
    });

    HttpHelper<VerifyCodeResponse>(VerifyCodeResponse.new).post(
        apiVerifyCode, {'email': email, 'code': code}, onResponse: (response) {
      setState(() {
        loading = false;
      });
      if (response.errCode == 0 && response.verified) {
        widget.callback(email, true);
      } else {
        widget.callback(email, false);
        setState(() {
          errMsg = response.errMsg;
        });
      }
    }, onError: (et, em) {
      if (UiHelper.isVerticalUI()) {
        ToastHelper.show(em);
        return;
      }
      setState(() {
        loading = false;
        errMsg = em;
      });
    });
  }

  void startCountDown() {
    countDownSeconds = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countDownSeconds--;
        if (countDownSeconds == 0) {
          timer.cancel();
        }
      });
    });
  }

  void getVerificationCode(String email) async {
    if (email.isEmpty) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.hintEmailInvalid;
      });
      return;
    }
    setState(() {
      getCodeLoading = true;
    });
    HttpHelper<CommonReponse>(CommonReponse.new).post(
      apiGetVerificationCode,
      {'email': email, 'action': widget.action},
      onResponse: (response) {
        setState(() {
          getCodeLoading = false;
          startCountDown();
          errMsg = '';
        });
      },
      onError: (et, em) {
        setState(() {
          getCodeLoading = false;
          errMsg = em;
        });
      },
    );
  }
}
