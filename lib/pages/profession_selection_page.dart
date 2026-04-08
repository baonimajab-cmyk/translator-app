import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/pages/home.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/profession_item.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongol/mongol.dart';

class ProfessionSelectionPage extends StatefulWidget {
  final bool firstRegister;
  const ProfessionSelectionPage({super.key, this.firstRegister = false});

  @override
  State<ProfessionSelectionPage> createState() =>
      _ProfessionSelectionPageState();
}

class _ProfessionSelectionPageState extends State<ProfessionSelectionPage> {
  List<ProfessionItem> professionList = [];

  int _selectedProfessionId = -1;

  @override
  void initState() {
    super.initState();
    getProfessionList();
  }

  void getProfessionList() async {
    HttpHelper<ProfessionListResponse>(ProfessionListResponse.new).post(
      apiGetProfessionList,
      null,
      onResponse: (response) {
        setState(() {
          professionList = response.list;
        });
        int currentProfessionId =
            GetIt.I<UserManager>().getCurrentUser()?.profession ?? -1;
        if (currentProfessionId != -1) {
          setState(() {
            _selectedProfessionId = currentProfessionId;
          });
        }
      },
      onError: (error, message) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.textProfessionSelection,
      ),
      body: UiHelper.isVerticalUI()
          ? Stack(children: [
              Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: VerticalTitle(
                      text: AppLocalizations.of(context)!
                          .textProfessionSelection)),
              Positioned.fill(
                  left: 46, top: 0, bottom: 0, child: _buildVerticalUI())
            ])
          : _buildHorizontalUI(),
    );
  }

  Widget _buildVerticalUI() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: MongolText(
              AppLocalizations.of(context)!.hintSelectProfession,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: professionList.length,
            itemBuilder: (context, index) {
              return ProfessionItemView(
                selected: _selectedProfessionId == professionList[index].id,
                onClick: (id) {
                  setState(() {
                    _selectedProfessionId = id;
                  });
                },
                name: '${index + 1}. ${professionList[index].name}',
                id: professionList[index].id,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return AdaptiveDivider(
                isVerticalUI: UiHelper.isVerticalUI(),
                indent: 24,
              );
            },
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: RedRoundedButton(
                label: AppLocalizations.of(context)!.textButtonOK,
                fill: true,
                loading: false,
                onClick: () {
                  setProfession();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              AppLocalizations.of(context)!.hintSelectProfession,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: professionList.length,
              itemBuilder: (context, index) {
                return ProfessionItemView(
                  selected: _selectedProfessionId == professionList[index].id,
                  onClick: (id) {
                    setState(() {
                      _selectedProfessionId = id;
                    });
                  },
                  name: '${index + 1}. ${professionList[index].name}',
                  id: professionList[index].id,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return AdaptiveDivider(
                  isVerticalUI: false,
                  indent: 24,
                );
              },
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 36),
              child: RedRoundedButton(
                label: AppLocalizations.of(context)!.textButtonOK,
                fill: true,
                loading: false,
                onClick: () {
                  setProfession();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void setProfession() {
    HttpHelper<CommonReponse>(CommonReponse.new).post(
      apiSetUserProfession,
      {
        'profession': _selectedProfessionId,
      },
      onResponse: (response) {
        GetIt.I<UserManager>().getCurrentUser()?.profession =
            _selectedProfessionId;
        if (widget.firstRegister) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false);
        } else {
          ToastHelper.show(
              AppLocalizations.of(context)!.toastProfessionSetSuccess);
          Navigator.pop(context);
        }
      },
      onError: (error, message) {},
    );
  }
}
