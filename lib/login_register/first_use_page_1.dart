import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/first_use_page_2.dart';
import 'package:abiya_translator/pages/web_view.dart';
import 'package:abiya_translator/utils/device_helper.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class FirstUsePageOne extends StatefulWidget {
  const FirstUsePageOne({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FirstUsePageOneState();
  }
}

class _FirstUsePageOneState extends State<FirstUsePageOne> {
  bool agreementChecked = false;

  _FirstUsePageOneState();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((context) {
      showAgreementDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AbyAppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Container(),
          shape: const Border(),
          actions: const [],
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor:
                GetIt.I<SystemSetting>().isDarkMode(context)
                    ? Colors.black
                    : Colors.white,
          )),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: SizedBox(
                    height: 100,
                    child: Image.asset(
                        GetIt.I<SystemSetting>().isDarkMode(context)
                            ? 'assets/images/register_banner_dark.png'
                            : 'assets/images/register_banner.png')),
              ),
              const SizedBox(height: 50),
              UiHelper.isVerticalUI()
                  ? _buildVerticalUI(context)
                  : _buildHorizontalUI(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalUI(BuildContext context) {
    return Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
          Container(
            padding: const EdgeInsets.all(10),
            height: 220,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: MongolText(
              AppLocalizations.of(context)!.textAppIntroduction,
              textAlign: MongolTextAlign.top,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 100,
                  child: MongolText.rich(TextSpan(
                      text: AppLocalizations.of(context)!
                          .textFirstUseAgreementPrefix,
                      style: TextStyle(
                          fontFamily: 'NotoSans',
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 14),
                      children: [
                        TextSpan(
                            text:
                                AppLocalizations.of(context)!.textUserAgreement,
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
                                color: Theme.of(context).colorScheme.primary)),
                        TextSpan(text: AppLocalizations.of(context)!.textAnd),
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
                                color: Theme.of(context).colorScheme.primary)),
                        TextSpan(
                            text: AppLocalizations.of(context)!
                                .textFirstUseAgreementSuffix),
                      ])),
                ),
                MongolFilledButton(
                    onPressed: onClickContinue,
                    child: MongolText(
                      style: TextStyle(
                          fontFamily: 'NotoSans', color: Colors.white),
                      AppLocalizations.of(context)!.textButtonContinue,
                    ))
              ],
            ),
          ),
          SizedBox(height: 20),
        ]));
  }

  Widget _buildHorizontalUI(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              AppLocalizations.of(context)!.textAppIntroduction,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Spacer(),
          Row(
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
                    side: BorderSide(width: UiHelper.getDividerWidth(context)),
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
                          .textFirstUseAgreementPrefix,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 14),
                      children: [
                        TextSpan(
                            text:
                                AppLocalizations.of(context)!.textUserAgreement,
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
                                color: Theme.of(context).colorScheme.primary)),
                        TextSpan(text: AppLocalizations.of(context)!.textAnd),
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
                                color: Theme.of(context).colorScheme.primary)),
                        TextSpan(
                            text: AppLocalizations.of(context)!
                                .textFirstUseAgreementSuffix),
                      ]),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          RedRoundedButton(
            label: AppLocalizations.of(context)!.textButtonContinue,
            onClick: () {
              onClickContinue();
            },
            loading: false,
            fill: true,
          ),
          const SizedBox(
            height: 34,
          )
        ],
      ),
    );
  }

  void onClickContinue() {
    if (!agreementChecked) {
      showAgreementDialog();
      return;
    }
    //initialize device helper here, after user agreed to the
    //privacy statement and user agreement
    if (!GetIt.I.isRegistered<DeviceHelper>()) {
      GetIt.I.registerSingleton<DeviceHelper>(DeviceHelper());
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const FirstUsePageTwo();
    }));
  }

  Widget _buildVerticalAlertContent(BuildContext context) {
    return MongolText.rich(TextSpan(
      children: [
        TextSpan(
          text: AppLocalizations.of(context)!.textFullDocumentOfPrefix,
          style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        TextSpan(
          text: AppLocalizations.of(context)!.textAgreementDialogContent,
          style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        TextSpan(
          text: AppLocalizations.of(context)!.textReadFullDocumentOfSuffix,
          style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    ));
  }

  Widget _buildHorizontalAlertContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.textAgreementDialogContent,
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.textFullDocumentOfPrefix,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14),
              children: [
                TextSpan(
                    text: AppLocalizations.of(context)!.textUserAgreement,
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
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(text: AppLocalizations.of(context)!.textAnd),
                TextSpan(
                    text: AppLocalizations.of(context)!.textPrivacyStatement,
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
                        color: Theme.of(context).colorScheme.primary)),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .textReadFullDocumentOfSuffix),
              ]),
        )
      ],
    );
  }

  void showAgreementDialog() {
    Widget content = UiHelper.isVerticalUI()
        ? _buildVerticalAlertContent(context)
        : _buildHorizontalAlertContent(context);
    Alert.showContent(
        context,
        AppLocalizations.of(context)!.alertCheckAgreementTitle,
        content,
        AppLocalizations.of(context)!.textButtonAgreeAndContinue,
        AppLocalizations.of(context)!.textButtonDecline, () {
      Navigator.pop(context);
      setState(() {
        agreementChecked = true;
      });
    });
  }
}
