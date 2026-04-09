import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/logger.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/widgets/language_selection_pane.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LanguageSwicher extends StatefulWidget {
  final bool ignoreUnsupport;
  final bool writeConfig;
  final Color? buttonColor;
  const LanguageSwicher(
      {super.key,
      this.ignoreUnsupport = false,
      this.writeConfig = false,
      this.buttonColor});

  @override
  State<StatefulWidget> createState() {
    return LanguageSwitcherState();
  }
}

class LanguageSwitcherState extends State<LanguageSwicher> {
  LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
  @override
  void initState() {
    super.initState();
  }

  String getLanguageName(int id) {
    for (LanguageItem item in languageSetting.languages) {
      if (item.id == id) {
        return item.name;
      }
    }
    return '';
  }

  List<LanguageItem> getTargetLanguageList(int source) {
    LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
    List<LanguageItem> languages = [];
    for (ModelItem item in languageSetting.models) {
      if (item.fromId == source) {
        for (LanguageItem languageItem in languageSetting.languages) {
          if (languageItem.id == item.toId) {
            languages.add(LanguageItem(languageItem.id, languageItem.name,
                languageItem.shortName, item.support));
          }
        }
      }
    }
    return languages;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.writeConfig
          ? languageSetting.config
          : languageSetting.runtimeConfig,
      builder: (BuildContext context, LanguageConfig? config, Widget? child) {
        int fromID = -1;
        int toID = -1;
        String labelFrom = '';
        String labelTo = '';
        if (config == null) {
          for (ModelItem model in languageSetting.models) {
            if (model.support) {
              fromID = model.fromId;
              toID = model.toId;
              break;
            }
          }
        } else {
          fromID = config.from;
          toID = config.to;
          bool support = languageSetting.models.any((model) =>
              model.fromId == fromID && model.toId == toID && model.support);
          if (fromID == toID || (!support && !widget.ignoreUnsupport)) {
            for (ModelItem modelItem in languageSetting.models) {
              if (modelItem.fromId == fromID &&
                  (modelItem.support || widget.ignoreUnsupport)) {
                toID = modelItem.toId;
                break;
              }
            }
            // Persist corrected pair so home (and other listeners) stay in sync
            if (toID != config.to) {
              languageSetting.setLanguageConfig(
                  LanguageConfig(fromID, toID), widget.writeConfig);
            }
          }
          labelFrom = getLanguageName(fromID);
          labelTo = getLanguageName(toID);
        }
        List<LanguageItem> targetLanguages = getTargetLanguageList(fromID);
        List<LanguageItem> sourceLanguages = [];
        for (LanguageItem item in languageSetting.languages) {
          sourceLanguages.add(LanguageItem(
              item.id,
              item.name,
              item.shortName,
              languageSetting.models
                  .any((model) => model.fromId == item.id && model.support)));
        }
        bool supportReverse = languageSetting.models.any((model) =>
            model.fromId == toID && model.toId == fromID && model.support);
        Logger.log(
            "from: $labelFrom, to: $labelTo, supportReverse: $supportReverse");
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LanguageButton(fromID, labelFrom, (int language) {
              languageSetting.setLanguageConfig(
                  LanguageConfig(language, toID), widget.writeConfig);
            },
                languageList: sourceLanguages,
                ignoreSupport: widget.ignoreUnsupport,
                backgroundColor: widget.buttonColor),
            IconButton(
                onPressed: () {
                  if (!supportReverse && !widget.ignoreUnsupport) {
                    ToastHelper.show(
                        AppLocalizations.of(context)!.alertModelNotSupported);
                    return;
                  }
                  int tempFrom = toID;
                  int tempTo = fromID;
                  for (ModelItem model in languageSetting.models) {
                    if (model.fromId == tempFrom && model.toId == tempTo) {
                      if (!model.support) {
                        Logger.log(
                            "model not supported yet: ${model.from},${model.to}");
                      }
                    }
                  }
                  fromID = tempFrom;
                  toID = tempTo;
                  labelFrom = getLanguageName(fromID);
                  labelTo = getLanguageName(toID);
                  languageSetting.setLanguageConfig(
                      LanguageConfig(fromID, toID), widget.writeConfig);
                },
                icon: Icon(
                    size: 20,
                    CupertinoIcons.arrow_right_arrow_left,
                    color: supportReverse || widget.ignoreUnsupport
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outline)),
            LanguageButton(toID, labelTo, (int language) {
              languageSetting.setLanguageConfig(
                  LanguageConfig(fromID, language), widget.writeConfig);
            },
                languageList: targetLanguages,
                ignoreSupport: widget.ignoreUnsupport,
                backgroundColor: widget.buttonColor),
          ],
        );
      },
    );
  }
}

class LanguageButton extends StatelessWidget {
  final int languageID;
  final String text;
  final Function(int language) onLanguageSelect;
  final List<LanguageItem> languageList;
  final bool ignoreSupport;
  final Color? backgroundColor;
  const LanguageButton(this.languageID, this.text, this.onLanguageSelect,
      {super.key,
      required this.languageList,
      required this.ignoreSupport,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 120,
      child: text.isEmpty
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
            )
          : TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: backgroundColor ??
                      Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              onPressed: () => {
                    showMaterialModalBottomSheet(
                        context: context,
                        expand: false,
                        backgroundColor: Colors.transparent,
                        builder: (context) => LanguageSelectionPane(
                              current: languageID,
                              onLanguageSelect: onLanguageSelect,
                              exclude: languageID,
                              languageList: languageList,
                              ignoreSupport: ignoreSupport,
                            ))
                  },
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600),
              )),
    );
  }
}
