import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/language_item.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class LanguageSelectionPane extends StatefulWidget {
  final Function(int language) onLanguageSelect;
  final int exclude;
  final int current;
  // in app setting, we don't care if the language is supported for translation,
  // because we provide all the 5 languages in the UI system, so when this field
  // is set to true, the unsupported language can still be selected
  final bool ignoreSupport;
  final List<LanguageItem> languageList;
  const LanguageSelectionPane(
      {super.key,
      required this.current,
      required this.onLanguageSelect,
      required this.languageList,
      this.exclude = -1,
      this.ignoreSupport = false});

  @override
  State<StatefulWidget> createState() {
    return LanguageSelectionPaneState();
  }
}

class LanguageSelectionPaneState extends State<LanguageSelectionPane> {
  int current = 0;
  final LanguageSetting languages = GetIt.I<LanguageSetting>();
  @override
  void initState() {
    super.initState();
    current = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    List<LanguageItem> sortedLanguages = widget.languageList;

    sortedLanguages.sort((a, b) {
      if (a.support && !b.support) return -1;
      if (!a.support && b.support) return 1;
      return 0;
    });

    double radius = 24;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius)),
          color: Theme.of(context).colorScheme.surface),
      child: SizedBox(
        height: 400,
        child: UiHelper.isVerticalUI()
            ? _buildVerticalUI(context, sortedLanguages)
            : _buildHorizontalUI(context, sortedLanguages),
      ),
    );
  }

  Widget _buildVerticalUI(
      BuildContext context, List<LanguageItem> sortedLanguages) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: MongolText(
              AppLocalizations.of(context)!.textSelectLanguage,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 18,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => sortedLanguages
                .map((e) => LanguageItemView(
                    data: e,
                    forceClickable: widget.ignoreSupport,
                    selected: e.id == current,
                    onClick: (id) {
                      Navigator.of(context).pop();
                      widget.onLanguageSelect(id);
                      setState(() {
                        current = id;
                      });
                    }))
                .toList()[index],
            separatorBuilder: (context, index) => AdaptiveDivider(
              isVerticalUI: UiHelper.isVerticalUI(),
              indent: 24,
            ),
            itemCount: sortedLanguages.length,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalUI(
      BuildContext context, List<LanguageItem> sortedLanguages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.textSelectLanguage,
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => sortedLanguages
                .map((e) => LanguageItemView(
                    data: e,
                    forceClickable: widget.ignoreSupport,
                    selected: e.id == current,
                    onClick: (id) {
                      Navigator.of(context).pop();
                      widget.onLanguageSelect(id);
                      setState(() {
                        current = id;
                      });
                    }))
                .toList()[index],
            separatorBuilder: (context, index) =>
                AdaptiveDivider(isVerticalUI: false, indent: 24),
            itemCount: sortedLanguages.length,
          ),
        ),
      ],
    );
  }
}
