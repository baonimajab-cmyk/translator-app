import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/utils/logger.dart';

/// 拉取服务端会员周期并写回 [UserManager]（需已登录且 Token 有效）。
void syncMembershipPlanFromServer(UserManager userManager) {
  final user = userManager.getCurrentUser();
  if (user == null || user.token.isEmpty) {
    return;
  }
  HttpHelper<MembershipPlanResponse>(MembershipPlanResponse.new).post(
    apiMembershipPlan,
    {},
    onResponse: (response) {
      user.membershipPlan = response.plan;
      if (response.expireDate > 0) {
        user.membershipExpireDate = response.expireDate;
      }
      userManager.saveUser(user);
    },
    onError: (et, em) {
      Logger.log('membership_plan: $em');
    },
  );
}
