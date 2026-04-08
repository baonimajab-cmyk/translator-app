import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/pages/membership.dart';
import 'package:abiya_translator/pages/message_list_page.dart';
import 'package:abiya_translator/pages/phrasebook.dart';
import 'package:abiya_translator/pages/translation_list_page.dart';
import 'package:abiya_translator/pages/user_info_page.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PersonalPageState();
  }
}

class _PersonalPageState extends State<PersonalPage> {
  UserManager manager = GetIt.I<UserManager>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.titleMine,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(CupertinoIcons.arrow_left),
        ),
        actions: [
          IconButton(
            onPressed: () => {toMessageList()},
            icon: const Icon(CupertinoIcons.bell),
          ),
        ],
      ),
      body: ValueListenableBuilder<UserInfo?>(
        valueListenable: manager.notifier,
        builder: (context, userInfo, child) {
          bool isVerticalUI = UiHelper.isVerticalUI();
          if (isVerticalUI) {
            return Row(
              children: [
                VerticalTitle(text: AppLocalizations.of(context)!.titleMine),
                Expanded(child: _buildListView(userInfo)),
              ],
            );
          } else {
            return _buildListView(userInfo);
          }
        },
      ),
    );
  }

  Widget _buildListView(UserInfo? userInfo) {
    return AdaptiveListView(children: [
      UserBanner(userInfo: userInfo),
      ListGap(),
      PremiumBanner(),
      ListGap(),
      ListItem(
          icon: 'assets/images/icons/icon_mine_phrasebook.png',
          text: AppLocalizations.of(context)!.titlePhrasebook,
          onClick: () {
            toPhraseBook();
          }),
      ListGap(),
      ListGroup(dividerMargin: 48, children: [
        ListItem(
            icon: 'assets/images/icons/icon_mine_history.png',
            text: AppLocalizations.of(context)!.textHitory,
            onClick: () {
              toHistory();
            }),
        ListItem(
            icon: 'assets/images/icons/icon_mine_favourites.png',
            text: AppLocalizations.of(context)!.textFavourite,
            onClick: () {
              toFavourite();
            })
      ]),
    ]);
  }

  void toPhraseBook() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Phrasebook()));
  }

  void toHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TranslationListPage(
                  listType: TranslationListPage.typeHistory,
                )));
  }

  void toFavourite() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TranslationListPage(
                  listType: TranslationListPage.typeFavourite,
                )));
  }

  void toMembershipPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MembershipPage()));
  }

  void toMessageList() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MessageListPage()));
  }
}

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI
        ? _buildVerticalPremiumBanner(context)
        : _buildHorizontalPremiumBanner(context);
  }

  Widget _buildVerticalPremiumBanner(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SizedBox(
          width: 30,
          height: 60,
          child: Image.asset('assets/images/icon_membership.png'),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MongolText(
              AppLocalizations.of(context)!.textTranslatorPro,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 4,
            ),
            MongolText(
              AppLocalizations.of(context)!.textUpgradePremiumNow,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'NotoSans',
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          height: 110,
          width: 32.0,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 255, 204, 0),
                    Color.fromARGB(255, 255, 149, 0),
                  ])),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const MembershipPage();
                  }));
                },
                child: Center(
                  child: Transform.translate(
                    offset: Offset(2, 0),
                    child: MongolText(
                      AppLocalizations.of(context)!.textButtonUpgrade,
                      style: TextStyle(
                          fontFamily: 'NotoSans', fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ),
        )
      ]),
    );
  }

  Widget _buildHorizontalPremiumBanner(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        SizedBox(
          width: 30,
          height: 60,
          child: Image.asset('assets/images/icon_membership.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.textTranslatorPro,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              AppLocalizations.of(context)!.textUpgradePremiumNow,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 120,
          height: 32.0,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 255, 204, 0),
                    Color.fromARGB(255, 255, 149, 0),
                  ])),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const MembershipPage();
                  }));
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.textButtonUpgrade,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
          ),
        )
      ]),
    );
  }
}

class UserBanner extends StatelessWidget {
  final UserInfo? userInfo;
  const UserBanner({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return GestureDetector(
      onTap: () {
        toLoginPage(context, userInfo);
      },
      child: isVerticalUI
          ? _buildVerticalUserBanner(context)
          : _buildHorizontalUserBanner(context),
    );
  }

  Widget _buildVerticalUserBanner(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(userInfo == null
                  ? GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_no_login_dark.png'
                      : 'assets/images/avatar_no_login_light.png'
                  : GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_login_dark.png'
                      : 'assets/images/avatar_login_light.png')),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  MongolText(
                    userInfo == null
                        ? AppLocalizations.of(context)!.textLoginPlaceholder
                        : userInfo!.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                  userInfo == null || !userInfo!.isMember()
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: Image.asset(
                                'assets/images/icon_membership_active_small.png'),
                          ),
                        )
                ],
              ),
              userInfo != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: MongolText(
                        userInfo!.email,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'NotoSans',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 3,
            child: Icon(
              size: 18,
              CupertinoIcons.back,
              color: userInfo != null && userInfo!.email.isEmpty
                  ? Colors.transparent
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalUserBanner(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(userInfo == null
                  ? GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_no_login_dark.png'
                      : 'assets/images/avatar_no_login_light.png'
                  : GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_login_dark.png'
                      : 'assets/images/avatar_login_light.png')),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userInfo == null
                        ? AppLocalizations.of(context)!.textLoginPlaceholder
                        : userInfo!.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                  userInfo == null || !userInfo!.isMember()
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: Image.asset(
                                'assets/images/icon_membership_active_small.png'),
                          ),
                        )
                ],
              ),
              userInfo != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        userInfo!.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 2,
            child: Icon(
              size: 18,
              CupertinoIcons.back,
              color: userInfo != null && userInfo!.email.isEmpty
                  ? Colors.transparent
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  void toLoginPage(BuildContext context, UserInfo? userInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userInfo == null
              ? const LoginRegisterPage()
              : const UserInfoPage()),
    );
  }
}
