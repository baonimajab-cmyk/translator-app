import 'dart:io';

import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/rounded_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentSelectionPane extends StatefulWidget {
  final List<PaymentMethod> methods;
  final Function(PaymentMethod) onSelect;
  final PaymentMethod? selectedMethod;
  final String totalPrice;

  const PaymentSelectionPane({
    super.key,
    required this.methods,
    required this.onSelect,
    this.selectedMethod,
    required this.totalPrice,
  });

  @override
  State<StatefulWidget> createState() {
    return PaymentSelectionPaneState();
  }
}

class PaymentSelectionPaneState extends State<PaymentSelectionPane> {
  PaymentMethod? selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.selectedMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Platform.isAndroid ? 16 : 0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: UiHelper.getDividerWidth(context),
                        color: Theme.of(context).colorScheme.outline))),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.textSelectPaymentMethod,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              shrinkWrap: true,
              itemCount: widget.methods.length,
              itemBuilder: (context, index) {
                PaymentMethod method = widget.methods[index];
                return PaymentMethodItem(
                  method: method,
                  selected: method.id == selectedMethod?.id,
                  onTap: () {
                    setState(() {
                      selectedMethod = method;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.textTotalPrice,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.totalPrice,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GreyRoundedButton(
                label: AppLocalizations.of(context)!.textButtonCancel,
                fill: true,
                loading: false,
                onClick: () {
                  Navigator.pop(context);
                },
                backgroundColor: Theme.of(context).colorScheme.outline,
                forgroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              RedRoundedButton(
                label: AppLocalizations.of(context)!.textButtonConfirm,
                loading: false,
                onClick: () {
                  widget.onSelect(selectedMethod!);
                  Navigator.pop(context);
                },
                fill: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentMethodItem extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final Function() onTap;

  const PaymentMethodItem({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: UiHelper.getDividerWidth(context),
                    color: Theme.of(context).colorScheme.outline))),
        child: Row(
          children: [
            Image.asset(
              method.icon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(
              method.name,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
            const Spacer(),
            selected
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary),
                    child: const Icon(
                        size: 16,
                        color: Colors.white,
                        CupertinoIcons.check_mark),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
