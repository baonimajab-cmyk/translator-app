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
      // 验单成功后本地已写入正确到期时间；若支付回调尚未落库，membership_plan 可能仍返回旧
      // expire_date，直接覆盖会把 isMember() 打回 false（角标变灰）。到期时间取本地与服务端的较大值。
      final fresh = userManager.getCurrentUser();
      if (fresh == null) {
        return;
      }
      fresh.membershipPlan = response.plan;
      if (response.expireDate > 0) {
        final merged = response.expireDate > fresh.membershipExpireDate
            ? response.expireDate
            : fresh.membershipExpireDate;
        fresh.membershipExpireDate = merged;
      }
      userManager.saveUser(fresh);
    },
    onError: (et, em) {
      Logger.log('membership_plan: $em');
    },
  );
}
