import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class CheckEmailView extends StatefulWidget {
  final Function(String email, bool registered) callback;
  const CheckEmailView({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() {
    return _CheckEmailViewState();
  }
}

class _CheckEmailViewState extends State<CheckEmailView> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  bool showClearButton = false;
  bool loading = false;
  String errMsg = '';
  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {
        showClearButton = emailController.text.isNotEmpty;
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          focusNode: emailFocusNode,
          cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          controller: emailController,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onSubmitted: (value) => {checkEmail(emailController.text.trim())},
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
        errMsg.isEmpty
            ? Container()
            : Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(12, 255, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Text(
                  errMsg,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14),
                ),
              ),
        const Spacer(),
        RedRoundedButton(
            label: AppLocalizations.of(context)!.textButtonNext,
            loading: loading,
            onClick: () => {checkEmail(emailController.text.trim())}),
        const SizedBox(
          height: 34,
        )
      ],
    );
  }

  void checkEmail(String email) async {
    if (email.isEmpty || !EmailValidator.validate(email)) {
      setState(() {
        errMsg = AppLocalizations.of(context)!.hintEmailInvalid;
      });
      return;
    }
    setState(() {
      loading = true;
      errMsg = '';
    });

    HttpHelper<CheckEmailResponse>(CheckEmailResponse.new).post(
      apiCheckEmail,
      {'email': email},
      onResponse: (response) {
        if (response.registred) {
          setState(() {
            loading = false;
          });
          widget.callback(email, true);
        } else {
          widget.callback(email, false);
        }
      },
      onError: (et, em) {
        setState(() {
          loading = false;
          errMsg = em;
        });
      },
    );
  }
}
