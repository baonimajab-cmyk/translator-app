import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:abiya_translator/pages/home.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/widgets/language_item.dart';
import 'package:abiya_translator/widgets/language_selection_pane.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mongol/mongol.dart';

class FirstUsePageTwo extends StatefulWidget {
  const FirstUsePageTwo({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FirstUsePageTwoState();
  }
}

class _FirstUsePageTwoState extends State<FirstUsePageTwo> {
  LanguageItem? currentLanguage;
  LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
  SystemSetting setting = GetIt.I<SystemSetting>();
  _FirstUsePageTwoState();
  @override
  void initState() {
    super.initState();
    for (LanguageItem lan in languageSetting.languages) {
      if (lan.shortName.toLowerCase() == setting.localeName) {
        currentLanguage = lan;
        break;
      }
    }
    if (currentLanguage == null) {
      //no matching languages selected
      //set default language to English
      for (LanguageItem lan in languageSetting.languages) {
        if (lan.shortName.toLowerCase() == 'en') {
          currentLanguage = lan;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AbyAppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const Border(),
        title: Container(),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: GetIt.I<SystemSetting>().isDarkMode(context)
              ? Colors.black
              : Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
            Expanded(
                child: UiHelper.isVerticalUI()
                    ? _buildVerticalUI(context)
                    : _buildHorizontalUI(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalUI(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
          child: SizedBox(
            height: 100,
            child: MongolText(
              AppLocalizations.of(context)!.textSelectLanagueFirst,
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (currentLanguage == null) ...[
          SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Theme.of(context).hintColor)),
          const Spacer(),
        ] else
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        border: BoxBorder.symmetric(
                            vertical: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: UiHelper.getDividerWidth(context)))),
                    child: LanguageItemView(
                        data: currentLanguage!,
                        forceClickable: true,
                        selected: true,
                        onClick: (id) {
                          showMaterialModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              expand: false,
                              builder: (context) => LanguageSelectionPane(
                                    current: currentLanguage!.id,
                                    ignoreSupport: true,
                                    onLanguageSelect: onLanguageSelect,
                                    languageList: languageSetting.languages,
                                  ));
                        }),
                  ),
                ),
                Positioned(
                    right: 20,
                    bottom: 0,
                    child: MongolFilledButton(
                        onPressed: onClickFinish,
                        child: MongolText(
                          style: TextStyle(
                              fontFamily: 'NotoSans',
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          AppLocalizations.of(context)!.textButtonDone,
                        ))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalUI(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.textSelectLanagueFirst,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        currentLanguage == null
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Theme.of(context).hintColor))
            : LanguageItemView(
                data: currentLanguage!,
                forceClickable: true,
                selected: true,
                onClick: (id) {
                  showMaterialModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      expand: false,
                      builder: (context) => LanguageSelectionPane(
                            current: currentLanguage!.id,
                            ignoreSupport: true,
                            onLanguageSelect: onLanguageSelect,
                            languageList: languageSetting.languages,
                          ));
                }),
        const Spacer(),
        const SizedBox(
          height: 20,
        ),
        RedRoundedButton(
          fill: true,
          label: AppLocalizations.of(context)!.textButtonDone,
          onClick: onClickFinish,
          loading: false,
        ),
        const SizedBox(
          height: 34,
        )
      ],
    );
  }

  void onClickFinish() {
    UserManager manager = GetIt.I<UserManager>();
    //todo set language for app
    manager.setUserAgreementAccepted();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MyHomePage();
    }));
  }

  void onLanguageSelect(int language) {
    Navigator.of(context).pop(); //close the language selection panel
    LanguageSetting languageList = GetIt.I<LanguageSetting>();
    for (LanguageItem item in languageList.languages) {
      if (item.id == language) {
        // Language ID 5 is traditional Mongolian, use 'mo' locale
        String locale = (language == 5) ? 'mo' : item.shortName.toLowerCase();
        setting.setLocaleSetting(locale);
        setState(() {
          currentLanguage = item;
        });
      }
    }
  }
}
