import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/pages/faq.dart';
import 'package:abiya_translator/pages/feedback.dart';
import 'package:abiya_translator/pages/theme_setting.dart';
import 'package:abiya_translator/pages/web_view.dart';
import 'package:abiya_translator/utils/constants.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/language_selection_pane.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mongol/mongol.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {
  int currentLanguageId = -1;
  LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
  SystemSetting systemSetting = GetIt.I<SystemSetting>();
  String version = '';
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        version = info.version;
      });
    });
    for (LanguageItem lan in languageSetting.languages) {
      if (lan.shortName.toLowerCase() == systemSetting.localeName) {
        currentLanguageId = lan.id;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.titleSettings,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(CupertinoIcons.arrow_left),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () => onClickShare(),
        //     icon: const Icon(Icons.share_outlined),
        //   ),
        // ],
      ),
      body: isVerticalUI
          ? Row(
              children: [
                VerticalTitle(
                    text: AppLocalizations.of(context)!.titleSettings),
                Expanded(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildList(context),
                            _buildVerticalVersionInfo(context)
                          ],
                        )))
              ],
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildList(context)),
                  _buildHorizontalVersionInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildList(BuildContext context) {
    return AdaptiveListView(children: [
      ListItem(
        icon: 'assets/images/icons/icon_setting_language.png',
        text: AppLocalizations.of(context)!.textLanguage,
        onClick: () {
          showMaterialModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              expand: false,
              builder: (context) => LanguageSelectionPane(
                    current: currentLanguageId,
                    onLanguageSelect: onLanguageSelect,
                    ignoreSupport: true,
                    languageList: languageSetting.languages,
                  ));
        },
      ),
      ListGap(),
      ListItem(
        icon: 'assets/images/icons/icon_setting_theme.png',
        text: AppLocalizations.of(context)!.textTheme,
        onClick: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ThemeSettingPage()));
        },
      ),
      ListGap(),
      ListGroup(dividerMargin: 48, children: [
        ListItem(
          icon: 'assets/images/icons/icon_setting_user_agreement.png',
          text: AppLocalizations.of(context)!.textUserAgreement,
          onClick: () {
            showCupertinoModalBottomSheet(
                context: context,
                enableDrag: false,
                expand: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    const WebView(url: Constants.userAgreementUrl));
          },
        ),
        ListItem(
          icon: 'assets/images/icons/icon_setting_privacy_statement.png',
          text: AppLocalizations.of(context)!.textPrivacyStatement,
          onClick: () {
            showCupertinoModalBottomSheet(
                context: context,
                expand: true,
                enableDrag: false,
                backgroundColor: Colors.transparent,
                builder: (context) => const WebView(
                      url: Constants.privacyStatementUrl,
                    ));
          },
        ),
      ]),
      ListGap(),
      ListGroup(
        dividerMargin: 48,
        children: [
          ListItem(
            icon: 'assets/images/icons/icon_setting_faq.png',
            text: AppLocalizations.of(context)!.textFaq,
            onClick: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FaqList(type: FaqList.typeSystem))),
          ),
          ListItem(
            icon: 'assets/images/icons/icon_setting_feedback.png',
            text: AppLocalizations.of(context)!.textFeedback,
            onClick: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackPage()));
            },
          ),
        ],
      ),
    ]);
  }

  Widget _buildVerticalVersionInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          MongolText(
            '${AppLocalizations.of(context)!.textVersion}$version',
            style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(
            height: 10,
          ),
          MongolText(
            AppLocalizations.of(context)!.textCompanyName,
            textAlign: MongolTextAlign.center,
            style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(
            height: 10,
          ),
          MongolText(
            AppLocalizations.of(context)!.textCopyright,
            style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalVersionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            '${AppLocalizations.of(context)!.textVersion}$version',
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.textCompanyName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.textCopyright,
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }

  void onLanguageSelect(int language) {
    LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
    for (LanguageItem item in languageSetting.languages) {
      if (item.id == language) {
        systemSetting.setLocaleSetting(item.shortName.toLowerCase());
        setState(() {
          currentLanguageId = item.id;
        });
      }
    }
  }

  void onClickShare() {
    // Share.share('https://www.abiya-tech.com/app', subject: 'Abiya Translator');
  }
}
