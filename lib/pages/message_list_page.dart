import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:mongol/mongol.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MessageListState();
  }
}

class MessageListState extends State<MessageListPage> {
  static const _pageSize = 6;

  final PagingController<int, MessageItem> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      getMessageList(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AbyAppBar(
          titleText: AppLocalizations.of(context)!.titleMessages,
          leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              CupertinoIcons.arrow_left,
            ),
          ),
        ),
        body: UiHelper.isVerticalUI()
            ? _buildVerticalUI()
            : _buildHorizontalUI());
  }

  Widget _buildVerticalUI() {
    return Row(
      children: [
        VerticalTitle(text: AppLocalizations.of(context)!.titleMessages),
        Expanded(child: _buildList(true)),
      ],
    );
  }

  Widget _buildHorizontalUI() {
    return _buildList(false);
  }

  Widget _buildList(bool isVertical) {
    return PagedListView<int, MessageItem>(
      scrollDirection: isVertical ? Axis.horizontal : Axis.vertical,
      padding: isVertical
          ? const EdgeInsets.only(right: 16)
          : const EdgeInsets.only(bottom: 16),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<MessageItem>(
        firstPageErrorIndicatorBuilder: (context) => const FirstPageErrorView(),
        itemBuilder: (context, item, index) {
          return MessageItemView(data: item);
        },
        noItemsFoundIndicatorBuilder: (context) {
          return EmptyListIndicator(
              text: AppLocalizations.of(context)!.textMessageListEmpty);
        },
        noMoreItemsIndicatorBuilder: (context) => const SizedBox(
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  void getMessageList(int page) {
    HttpHelper<MessageListResponse>(MessageListResponse.new).post(
      apiGetMessageList,
      {
        'page': page,
        'limit': _pageSize,
      },
      onResponse: (response) {
        if (response.more) {
          final nextPageKey = page + 1;
          _pagingController.appendPage(response.messages, nextPageKey);
        } else {
          _pagingController.appendLastPage(response.messages);
        }
      },
      onError: (et, em) {
        //todo check
        _pagingController.error = em;
      },
    );
  }
}

class MessageItemView extends StatelessWidget {
  final MessageItem data;
  const MessageItemView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(data.time * 1000);
    // var df = DateFormat('MM/dd/yyyy, HH:mm').format(dt);
    var df = DateFormat('dd/MM HH:mm').format(dt);
    var dateColor = Theme.of(context).hintColor;
    return Padding(
      padding: UiHelper.isVerticalUI()
          ? const EdgeInsets.only(left: 16.0, top: 16, bottom: 16)
          : const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.all(16),
          child: UiHelper.isVerticalUI()
              ? _buildVerticalUI(context, df, dateColor)
              : _buildHorizontalUI(context, df, dateColor),
        ),
      ),
    );
  }

  Widget _buildVerticalUI(BuildContext context, String date, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            MongolText(
              data.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSans',
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            MongolText(
              date,
              style:
                  TextStyle(fontSize: 14, color: color, fontFamily: 'NotoSans'),
            )
          ],
        ),
        const SizedBox(width: 16),
        MongolText(
          data.content,
          style: TextStyle(fontSize: 16, color: color, fontFamily: 'NotoSans'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHorizontalUI(BuildContext context, String date, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              date,
              style: TextStyle(fontSize: 14, color: color),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.content,
          style: TextStyle(fontSize: 16, color: color),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
