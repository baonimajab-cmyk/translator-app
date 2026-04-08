import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/db_helper.dart';
import 'package:abiya_translator/db/history_model.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/pages/membership.dart';
import 'package:abiya_translator/pages/personal.dart';
import 'package:abiya_translator/pages/setting_page.dart';
import 'package:abiya_translator/pages/translation_list_page.dart';
import 'package:abiya_translator/utils/device_helper.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/logger.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/language_swicher.dart';
import 'package:abiya_translator/widgets/slow_linear_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  TextEditingController? editingController;
  TranslateResponse? translateResponse;
  bool addedFavourite = false;
  int quarter = 0;
  int maxLength = 2000;
  int curLength = 0;
  late DeviceHelper helper;
  LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
  UserManager userManager = GetIt.I<UserManager>();
  SystemSetting systemSetting = GetIt.I<SystemSetting>();
  FocusNode focusNode = FocusNode();
  bool keyboardShwoing = false;

  bool translating = false;

  String fromLanguage = '';
  String toLanguage = '';

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController();
    focusNode.addListener(() {
      setState(() {
        keyboardShwoing = focusNode.hasFocus;
      });
    });
    registerDevice();
  }

  void registerDevice() async {
    if (!GetIt.I.isRegistered<DeviceHelper>()) {
      GetIt.I.registerSingleton(DeviceHelper());
    }
    helper = GetIt.I<DeviceHelper>();
    await helper.loadDeviceInfo();
    HttpHelper(ConnectResponse.new).post(
      apiRegisterDevice,
      {}..addAll(helper.getJsonParam()),
      onError: (et, em) {
        if (et >= 1000) {
          showLoginAlert();
        }
      },
      onResponse: (response) {
        Logger.log(response.errMsg);
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

  String getLanguageCode(int id) {
    for (LanguageItem item in languageSetting.languages) {
      if (item.id == id) {
        return item.shortName.toLowerCase();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: languageSetting.config,
        builder: (BuildContext context, LanguageConfig? config, Widget? child) {
          if (config != null) {
            fromLanguage = getLanguageCode(config.from);
            toLanguage = getLanguageCode(config.to);
          }
          return Scaffold(
            backgroundColor: systemSetting.isDarkMode(context)
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              bottom: translating
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: SlowLinearProgressIndicator(
                        minHeight: 2,
                        color: const Color.fromARGB(255, 255, 0, 0),
                        backgroundColor: Colors.transparent,
                        period: const Duration(milliseconds: 3200),
                      ),
                    )
                  : null,
              title: SizedBox(
                  width: 20,
                  height: 30,
                  child: Image.asset('assets/images/app_bar_logo.png')),
              actions: [
                IconButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TranslationListPage(
                                        listType:
                                            TranslationListPage.typeHistory,
                                      )))
                        },
                    icon: const Icon(
                      CupertinoIcons.clock,
                    )),
                IconButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PersonalPage()),
                          )
                        },
                    icon: const Icon(
                      CupertinoIcons.person,
                    ))
              ],
              leading: IconButton(
                onPressed: () => {Navigator.of(context).push(_createRoute())},
                icon: const Icon(
                  CupertinoIcons.gear,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TextField(
                                    minLines: null,
                                    maxLines: null,
                                    maxLength: maxLength,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    focusNode: focusNode,
                                    controller: editingController,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (value) => {translate()},
                                    onChanged: (text) {
                                      setState(() {
                                        curLength = text.characters.length;
                                      });
                                    },
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(8.0),
                                      border: InputBorder.none,
                                      counterText: '',
                                      hintText: AppLocalizations.of(context)!
                                          .hintTranslationInput,
                                      fillColor:
                                          systemSetting.isDarkMode(context)
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                      hintStyle: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('$curLength/$maxLength',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Theme.of(context).hintColor)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: systemSetting.isDarkMode(context)
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).scaffoldBackgroundColor,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    translateResponse != null
                                        ? translateResponse!.result
                                        : translating
                                            ? AppLocalizations.of(context)!
                                                .hintTranslating
                                            : AppLocalizations.of(context)!
                                                .hintTranslationResult,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: translateResponse != null
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context).hintColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  const LanguageSwicher(writeConfig: true),
                ],
              ),
            ),
          );
        });
  }

  void translate() {
    setState(() {
      if (translateResponse != null) translateResponse!.result = '';
    });
    String source = editingController!.value.text.trim();
    if (source.isEmpty) {
      ToastHelper.show(AppLocalizations.of(context)!.alertEmptyString);
      return;
    }
    setState(() {
      translating = true;
      addedFavourite = false;
    });
    HttpHelper<TranslateResponse>(TranslateResponse.new).post(
      apiTranslate,
      {
        'from': fromLanguage,
        'to': toLanguage,
        'text': source,
        'device_id': helper.deviceID,
        'uuid': userManager.getCurrentUser() != null
            ? userManager.getCurrentUser()!.uuid
            : ''
      },
      onError: (et, em) {
        setState(() {
          translating = false;
        });
        if (et >= 2000) {
          //free amount insufficient
          Alert.show(
              context,
              et == 2000
                  ? AppLocalizations.of(context)!
                      .alertInsufficientFreeAmountTitle
                  : AppLocalizations.of(context)!.alertFreeAmountUsedUpTitle,
              em,
              AppLocalizations.of(context)!.textButtonUpgradeNow,
              AppLocalizations.of(context)!.textButtonMaybeLater, () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MembershipPage()));
          });
        } else if (et >= 1000) {
          showLoginAlert();
        } else {
          ToastHelper.show(em);
        }
      },
      onResponse: (response) {
        setState(() {
          translating = false;
        });
        if (userManager.getCurrentUser() == null) {
          //user not logged in, we should store history locally
          DbHelper().insertHistory(History(
              id: 0,
              from: fromLanguage,
              to: toLanguage,
              source: source,
              target: response.result,
              time: DateTime.now().millisecondsSinceEpoch ~/ 1000));
        }
        setState(() {
          translateResponse = response;
        });
      },
    );
  }

  void addFavourite(int translateId) {
    HttpHelper<AddFavouriteResponse>(AddFavouriteResponse.new).post(
      apiAddFavourite,
      {
        'id': translateId,
        'add': !addedFavourite,
      },
      onResponse: (response) {
        setState(() {
          addedFavourite = response.favourite;
        });
      },
      onError: (et, em) {
        ToastHelper.show(em);
      },
    );
  }

  //to slide from left to right
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SettingPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
