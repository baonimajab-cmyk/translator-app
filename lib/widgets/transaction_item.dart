import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mongol/mongol.dart';

class TransactionItemView extends StatelessWidget {
  final TransactionItem data;
  const TransactionItemView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(data.time * 1000);
    var date = DateFormat('yyyy-MM-dd').format(dt);
    var time = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    final bool isVerticalUI = UiHelper.isVerticalUI();
    final cs = Theme.of(context).colorScheme;
    final double dividerW = UiHelper.getDividerWidth(context);

    final border = isVerticalUI
        ? Border.symmetric(
            vertical: BorderSide(
              width: dividerW,
              color: cs.outline,
            ),
          )
        : Border.symmetric(
            horizontal: BorderSide(
              width: dividerW,
              color: cs.outline,
            ),
          );

    return Padding(
      padding: isVerticalUI
          ? const EdgeInsets.only(left: 20)
          : const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          border: border,
        ),
        child: isVerticalUI
            ? _buildVertical(context, date, time, cs)
            : _buildHorizontal(context, date, time, cs),
      ),
    );
  }

  Widget _buildVertical(
    BuildContext context,
    String date,
    String time,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MongolText(
              date,
              rotateCJK: false,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w600,
                color: cs.onSecondary,
              ),
            ),
            const SizedBox(height: 24),
            MongolText(
              '${data.amount} (${data.currency})',
              rotateCJK: false,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
        AdaptiveDivider(isVerticalUI: true),
        Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(12, 255, 0, 0),
                  ),
                  child: Image.asset(
                    membershipBadgeAsset(data.projectId ?? 0),
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 10),
                MongolText(
                  data.product,
                  rotateCJK: false,
                  style: TextStyle(
                    overflow: TextOverflow.fade,
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                MongolText(
                  ' x 1',
                  rotateCJK: false,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSans',
                    color: cs.onSurface,
                  ),
                ),
              ],
            )),
        AdaptiveDivider(isVerticalUI: true),
        const SizedBox(width: 12),
        MongolText(
          '${l10n.textLabelTransactionId}${data.id} ',
          rotateCJK: false,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoSans',
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: 8),
        MongolText(
          '${l10n.textLabelPaymentMethod}${data.payment} ',
          rotateCJK: false,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoSans',
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: 8),
        MongolText(
          '${l10n.textLabelTransactionTime}$time ',
          rotateCJK: false,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NotoSans',
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    String date,
    String time,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
                    color: cs.onSecondary),
              ),
              const Spacer(),
              Text(
                '${data.amount} (${data.currency})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
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
                  membershipBadgeAsset(data.projectId ?? 0),
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.product} x 1',
                      style: TextStyle(
                          overflow: TextOverflow.fade,
                          fontSize: 16,
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Text(
                '',
                style: TextStyle(color: cs.onSurface, fontSize: 16),
              )
            ],
          ),
        ),
        AdaptiveDivider(isVerticalUI: false),
        const SizedBox(height: 8),
        Text(
          '${l10n.textLabelTransactionId}${data.id} ',
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          '${l10n.textLabelPaymentMethod}${data.payment} ',
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          '${l10n.textLabelTransactionTime}$time ',
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
        ),
      ],
    );
  }

  /// 会员名后角标：非会员为灰色；在会与员依据 [UserInfo.membershipPlan]。
  String membershipBadgeAsset(int projectId) {
    switch (projectId) {
      case 1:
        return 'assets/images/icon_membership_month.png';
      case 2:
        return 'assets/images/icon_membership_season.png';
      case 3:
        return 'assets/images/icon_membership_year.png';
      default:
        return 'assets/images/icon_membership_month.png';
    }
  }
}
