import 'dart:async';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:tobias/tobias.dart';

class AlipayHelper {
  Tobias tobias = Tobias();
  AlipayHelper();
  Map? currentResponse;
  AlipayPrepayResponse? currentPrepayResponse;
  void initAlipayPay() {}

  Future<bool> checkAlipay() async {
    return await tobias.isAliPayInstalled;
  }

  void pay(String productId, Function(Map) onPay) {
    HttpHelper<AlipayPrepayResponse>(AlipayPrepayResponse.new)
        .post(apiStartAlipayTransaction, {'product_id': productId},
            onResponse: (response) {
      currentPrepayResponse = response;
      _startAlipayPay(response).then((result) {
        currentResponse = result;
        onPay(result);
      });
    }, onError: (code, msg) {
      ToastHelper.show(msg);
    });
  }

  Future<Map> _startAlipayPay(AlipayPrepayResponse response) {
    return tobias.pay(response.orderString);
  }

  void verifyPurchase(
      String? result, Function(TransactionVerifyReponse?) onVerify) {
    if (currentResponse == null || currentPrepayResponse == null) return;
    HttpHelper<TransactionVerifyReponse>(TransactionVerifyReponse.new)
        .post(apiVerifyAlipayTransaction, {
      'result': result,
      'transaction_id': currentPrepayResponse!.transactionId,
      'product_id': currentPrepayResponse!.productId,
      'product_name': currentPrepayResponse!.productName,
    }, onResponse: (response) {
      onVerify(response);
    }, onError: (code, msg) {
      ToastHelper.show(msg);
    });
  }
}
