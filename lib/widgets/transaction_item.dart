import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItemView extends StatelessWidget {
  final TransactionItem data;
  const TransactionItemView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(data.time * 1000);
    // var df = DateFormat('MM/dd/yyyy, HH:mm').format(dt);
    var date = DateFormat('yyyy-MM-dd').format(dt);
    var time = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.symmetric(
                horizontal: BorderSide(
                    width: UiHelper.getDividerWidth(context),
                    color: Theme.of(context).colorScheme.outline))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    date,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  const Spacer(),
                  Text(
                    data.amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              ),
            ),
            AdaptiveDivider(isVerticalUI: false),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(12, 255, 0, 0)),
                    child: Image.asset(
                      'assets/images/icon_transaction.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.product,
                          style: TextStyle(
                              overflow: TextOverflow.fade,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.product
                              .substring(data.product.indexOf(RegExp('\\d'))),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    'x1',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16),
                  )
                ],
              ),
            ),
            AdaptiveDivider(isVerticalUI: false),
            const SizedBox(height: 8),
            Text(
              'Transaction ID: ${data.id}',
              style:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Payment Method: ${data.payment}',
              style:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Transaction Time: $time',
              style:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
