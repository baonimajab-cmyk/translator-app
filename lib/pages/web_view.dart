import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';

class WebView extends StatefulWidget {
  final String url;
  const WebView({super.key, required this.url});

  @override
  State<StatefulWidget> createState() {
    return WebViewState();
  }
}

class WebViewState extends State<WebView> {
  InAppWebViewController? controller;
  String? title;
  bool showTitle = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: Icon(CupertinoIcons.xmark,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              if (showTitle)
                Expanded(
                  child: Text(
                    title ?? 'Abiya Translator',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSans',
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              IconButton(onPressed: () {}, icon: Container()),
            ],
          ),
          Expanded(
              child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url), headers: {
              'User': GetIt.I<UserManager>().getCurrentUser()?.name ?? '',
              'Language': GetIt.I<SystemSetting>().localeName,
              'Theme': GetIt.I<SystemSetting>().isDarkMode(context)
                  ? 'dark'
                  : 'light',
            }),
            onWebViewCreated: (controller) {
              this.controller = controller;
            },
            onLoadStop: (controller, url) {
              controller.getTitle().then((t) => {
                    if (showTitle)
                      setState(() {
                        title = t;
                      })
                  });
            },
          )),
        ],
      ),
    );
  }
}
