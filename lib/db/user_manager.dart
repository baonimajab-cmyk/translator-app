import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String userKey = 'USER';
const String userAgreementKey = 'FIRST_USE';
const String lastTransactionUuid = 'LAST_TRANSACTION_UUID';
const String lastTransactionId = 'LAST_TRANSACTION_ID';

class UserManager {
  late ValueNotifier<UserInfo?> notifier = ValueNotifier(null);
  UserManager() {
    loadUser();
  }

  void loadUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userJson = preferences.getString(userKey);
    if (userJson != null && userJson.isNotEmpty) {
      UserInfo user = UserInfo.fromJson(json.decode(userJson));
      notifier.value = user;
    }
  }

  UserInfo? getCurrentUser() {
    return notifier.value;
  }

  void saveUser(UserInfo user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(user.toJson());
    preferences.setString(userKey, jsonStr);
    // 必须用新实例赋值：各处常对 getCurrentUser() 原地改字段后再 save；
    // 若引用与 notifier.value 相同，ValueNotifier 不会 notify，其它页的
    // ValueListenableBuilder 不会重建（会员页因 setState 仍会刷新，造成不一致）。
    notifier.value = UserInfo.fromJson(json.decode(jsonStr));
  }

  void logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(userKey, '');
    notifier.value = null;
  }

  Future<bool> userAgreementAccepted() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ret = preferences.getBool(userAgreementKey);
    if (ret == null) {
      return false;
    } else {
      return ret;
    }
  }

  void setUserAgreementAccepted() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(userAgreementKey, true);
  }

  Future<String?> getLastTransactionUuid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(lastTransactionUuid);
  }

  void setLastTransactionUuid(String uuid) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(lastTransactionUuid, uuid);
  }

  Future<String?> getLastTransactionId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(lastTransactionId);
  }

  void setLastTransactionId(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(lastTransactionId, id);
  }
}

class UserInfo {
  String uuid;
  String name;
  String token;
  String email;
  String mobile;
  String wechat;
  int language;
  int profession;
  int membershipExpireDate;
  String tags;

  /// 服务端 `POST /app/membership_plan` 返回的 `plan`：monthly / quarterly / yearly / unknown
  String? membershipPlan;
  UserInfo(
      {required this.uuid,
      required this.name,
      required this.token,
      required this.email,
      required this.mobile,
      required this.wechat,
      required this.language,
      required this.profession,
      required this.membershipExpireDate,
      required this.tags,
      this.membershipPlan});
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
        uuid: json['uuid'],
        name: json['name'],
        token: json['token'] ?? '',
        email: json['email'] ?? '',
        mobile: json['mobile'] ?? '',
        wechat: json['wechat'] ?? '',
        language: json['language'] ?? 0,
        profession: json['profession'] ?? 0,
        membershipExpireDate: json['expire_date'] ?? 0,
        tags: json['tags'] ?? '',
        membershipPlan: json['plan'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "name": name,
      "token": token,
      "email": email,
      "mobile": mobile,
      "wechat": wechat,
      "language": language,
      "profession": profession,
      "expire_date": membershipExpireDate,
      "tags": tags,
      if (membershipPlan != null) "plan": membershipPlan,
    };
  }

  bool isMember() {
    var now = DateTime.now().millisecondsSinceEpoch;
    bool isMember = membershipExpireDate > now;
    return isMember;
  }
}

/// 会员名后角标：非会员为灰色；在会与员依据 [UserInfo.membershipPlan]。
String membershipBadgeAsset(UserInfo user) {
  if (!user.isMember()) {
    return 'assets/images/icon_membership_inactive_small.png';
  }
  switch (user.membershipPlan) {
    case 'monthly':
      return 'assets/images/icon_membership_month.png';
    case 'quarterly':
      return 'assets/images/icon_membership_season.png';
    case 'yearly':
      return 'assets/images/icon_membership_year.png';
    default:
      return 'assets/images/icon_membership_month.png';
  }
}
