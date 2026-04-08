import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<ThemeSettingPage> {
  bool automatic = true;
  bool lightTheme = true;
  final SystemSetting themeProvider = GetIt.I<SystemSetting>();
  @override
  void initState() {
    super.initState();
    automatic = themeProvider.themeMode == ThemeMode.system;
    lightTheme = themeProvider.themeMode == ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    Widget children = AdaptiveListView(children: [
      ListGroup(
        dividerMargin: 16,
        children: [
          ThemeSelectItem(
            name: AppLocalizations.of(context)!.textThemeLight,
            selected: lightTheme,
            onClick: () {
              setState(() {
                lightTheme = true;
                themeProvider.setThemeMode(ThemeMode.light);
              });
            },
          ),
          ThemeSelectItem(
            name: AppLocalizations.of(context)!.textThemeDark,
            selected: !lightTheme,
            onClick: () {
              setState(() {
                lightTheme = false;
                themeProvider.setThemeMode(ThemeMode.dark);
              });
            },
          ),
        ],
      ),
    ]);
    return Scaffold(
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.textTheme,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(CupertinoIcons.arrow_left),
        ),
      ),
      body: isVerticalUI
          ? _buildVerticalLayout(context, children)
          : _buildHorizontalLayout(context, children),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, Widget children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalTitle(text: AppLocalizations.of(context)!.textTheme),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
              vertical: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      child: MongolText(
                        AppLocalizations.of(context)!.textThemeAutomatic,
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MongolText(
                      AppLocalizations.of(context)!.textThemeDescription,
                      style: TextStyle(
                          fontFamily: 'NotoSans',
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 14),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Switch.adaptive(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  value: automatic,
                  onChanged: (bool value) {
                    setState(() {
                      automatic = value;
                      if (automatic) {
                        themeProvider.setThemeMode(ThemeMode.system);
                      } else {
                        SystemSetting setting = GetIt.I<SystemSetting>();
                        bool isDark = setting.isDarkMode(context);
                        if (isDark) {
                          themeProvider.setThemeMode(ThemeMode.dark);
                          lightTheme = false;
                        } else {
                          lightTheme = true;
                          themeProvider.setThemeMode(ThemeMode.light);
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (!automatic) children,
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, Widget children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
              horizontal: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.textThemeAutomatic,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.textThemeDescription,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                      )
                    ]),
              ),
              const SizedBox(width: 10),
              Switch.adaptive(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                value: automatic,
                onChanged: (bool value) {
                  setState(() {
                    automatic = value;
                    if (automatic) {
                      themeProvider.setThemeMode(ThemeMode.system);
                    } else {
                      SystemSetting setting = GetIt.I<SystemSetting>();
                      bool isDark = setting.isDarkMode(context);
                      if (isDark) {
                        themeProvider.setThemeMode(ThemeMode.dark);
                        lightTheme = false;
                      } else {
                        lightTheme = true;
                        themeProvider.setThemeMode(ThemeMode.light);
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ),
        if (!automatic) children,
      ],
    );
  }
}

class ThemeSelectItem extends StatelessWidget {
  final Function()? onClick;
  final bool selected;
  final String name;
  const ThemeSelectItem(
      {super.key, required this.name, required this.selected, this.onClick});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return InkWell(
      onTap: onClick,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: isVerticalUI
              ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
              : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: isVerticalUI
              ? _buildVerticalItem(context)
              : _buildHorizontalItem(context),
        ),
      ),
    );
  }

  Widget _buildVerticalItem(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MongolText(
            name,
            style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          Spacer(),
          selected
              ? Icon(
                  CupertinoIcons.check_mark,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Container(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHorizontalItem(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          selected
              ? Icon(
                  CupertinoIcons.check_mark,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Container(),
        ],
      ),
    );
  }
}
