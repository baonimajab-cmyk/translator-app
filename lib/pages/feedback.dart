import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/horizontal_dropdown.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return FeedbackState();
  }
}

class FeedbackState extends State<FeedbackPage> {
  int? dropdownvalue;

  // List of items in our dropdown menu
  // var items = [
  //   'Suggestion',
  //   'Software Bug',
  //   'Translation Error',
  //   'Just to complain',
  //   'Other',
  // ];

  TextEditingController editingController = TextEditingController();

  bool loading = false;

  List<FeedbackType> feedbackTypes = [];

  @override
  void initState() {
    super.initState();
    getFeedbackTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AbyAppBar(
          titleText: AppLocalizations.of(context)!.titleFeedback,
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(CupertinoIcons.arrow_left),
          ),
        ),
        body: UiHelper.isVerticalUI()
            ? _buildVerticalUI()
            : _buildHorizontalUI());
  }

  Widget _buildVerticalUI() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        VerticalTitle(text: AppLocalizations.of(context)!.titleFeedback),
        const SizedBox(width: 36),
        HorizontalDropdown<int>(
          items: feedbackTypes.map((FeedbackType item) {
            return HorizontalDropdownItem<int>(
              value: item.id,
              label: item.name,
            );
          }).toList(),
          hint: AppLocalizations.of(context)!.textSelectFeedbackType,
          value: dropdownvalue,
          onChanged: (value) {
            setState(() {
              dropdownvalue = value;
            });
          },
        ),
        const SizedBox(width: 36),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.symmetric(
                    vertical: BorderSide(
                        width: UiHelper.getDividerWidth(context),
                        color: Theme.of(context).dividerColor))),
            child: MongolTextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              minLines: null,
              maxLines: null,
              maxLength: 1000,
              expands: true,
              controller: editingController,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) => {},
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSans',
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surface,
                  counterStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).hintColor,
                  ),
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.hintFeedback,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).hintColor,
                  )),
            ),
          ),
        ),
        const SizedBox(width: 36),
        Align(
          alignment: Alignment.center,
          child: RedRoundedButton(
              label: AppLocalizations.of(context)!.textButtonSend,
              fill: true,
              loading: loading,
              onClick: () {
                sendFeedback();
              }),
        ),
        const SizedBox(width: 20)
      ],
    );
  }

  Widget _buildHorizontalUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.symmetric(
                    horizontal: BorderSide(
                        width: UiHelper.getDividerWidth(context),
                        color: Theme.of(context).colorScheme.outline))),
            child: DropdownButton2(
              value: dropdownvalue,
              isExpanded: true,
              underline: Container(),
              hint: Text(
                AppLocalizations.of(context)!.textSelectFeedbackType,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16),
              ),
              iconStyleData: IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).hintColor,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(0)),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(right: 16),
              ),
              items: feedbackTypes.map((FeedbackType item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    item.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                );
              }).toList(),
              // onChanged: (FeedbackType? item) {
              //   setState(() {
              //     dropdownvalue = newValue!;
              //   });
              // },
              onChanged: (value) {
                setState(() {
                  dropdownvalue = value;
                });
              },
            ),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.symmetric(
                      horizontal: BorderSide(
                          width: UiHelper.getDividerWidth(context),
                          color: Theme.of(context).dividerColor))),
              child: TextField(
                minLines: null,
                maxLines: null,
                maxLength: 1000, // todo max length
                expands: true,
                controller: editingController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) => {},
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.hintFeedback,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).hintColor,
                    )),
              ),
            ),
          ),
          const Spacer(),
          RedRoundedButton(
              label: AppLocalizations.of(context)!.textButtonSend,
              fill: true,
              loading: loading,
              onClick: () {
                sendFeedback();
              }),
          const SizedBox(
            height: 34,
          )
        ],
      ),
    );
  }

  void getFeedbackTypes() {
    HttpHelper<FeedbackTypesResponse>(FeedbackTypesResponse.new).post(
      apiGetFeedbackTypes,
      null,
      onResponse: (response) {
        setState(() {
          feedbackTypes = response.types;
        });
      },
      onError: (et, em) {
        ToastHelper.show(em);
      },
    );
  }

  void sendFeedback() {
    if (dropdownvalue == null) {
      ToastHelper.show(
          AppLocalizations.of(context)!.toastPleaseSelectFeedbackType);
      return;
    }
    String content = editingController.text.trim();
    if (content.isEmpty) {
      ToastHelper.show(AppLocalizations.of(context)!.toastFeedbackContentEmpty);
      return;
    }
    HttpHelper<CommonReponse>(CommonReponse.new).post(
      apiFeedback,
      {
        'type': dropdownvalue!,
        'content': content,
      },
      onResponse: (response) {
        ToastHelper.show(
            AppLocalizations.of(context)!.toastFeedbackSuccessfullySent);
        Navigator.pop(context);
      },
      onError: (et, em) {
        ToastHelper.show(em);
      },
    );
  }
}
