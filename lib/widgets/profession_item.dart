import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class ProfessionItemView extends StatelessWidget {
  final Function(int id) onClick;
  final bool selected;
  final String name;
  final int id;
  const ProfessionItemView(
      {super.key,
      required this.selected,
      required this.onClick,
      required this.name,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClick(id);
      },
      child: UiHelper.isVerticalUI()
          ? _buildVerticalUI(context)
          : _buildHorizontalUI(context),
    );
  }

  Widget _buildVerticalUI(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: MongolText(
                name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                ),
              ),
            ),
            selected
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary),
                    child: const Icon(
                        size: 16,
                        color: Colors.white,
                        CupertinoIcons.check_mark),
                  )
                : Container()
          ]),
    );
  }

  Widget _buildHorizontalUI(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            selected
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary),
                    child: const Icon(
                        size: 16,
                        color: Colors.white,
                        CupertinoIcons.check_mark),
                  )
                : Container()
          ]),
    );
  }
}
