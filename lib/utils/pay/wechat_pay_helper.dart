import 'dart:async';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:wechat_kit/wechat_kit.dart';

class WechatPayHelper {
  late final StreamSubscription<WechatResp> _respSubs;
  WechatPrepayResponse? currentResponse;
  WechatPayHelper();

  void initWechatPay(Function(WechatResp resp) onResp) {
    _respSubs = WechatKitPlatform.instance.respStream().listen(onResp);
    WechatKitPlatform.instance.registerApp(
        appId: 'wx11cd748bbfd1e03c',
        universalLink: 'https://www.abiya-tech.com/app');
  }

  Future<bool> checkWechat() async {
    return await WechatKitPlatform.instance.isInstalled();
  }

  void prepay(String productId) {
    HttpHelper<WechatPrepayResponse>(WechatPrepayResponse.new)
        .post(apiStartWechatTransaction, {'product_id': productId},
            onResponse: (response) {
      startWechatPay(response);
    }, onError: (code, msg) {
      ToastHelper.show(msg);
    });
  }

  void startWechatPay(WechatPrepayResponse response) {
    currentResponse = response;
    WechatKitPlatform.instance.pay(
      appId: response.appid,
      partnerId: response.partnerid,
      prepayId: response.prepayId,
      package: 'Sign=WXPay',
      nonceStr: response.nonceStr,
      timeStamp: response.timestamp,
      sign: response.sign,
    );
  }

  void verifyPurchase(Function(TransactionVerifyReponse?) onVerify) {
    if (currentResponse == null) return;
    HttpHelper<TransactionVerifyReponse>(TransactionVerifyReponse.new)
        .post(apiVerifyWechatTransaction, {
      'transaction_id': currentResponse!.transactionId,
      'nonce_str': currentResponse!.nonceStr,
      'timestamp': currentResponse!.timestamp,
      'product_name': currentResponse!.productName,
      'product_id': currentResponse!.productId,
    }, onResponse: (response) {
      onVerify(response);
    }, onError: (code, msg) {
      ToastHelper.show(msg);
      onVerify(null);
    });
  }

  void dispose() {
    _respSubs.cancel();
  }
}
