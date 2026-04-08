import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/db/user_manager.dart';

class CommonReponse {
  late int errCode;
  late String errMsg;
  dynamic data;
  CommonReponse(dynamic json) {
    errCode = json['et'];
    errMsg = json['em'];
    data = json['data'];
  }
}

class ConnectResponse extends CommonReponse {
  late String latestVersion;
  ConnectResponse(super.json) {
    latestVersion = data['latest_version'];
  }
}

class CheckEmailResponse extends CommonReponse {
  late bool registred;
  CheckEmailResponse(super.json) {
    registred = data['registered'];
  }
}

class VerifyCodeResponse extends CommonReponse {
  late bool verified;
  VerifyCodeResponse(super.json) {
    verified = data['verified'];
  }
}

class TranslateResponse extends CommonReponse {
  late String result;
  late int translateId;
  TranslateResponse(super.json) {
    result = data['result'];
    translateId = data['translate_id'];
  }
}

class AddFavouriteResponse extends CommonReponse {
  late bool favourite;
  AddFavouriteResponse(super.json) {
    favourite = data['favourite'];
  }
}

class DeleteHistoryResponse extends CommonReponse {
  late bool success;
  int deletedID = -1;
  DeleteHistoryResponse(super.json) {
    success = data['success'];
    deletedID = data['deleted_id'] ?? -1;
  }
}

class LoginRegisterResponse extends CommonReponse {
  late UserInfo info;
  LoginRegisterResponse(super.json) {
    info = UserInfo.fromJson(data);
  }
}

class TranslationListResponse extends CommonReponse {
  List<TranslationItem> list = [];
  bool more = false;
  TranslationListResponse(super.json) {
    more = data['more'];
    data['list'].forEach((item) {
      list.add(TranslationItem(item));
    });
  }
}

class PhraseCategoryListResponse extends CommonReponse {
  List<PhraseCategoryItem> categoryList = [];
  bool more = false;
  PhraseCategoryListResponse(super.json) {
    data['categories'].forEach((item) {
      categoryList
          .add(PhraseCategoryItem(item['id'], item['name'], item['icon']));
    });
  }
}

class PhraseCategoryItem {
  final int id;
  final String name;
  final String icon;

  PhraseCategoryItem(this.id, this.name, this.icon);
}

class LanguageListResponse extends CommonReponse {
  List<LanguageItem> languageList = [];
  List<ModelItem> models = [];
  LanguageListResponse(super.json) {
    data['languages'].forEach((item) {
      languageList.add(LanguageItem(item['id'], item['display_name'],
          item['short_name'], item['supported'] == 1 ? true : false));
    });

    data['models'].forEach((item) {
      models.add(ModelItem(item['from'], item['to'], item['support'] == 1,
          item['from_id'], item['to_id']));
    });
  }
}

class LanguageItem {
  final int id;
  final String name;
  final String shortName;
  final bool support;
  LanguageItem(this.id, this.name, this.shortName, this.support);
}

class ModelItem {
  final String from;
  final String to;
  final int fromId;
  final int toId;
  final bool support;
  ModelItem(this.from, this.to, this.support, this.fromId, this.toId);
}

class TranslationItem {
  late int id;
  late String original;
  late String result;
  late String from;
  late String to;
  late int time;
  late bool isFavourite;
  TranslationItem(dynamic data) {
    id = data['id'];
    original = data['original'] ?? '';
    result = data['result'] ?? '';
    time = data['time'] ?? 0;
    from = data['from'] ?? '';
    to = data['to'] ?? '';
    isFavourite = data['favourite'];
  }
  TranslationItem.fromLocal(
      this.id, this.original, this.result, this.time, this.from, this.to) {
    isFavourite = false;
  }
}

class MessageListResponse extends CommonReponse {
  List<MessageItem> messages = [];
  bool more = false;
  MessageListResponse(super.json) {
    more = data['more'];
    data['list'].forEach((message) {
      messages.add(MessageItem(
          id: message['id'],
          type: message['type'] ?? 0,
          title: message['title'],
          content: message['content'],
          time: message['time']));
    });
  }
}

class MessageItem {
  final int id;
  final int type;
  final String title;
  final String content;
  final int time;

  MessageItem(
      {required this.id,
      required this.type,
      required this.title,
      required this.content,
      required this.time});
}

class FaqListResponse extends CommonReponse {
  List<FaqItemData> list = [];
  bool more = false;
  FaqListResponse(super.json) {
    more = data['more'];
    data['list'].forEach((faq) {
      list.add(FaqItemData(
        id: faq['id'],
        title: faq['title'],
        content: faq['content'],
      ));
    });
  }
}

class FaqItemData {
  final int id;
  final String title;
  final String content;

  FaqItemData({
    required this.id,
    required this.title,
    required this.content,
  });
}

class TransactionVerifyReponse extends CommonReponse {
  late int transactionTime;
  late int expirationTime;
  late String transactionId;
  late String uuid;
  UserInfo? userInfo;
  TransactionVerifyReponse(super.json) {
    transactionTime = data['transaction_time'];
    expirationTime = data['expiration_time'];
    transactionId = data['transaction_id'];
    uuid = data['uuid'] ?? '';
    if (data['user_info'] != null) {
      userInfo = UserInfo.fromJson(data['user_info']);
    } else {
      userInfo = null;
    }
  }
}

class TransactionInfoResponse extends CommonReponse {
  late TransactionItem transactionData;
  TransactionInfoResponse(super.json) {
    var item = data['transaction'];
    transactionData = TransactionItem(
      id: item['id'],
      amount: item['amount'],
      payment: '',
      time: item['time'],
      product: item['product'],
      currency: item['currency'],
    );
  }
}

class TransactionListResponse extends CommonReponse {
  List<TransactionItem> list = [];
  bool more = false;
  TransactionListResponse(super.json) {
    more = data['more'];
    data['list'].forEach((item) {
      list.add(TransactionItem(
        id: item['id'],
        amount: item['amount'],
        payment: getPaymentName(item['payment']),
        time: item['time'],
        product: item['product'],
        currency: item['currency'],
      ));
    });
  }
  String getPaymentName(int type) {
    if (type == 1) {
      return 'Apple Pay';
    } else if (type == 2) {
      return 'Google Pay';
    } else if (type == 3) {
      return 'Wechat Pay';
    } else {
      return 'Alipay';
    }
  }
}

class TransactionItem {
  final String id;
  final String amount;
  final String payment;
  final int time;
  final String product;
  final String currency;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.payment,
    required this.time,
    required this.product,
    required this.currency,
  });
}

class StartTransactionResponse extends CommonReponse {
  late UserInfo userInfo;
  StartTransactionResponse(super.json) {
    userInfo = UserInfo.fromJson(data['user_info']);
  }
}

class SubscriptionProductResponse extends CommonReponse {
  List<SubscriptionProductItem> products = [];
  SubscriptionProductResponse(super.json) {
    data['subscriptions'].forEach((item) {
      products.add(SubscriptionProductItem(
          id: item['id'].toString(),
          name: item['name'],
          price: item['price'],
          currency: item['currency'],
          appStoreId: item['app_store_id'],
          playStoreId: item['play_store_id']));
    });
  }
}

class WechatPrepayResponse extends CommonReponse {
  late String prepayId;
  late String nonceStr;
  late String sign;
  late String timestamp;
  late String appid;
  late String partnerid;
  late String transactionId;
  late String productName;
  late String productId;
  WechatPrepayResponse(super.json) {
    prepayId = data['prepay_id'];
    nonceStr = data['nonce_str'];
    sign = data['sign'];
    timestamp = data['timestamp'].toString();
    appid = data['appid'];
    partnerid = data['partner_id'];
    transactionId = data['transaction_id'];
    productName = data['product_name'];
    productId = data['product_id'];
  }
}

class AlipayPrepayResponse extends CommonReponse {
  late String orderString;
  late String transactionId;
  late String productId;
  late String productName;
  AlipayPrepayResponse(super.json) {
    orderString = data['order_str'];
    transactionId = data['transaction_id'];
    productId = data['product_id'];
    productName = data['product_name'];
  }
}

class SubscriptionProductItem {
  final String id;
  final String currency;
  final String name;
  final String price;
  final String appStoreId;
  final String playStoreId;

  SubscriptionProductItem({
    required this.id,
    required this.currency,
    required this.name,
    required this.price,
    required this.appStoreId,
    required this.playStoreId,
  });
}

class FeedbackTypesResponse extends CommonReponse {
  List<FeedbackType> types = [];
  FeedbackTypesResponse(super.json) {
    data['types'].forEach((typeJson) {
      types.add(FeedbackType(id: typeJson['id'], name: typeJson['name']));
    });
  }
}

class FeedbackType {
  final int id;
  final String name;
  FeedbackType({required this.id, required this.name});
}

String getImageUrl(String url) {
  return host + url;
}

class ProfessionListResponse extends CommonReponse {
  List<ProfessionItem> list = [];
  ProfessionListResponse(super.json) {
    data['professions'].forEach((item) {
      list.add(ProfessionItem(id: item['id'], name: item['name']));
    });
  }
}

class ProfessionItem {
  final int id;
  final String name;
  ProfessionItem({required this.id, required this.name});
}
