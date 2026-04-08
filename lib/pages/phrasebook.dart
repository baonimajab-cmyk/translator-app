import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/icon_assets_helper.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/pages/translation_list_page.dart';
import 'package:abiya_translator/utils/language_setting.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/language_swicher.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class Phrasebook extends StatefulWidget {
  const Phrasebook({super.key});

  @override
  State<StatefulWidget> createState() {
    return PhraseBookState();
  }
}

class PhraseBookState extends State<Phrasebook> {
  List<PhraseCategoryItem> categories = [];
  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  void getCategoryList() async {
    HttpHelper<PhraseCategoryListResponse>(PhraseCategoryListResponse.new).post(
      apiGetPhraseCategories,
      null,
      onResponse: (response) {
        setState(() {
          categories = response.categoryList;
        });
      },
      onError: (et, em) {
        ToastHelper.show(em);
      },
    );
  }

  String getLanguageCode(int id) {
    for (LanguageItem item in GetIt.I<LanguageSetting>().languages) {
      if (item.id == id) {
        return item.shortName.toLowerCase();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Scaffold(
        appBar: AbyAppBar(
          titleText: AppLocalizations.of(context)!.titlePhrasebook,
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(CupertinoIcons.arrow_left),
          ),
          actions: const [],
        ),
        body: isVerticalUI
            ? Row(children: [
                PhracebookTitle(),
                _buildList(context, isVerticalUI),
              ])
            : SafeArea(
                child: Column(
                  children: [
                    _buildList(context, isVerticalUI),
                    isVerticalUI
                        ? Container()
                        : LanguageSwicher(
                            ignoreUnsupport: true,
                            buttonColor: Theme.of(context).colorScheme.surface),
                  ],
                ),
              ));
  }

  Widget _buildList(BuildContext context, bool isVerticalUI) {
    return categories.isEmpty
        ? Expanded(
            child: Container(),
          )
        : Expanded(
            child: AdaptiveListView(children: [
              ListGroup(
                dividerMargin: 42,
                children: categories
                    .map((item) => CategoryItemView(
                          id: item.id,
                          icon: item.icon,
                          name: item.name,
                          onTap: (id, name, icon) {
                            toPhrasebook(id, name, icon);
                          },
                        ))
                    .toList(),
              ),
            ]),
          );
  }

  void toPhrasebook(int id, String name, String icon) {
    LanguageConfig? config = GetIt.I<LanguageSetting>().runtimeConfig.value;
    if (config != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TranslationListPage(
                  listType: TranslationListPage.typePhrases,
                  phraseCategoryId: id,
                  phraseCategoryName: name,
                  phraseCategoryIcon: icon,
                  from: getLanguageCode(config.from),
                  to: getLanguageCode(config.to))));
    }
  }
}

class CategoryItemView extends StatelessWidget {
  final int id;
  final String icon;
  final String name;
  final LanguageSetting languageSetting = GetIt.I<LanguageSetting>();
  final Function(int, String, String) onTap;
  CategoryItemView(
      {super.key,
      required this.id,
      required this.icon,
      required this.name,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(id, name, icon);
      },
      child: UiHelper.isVerticalUI()
          ? _buildVerticalItem(context)
          : _buildHorizontalItem(context),
    );
  }

  Widget _buildVerticalItem(BuildContext context) {
    return Container(
      width: 46,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(IconAssetsHelper.getIcon(icon)),
          ),
          const SizedBox(height: 16),
          Transform.translate(
            offset: Offset(4, 0),
            child: MongolText(
              name,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 3,
            child: Icon(
              size: 18,
              CupertinoIcons.back,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalItem(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(IconAssetsHelper.getIcon(icon)),
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            name,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 2,
            child: Icon(
              size: 18,
              CupertinoIcons.back,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PhracebookTitle extends StatelessWidget {
  const PhracebookTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            right: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: UiHelper.getDividerWidth(context))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(4, 0),
              child: MongolText(
                AppLocalizations.of(context)!.titlePhrasebook,
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            RotatedBox(
              quarterTurns: 1,
              child: const LanguageSwicher(ignoreUnsupport: true),
            )
          ],
        ),
      ),
    );
  }
}
