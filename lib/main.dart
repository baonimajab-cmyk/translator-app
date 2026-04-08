import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/first_use_page_1.dart';
import 'package:abiya_translator/pages/home.dart';
import 'package:abiya_translator/pages/home_web.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:toastification/toastification.dart';

void main() async {
  //to recover the top bottom bar for ios after splash screen
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Setup your config before the resume.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );
  GetIt.I.registerSingleton<UserManager>(UserManager());
  GetIt.I.registerSingleton<LanguageSetting>(LanguageSetting());
  GetIt.I.registerSingleton<SystemSetting>(SystemSetting());
  final UserManager userManager = GetIt.I<UserManager>();
  bool userAgreementAccepted = await userManager.userAgreementAccepted();
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
  runApp(MyApp(firstUse: !userAgreementAccepted));
}

class MyApp extends StatefulWidget {
  final bool firstUse;
  const MyApp({super.key, required this.firstUse});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final SystemSetting systemSetting = GetIt.I<SystemSetting>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: systemSetting,
        builder: (context, snapshot) {
          return ToastificationWrapper(
            child: MaterialApp(
              title: 'Abiya Translator',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('ja'), // Japanese
                Locale('zh'), // Chinese
                Locale('mn'), // Cyrillic
                Locale('mo'), // Traditional Mongolian
              ],
              locale: systemSetting.getLocale(),
              theme: Themes.lightTheme,
              darkTheme: Themes.darkTheme,
              themeMode: systemSetting.getThemeMode(), // device controls theme
              home: kIsWeb
                  ? const WebHomePage()
                  : !widget.firstUse
                      ? const MyHomePage()
                      : const FirstUsePageOne(),
            ),
          );
        });
  }
}
