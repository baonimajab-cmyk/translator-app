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
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/language_swicher.dart';
import 'package:abiya_translator/widgets/slow_linear_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  int fromLanguageId = -1;
  int toLanguageId = -1;
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

  /// 多行输入时部分 IME 仍会把回车当作换行而不触发 [onSubmitted]，
  /// 末尾换行则视为“发送”并去掉该换行。
  void _onTranslationInputTextChanged(String text) {
    if (text.endsWith('\n')) {
      final trimmed = text.substring(0, text.length - 1);
      editingController!.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
      setState(() {
        curLength = trimmed.characters.length;
      });
      translate();
      return;
    }
    setState(() {
      curLength = text.characters.length;
    });
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

  void handleLanguageChange(int oldFrom, int oldTo, int newFrom, int newTo) {
    if (oldFrom != newFrom) {
      translateResponse = null;
      editingController!.clear();
      curLength = 0;
    }
    if (oldTo != newTo) {
      translateResponse = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: languageSetting.config,
        builder: (BuildContext context, LanguageConfig? config, Widget? child) {
          if (config != null) {
            fromLanguage = getLanguageCode(config.from);
            toLanguage = getLanguageCode(config.to);
            handleLanguageChange(
                fromLanguageId, toLanguageId, config.from, config.to);
            fromLanguageId = config.from;
            toLanguageId = config.to;
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
                      icon: const Icon(CupertinoIcons.clock)),
                  IconButton(
                      onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PersonalPage()),
                            )
                          },
                      icon: const Icon(CupertinoIcons.person))
                ],
                leading: IconButton(
                  onPressed: () => {Navigator.of(context).push(_createRoute())},
                  icon: const Icon(CupertinoIcons.gear),
                ),
              ),
              body: SafeArea(
                  child: UiHelper.isVerticalUI()
                      ? _buildVerticalUI(context)
                      : _buildHorizontalUI(context)));
        });
  }

  Widget _getOutputText(int languageId) {
    if (translateResponse == null) {
      //no translation result yet, show hint text
      if (UiHelper.isVerticalUI()) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: MongolText(
            translating
                ? AppLocalizations.of(context)!.hintTranslating
                : AppLocalizations.of(context)!.hintTranslationResult,
            textAlign: MongolTextAlign.top,
            softWrap: true,
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSans',
                color: Theme.of(context).hintColor),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(
            translating
                ? AppLocalizations.of(context)!.hintTranslating
                : AppLocalizations.of(context)!.hintTranslationResult,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, color: Theme.of(context).hintColor),
          ),
        );
      }
    }
    if (languageId == 5) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: MongolText(
          translateResponse!.result,
          textAlign: MongolTextAlign.top,
          softWrap: true,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSans',
              // fontWeight: FontWeight.w600,
              color: translateResponse != null
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).hintColor),
        ),
      );
    } else {
      return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(
            translateResponse != null
                ? translateResponse!.result
                : translating
                    ? AppLocalizations.of(context)!.hintTranslating
                    : AppLocalizations.of(context)!.hintTranslationResult,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18,
                color: translateResponse != null
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).hintColor,
                fontWeight: FontWeight.w600),
          ));
    }
  }

  Widget _getInputText(int languageId) {
    if (!keyboardShwoing) {
      if (UiHelper.isVerticalUI() &&
          languageId != 5 &&
          editingController!.text.isEmpty) {
        //only show this hint when in Mongolian mode and the source language is not Mongolian
        //and the keyboard is not showing
        return GestureDetector(
          onTap: () {
            setState(() {
              keyboardShwoing = true;
            });
            focusNode.requestFocus();
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: MongolText(
              AppLocalizations.of(context)!.hintTranslationInput,
              textAlign: MongolTextAlign.top,
              softWrap: true,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSans',
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      }
    }
    if (languageId == 5) {
      return MongolTextField(
        minLines: null,
        maxLines: null,
        maxLength: maxLength,
        expands: true,
        focusNode: focusNode,
        controller: editingController,
        textInputAction: TextInputAction.send,
        onSubmitted: (value) => translate(),
        onChanged: _onTranslationInputTextChanged,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: TextStyle(
            fontSize: 18,
            fontFamily: 'NotoSans',
            color: Theme.of(context).colorScheme.onPrimary),
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            border: InputBorder.none,
            counterText: '',
            hintText: AppLocalizations.of(context)!.hintTranslationInput,
            fillColor: systemSetting.isDarkMode(context)
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).colorScheme.surface,
            hintStyle:
                TextStyle(fontSize: 18, color: Theme.of(context).hintColor)),
      );
    } else {
      return TextField(
        minLines: null,
        maxLines: null,
        maxLength: maxLength,
        expands: true,
        focusNode: focusNode,
        controller: editingController,
        textInputAction: TextInputAction.send,
        onSubmitted: (value) => translate(),
        onChanged: _onTranslationInputTextChanged,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: editingController!.text.isEmpty ? 12.0 : 8.0),
            border: InputBorder.none,
            counterText: '',
            hintText: AppLocalizations.of(context)!.hintTranslationInput,
            fillColor: systemSetting.isDarkMode(context)
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).colorScheme.surface,
            hintStyle: TextStyle(
                fontSize: 18,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.normal),
            suffix:
                editingController!.text.isNotEmpty && !UiHelper.isVerticalUI()
                    ? GestureDetector(
                        child: Icon(
                            size: 24,
                            CupertinoIcons.clear,
                            color: Theme.of(context).hintColor),
                        onTap: () {
                          editingController!.clear();
                          setState(() {
                            curLength = 0;
                          });
                        },
                      )
                    : null),
      );
    }
  }

  Widget _buildVerticalUI(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              color: systemSetting.isDarkMode(context)
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).scaffoldBackgroundColor,
              child: RotatedBox(
                quarterTurns: quarter,
                child: _getOutputText(toLanguageId),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: systemSetting.isDarkMode(context)
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    bottom: BorderSide(
                        width: UiHelper.getDividerWidth(context),
                        color: Theme.of(context).colorScheme.outline))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                translateResponse != null
                    ? IconButton(
                        onPressed: () async {
                          String copyToastMsg =
                              AppLocalizations.of(context)!.toastTextCopied;
                          await Clipboard.setData(
                              ClipboardData(text: translateResponse!.result));
                          ToastHelper.show(copyToastMsg);
                        },
                        icon: const Icon(CupertinoIcons.square_on_square))
                    : Container(),
                IconButton(
                    onPressed: () => {
                          setState(() {
                            if (quarter == 0) {
                              quarter = 2;
                            } else {
                              quarter = 0;
                            }
                          })
                        },
                    icon: const Icon(CupertinoIcons.arrow_2_squarepath)),
                IconButton(
                    onPressed: () {
                      if (translateResponse == null) return;
                      addFavourite(translateResponse!.translateId);
                    },
                    icon: Icon(addedFavourite
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star))
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _getInputText(fromLanguageId)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (editingController!.text.isNotEmpty)
                        GestureDetector(
                          child: Icon(
                              size: 24,
                              CupertinoIcons.clear,
                              color: Theme.of(context).hintColor),
                          onTap: () {
                            editingController!.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              curLength = 0;
                            });
                          },
                        ),
                      Spacer(),
                      MongolText('$curLength/$maxLength',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSans',
                              color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
                if (!keyboardShwoing &&
                    MediaQuery.viewInsetsOf(context).bottom < 8)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RotatedBox(
                        quarterTurns: 1,
                        child: LanguageSwicher(writeConfig: true)),
                  )
              ],
            ),
          )
        ]);
  }

  Widget _buildHorizontalUI(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: systemSetting.isDarkMode(context)
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).scaffoldBackgroundColor,
              child: RotatedBox(
                quarterTurns: quarter,
                child: _getOutputText(toLanguageId),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: systemSetting.isDarkMode(context)
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    bottom: BorderSide(
                        width: UiHelper.getDividerWidth(context),
                        color: Theme.of(context).colorScheme.outline))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                translateResponse != null
                    ? IconButton(
                        onPressed: () async {
                          String copyToastMsg =
                              AppLocalizations.of(context)!.toastTextCopied;
                          await Clipboard.setData(
                              ClipboardData(text: translateResponse!.result));
                          ToastHelper.show(copyToastMsg);
                        },
                        icon: const Icon(CupertinoIcons.square_on_square))
                    : Container(),
                IconButton(
                    onPressed: () => {
                          setState(() {
                            if (quarter == 0) {
                              quarter = 2;
                            } else {
                              quarter = 0;
                            }
                          })
                        },
                    icon: const Icon(CupertinoIcons.arrow_2_squarepath)),
                IconButton(
                    onPressed: () {
                      if (translateResponse == null) return;
                      addFavourite(translateResponse!.translateId);
                    },
                    icon: Icon(addedFavourite
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star))
              ],
            ),
          ),
          Expanded(flex: 1, child: _getInputText(fromLanguageId)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('$curLength/$maxLength',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).hintColor)),
            ),
          ),
          if (!keyboardShwoing) LanguageSwicher(writeConfig: true)
        ]);
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
    focusNode.unfocus();
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
          //only on a successfull translation
          if (response.result.isNotEmpty) {
            DbHelper().insertHistory(History(
                id: 0,
                from: fromLanguage,
                to: toLanguage,
                source: source,
                target: response.result,
                time: DateTime.now().millisecondsSinceEpoch ~/ 1000));
          }
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
