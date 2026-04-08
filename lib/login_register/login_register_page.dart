import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_view.dart';
import 'package:abiya_translator/login_register/set_password_view.dart';
import 'package:abiya_translator/login_register/verify_email_view.dart';
import 'package:abiya_translator/pages/profession_selection_page.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginRegisterPage extends StatefulWidget {
  final bool changePassword;
  final bool deleteAccount;
  const LoginRegisterPage({
    super.key,
    this.changePassword = false,
    this.deleteAccount = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _LoginRegisterPageState();
  }
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  late PageController pageController;
  static int loginPage = 0;
  static int verifyEmailPage = 1;
  static int passwordPage = 2;
  String email = '';
  late bool jumpToVerifyEmailPage;
  bool forgotPassword = false;
  bool newRegister = false;
  String currentTitle = '';
  _LoginRegisterPageState();
  @override
  void initState() {
    super.initState();
    jumpToVerifyEmailPage = widget.changePassword || widget.deleteAccount;
    if (jumpToVerifyEmailPage) {
      UserManager manager = GetIt.I<UserManager>();
      UserInfo? info = manager.getCurrentUser();
      if (info != null) email = info.email;
    }
    pageController = PageController(
        initialPage: jumpToVerifyEmailPage ? verifyEmailPage : loginPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentTitle = forgotPassword
        ? AppLocalizations.of(context)!.titleResetPassword
        : widget.changePassword
            ? AppLocalizations.of(context)!.titleChangePassword
            : widget.deleteAccount
                ? AppLocalizations.of(context)!.titleDeleteAccount
                : AppLocalizations.of(context)!.titleLogin;
  }

  void handleBack() {
    int p = pageController.page!.toInt();
    if (p == loginPage) {
      Navigator.pop(context);
    } else if (p == verifyEmailPage) {
      if (newRegister) {
        newRegister = false;
      } else if (widget.changePassword || widget.deleteAccount) {
        Navigator.pop(context);
        return;
      }
      forgotPassword = false;
      toPage(loginPage);
    } else if (p == passwordPage) {
      if (newRegister) {
        Alert.show(
            context,
            AppLocalizations.of(context)!.alertTitleCancelRegister,
            AppLocalizations.of(context)!.alertContentCancelRegister,
            AppLocalizations.of(context)!.textButtonOK,
            AppLocalizations.of(context)!.textButtonCancel, () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).splashColor,
      appBar: AppBar(
        elevation: 0,
        title: isVerticalUI ? Container() : Text(currentTitle),
        shape: const Border(),
        leading: IconButton(
          onPressed: () => {handleBack()},
          icon: const Icon(
            CupertinoIcons.arrow_left,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: UiHelper.isVerticalUI() ? 0 : 40),
                child: SizedBox(
                    height: 100,
                    child: Image.asset(
                        GetIt.I<SystemSetting>().isDarkMode(context)
                            ? 'assets/images/register_banner_dark.png'
                            : 'assets/images/register_banner.png')),
              ),
              SizedBox(
                height: UiHelper.isVerticalUI() ? 30 : 50,
              ),
              Expanded(
                child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: [
                      LoginView(
                        onRegisterNewAccount: () {
                          newRegister = true;
                          toPage(verifyEmailPage);
                        },
                        callback: (success) {
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                        onForgotPassword: () {
                          jumpToVerifyEmailPage = true;
                          forgotPassword = true;
                          toPage(verifyEmailPage);
                        },
                      ),
                      VerifyEmailView(
                          email: email,
                          action: widget.changePassword
                              ? 'change_password'
                              : forgotPassword
                                  ? 'reset_password'
                                  : widget.deleteAccount
                                      ? 'delete_account'
                                      : 'register',
                          callback: (email, success) {
                            this.email = email;
                            if (success) {
                              toPage(passwordPage);
                            }
                          }),
                      SetPasswordView(
                        email: email,
                        changePassword: widget.changePassword || forgotPassword,
                        deleteAccount: widget.deleteAccount,
                        forgotPassword: forgotPassword,
                        callback: (success) {
                          if (success) {
                            if (widget.deleteAccount) {
                              UserManager manager = GetIt.I<UserManager>();
                              manager.logout();
                              ToastHelper.show(AppLocalizations.of(context)!
                                  .toastDeleteAccountSuccess);
                            } else if (forgotPassword) {
                              ToastHelper.show(AppLocalizations.of(context)!
                                  .toastPasswordResetSuccess);
                              forgotPassword = false;
                              toPage(loginPage);
                              return;
                            } else if (widget.changePassword) {
                              ToastHelper.show(AppLocalizations.of(context)!
                                  .toastChangePasswordSuccess);
                            } else {
                              //new register, to profession selection page
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfessionSelectionPage(
                                              firstRegister: true)),
                                  (route) => false);
                              return;
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toPage(int page) {
    setState(() {
      if (newRegister) {
        currentTitle = AppLocalizations.of(context)!.titleRegisterAccount;
      } else if (widget.changePassword) {
        currentTitle = AppLocalizations.of(context)!.titleChangePassword;
      } else if (forgotPassword) {
        currentTitle = AppLocalizations.of(context)!.titleResetPassword;
      } else if (widget.deleteAccount) {
        currentTitle = AppLocalizations.of(context)!.titleDeleteAccount;
      } else {
        currentTitle = AppLocalizations.of(context)!.titleLogin;
      }
    });
    pageController.animateToPage(page,
        duration: Durations.short1, curve: Curves.linear);
  }
}
