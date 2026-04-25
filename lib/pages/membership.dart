import 'dart:async';
import 'dart:io';

import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:abiya_translator/db/user_manager.dart';
import 'package:abiya_translator/l10n/app_localizations.dart';
import 'package:abiya_translator/login_register/login_register_page.dart';
import 'package:abiya_translator/pages/faq.dart';
import 'package:abiya_translator/pages/transactions.dart';
import 'package:abiya_translator/pages/web_view.dart';
import 'package:abiya_translator/utils/constants.dart';
import 'package:abiya_translator/utils/device_helper.dart';
import 'package:abiya_translator/utils/logger.dart';
import 'package:abiya_translator/utils/pay/alipay_helper.dart';
import 'package:abiya_translator/utils/pay/wechat_pay_helper.dart';
import 'package:abiya_translator/utils/system_setting.dart';
import 'package:abiya_translator/utils/membership_plan_sync.dart';
import 'package:abiya_translator/utils/toast_helper.dart';
import 'package:abiya_translator/utils/ui_helper.dart';
import 'package:abiya_translator/widgets/alert_dialog.dart';
import 'package:abiya_translator/widgets/aby_app_bar.dart';
import 'package:abiya_translator/widgets/list_item.dart';
import 'package:abiya_translator/widgets/payment_selection_pane.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mongol/mongol.dart';
import 'package:wechat_kit/wechat_kit.dart';

import 'package:abiya_translator/config/app_platform.dart';

const Set<String> appleIdList = <String>{
  'abiya_translator_membership_1_month',
  'abiya_translator_member_3_months',
  'abiya_translator_membership_1_year'
};
const Set<String> androidIdList = <String>{'1', '2', '3'};
const Set<String> googleIdList = <String>{
  'membership_1_month',
  'membership_3_months',
  'membership_1_year'
};

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MembershipPageState();
  }
}

class MembershipPageState extends State<MembershipPage> {
  UserManager userManager = GetIt.I<UserManager>();
  bool loading = false;
  String selectedProductId = '';
  late StreamSubscription<List<PurchaseDetails>> subscriptions;
  bool transactionVerified = false;
  List<ProductDetails> iapProductList = [];
  List<SubscriptionProductItem> productList = [];
  bool agreementChecked = false;
  bool showRestore = Platform.isIOS; //only show restore purchase on ios devices

  bool purchaseAsGuest = false;
  WechatPayHelper wechatPayHelper = WechatPayHelper();
  AlipayHelper alipayHelper = AlipayHelper();
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      initIapPurchase(false);
    } else if (Platform.isAndroid) {
      if (PlatformConfig.current == AppPlatform.google) {
        initIapPurchase(true);
      } else {
        wechatPayHelper.initWechatPay(onWechatPayResponse);
        getSubscriptionItems();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncMembershipPlanFromServer(userManager);
    });
  }

  // void onAlipayPayResponse(AlipayResp resp) {
  //   Logger.log('alipay pay response: ${resp.resultStatus}');
  //   if (resp.resultStatus == 9000) {
  //     //支付成功
  //     alipayHelper.verifyPurchase(resp.result, (response) {
  //       setState(() {
  //         loading = false;
  //       });
  //       if (response != null) {
  //         deliverProduct(response);
  //       }
  //     });
  //   } else {
  //     //支付失败
  //   }
  // }

  void onWechatPayResponse(WechatResp resp) async {
    //https://pay.weixin.qq.com/doc/v3/merchant/4013070351
    if (resp is WechatPayResp) {
      final String content = 'pay: ${resp.errorCode} ${resp.errorMsg}';
      if (resp.errorCode == -1) {
        //可能的原因：签名错误、未注册AppID、项目设置AppID不正确、注册的AppID与设置的不匹配、其他异常原因等。
      } else if (resp.errorCode == -2) {
        //用户取消支付返回App，商户可自行处理展示。
      } else {
        //支付成功，调用后端接口查单，如果订单已支付则展示支付成功页面
        wechatPayHelper.verifyPurchase((response) {
          setState(() {
            loading = false;
          });
          if (response != null) {
            deliverProduct(response);
          }
        });
      }
      Logger.log(content);
    }
  }

  void initIapPurchase(bool loadGoogleProducts) {
    final Stream<List<PurchaseDetails>> purchaseUpdate =
        InAppPurchase.instance.purchaseStream;
    subscriptions = purchaseUpdate.listen((purchaseList) {
      onPurchaseUpdate(purchaseList);
    }, onDone: () {
      subscriptions.cancel();
    }, onError: (err) {
      //todo error handle
      Logger.log('error purchasing: $err');
    });
    getIapProductList(loadGoogleProducts);
  }

  void startInAppPurchase(ProductDetails detail, String uuid) async {
    setState(() {
      loading = true;
    });

    final PurchaseParam param =
        PurchaseParam(productDetails: detail, applicationUserName: uuid);
    try {
      bool purchaseStarted =
          await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      if (!purchaseStarted) {
        setState(() {
          loading = false;
        });
        Logger.log("unable to start purchase");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      Logger.log('error purchasing: $e');
    }
  }

  void startTransaction(SubscriptionProductItem detail) async {
    if (Platform.isIOS) {
      startIapPurchase(detail);
    } else if (Platform.isAndroid) {
      showAndroidPaymentSelection(detail);
    }
  }

  void startIapPurchase(SubscriptionProductItem detail) {
    setState(() {
      loading = true;
    });
    DeviceHelper deviceHelper = GetIt.I<DeviceHelper>();
    HttpHelper<StartTransactionResponse>(StartTransactionResponse.new).post(
        apiStartIapTransaction,
        {'guest': purchaseAsGuest, 'device': deviceHelper.getJsonParam()},
        onResponse: (response) {
      if (purchaseAsGuest) {
        //we have to store the guest user information
        userManager.saveUser(response.userInfo);
      }
      setState(() {
        loading = false;
      });
      for (var item in iapProductList) {
        if (item.id == detail.appStoreId || item.id == detail.playStoreId) {
          startInAppPurchase(item, response.userInfo.uuid);
          return;
        }
      }
    }, onError: (et, em) {
      setState(() {
        loading = false;
      });
      if (et >= 1000 && !purchaseAsGuest) {
        showLoginAlert();
      }
    });
  }

  void showAndroidPaymentSelection(SubscriptionProductItem detail) {
    List<PaymentMethod> methods = [
      PaymentMethod(
          id: '1',
          name: AppLocalizations.of(context)!.textWechatPay,
          icon: 'assets/images/icons/icon_wechat_pay.png'),
      PaymentMethod(
          id: '2',
          name: AppLocalizations.of(context)!.textAlipay,
          icon: 'assets/images/icons/icon_alipay.png'),
      PaymentMethod(
          id: '3',
          name: AppLocalizations.of(context)!.textGooglePay,
          icon: 'assets/images/icons/icon_google_pay.png'),
    ];
    showMaterialModalBottomSheet(
        context: context,
        expand: false,
        backgroundColor: Colors.transparent,
        builder: (context) => PaymentSelectionPane(
              totalPrice: detail.price,
              selectedMethod: methods[0],
              methods: methods,
              onSelect: (method) {
                Logger.log('selected method: ${method.name}');
                onSelectAndroidPaymentMethod(method.id, detail);
              },
            ));
  }

  void onSelectAndroidPaymentMethod(
      String id, SubscriptionProductItem detail) async {
    Logger.log('selected method: $id');
    if (id == '1') {
      wechatPayHelper.checkWechat().then((installed) {
        if (!installed) {
          setState(() {
            loading = false;
          });
          if (mounted) {
            ToastHelper.show(
                AppLocalizations.of(context)!.textWechatNotInstalled);
          }
          return;
        }
        setState(() {
          loading = true;
        });
        wechatPayHelper.prepay(detail.id);
      });
    } else if (id == '2') {
      setState(() {
        loading = true;
      });
      alipayHelper.checkAlipay().then((installed) {
        if (!installed) {
          setState(() {
            loading = false;
          });
          if (mounted) {
            ToastHelper.show(
                AppLocalizations.of(context)!.toastAlipayNotInstalled);
          }
          return;
        }
        setState(() {
          loading = true;
        });
        alipayHelper.pay(detail.id, (result) {
          Logger.log('alipay pay result: $result');
          if (result['resultStatus'] == "9000") {
            alipayHelper.verifyPurchase(result['result'], (response) {
              setState(() {
                loading = false;
              });
              if (response != null) {
                deliverProduct(response);
              }
            });
          }
        });
      });
    } else if (id == '3') {
      //google pay
      for (var item in iapProductList) {
        if (item.id == detail.playStoreId) {
          startIapPurchase(detail);
          return;
        }
      }
    }
  }

  void onClickBuy(SubscriptionProductItem detail) async {
    if (loading) {
      return;
    }
    UserInfo? user = userManager.getCurrentUser();
    if (user == null && !purchaseAsGuest) {
      showLoginAlert();
      return;
    }
    if (!agreementChecked) {
      showCheckAgreementBox();
      return;
    }
    startTransaction(detail);
  }

  void deliverProduct(TransactionVerifyReponse response) {
    Logger.log('expires at : ${response.expirationTime}');
    final planFromVerify = response.membershipPlanFromProductId;
    UserInfo? info = userManager.getCurrentUser();
    if (info != null) {
      info.membershipExpireDate = response.expirationTime;
      if (planFromVerify != null) {
        info.membershipPlan = planFromVerify;
      }
      userManager.saveUser(info);
      syncMembershipPlanFromServer(userManager);
      userManager.setLastTransactionUuid(info.uuid);
      userManager.setLastTransactionId(response.transactionId);
    } else {
      if (response.userInfo != null) {
        final guest = response.userInfo!;
        if (planFromVerify != null) {
          guest.membershipPlan = planFromVerify;
        }
        userManager.saveUser(guest);
        syncMembershipPlanFromServer(userManager);
        userManager.setLastTransactionUuid(guest.uuid);
        userManager.setLastTransactionId(response.transactionId);
      }
    }
  }

  void verifyGooglePurchase(
      String productID, String productName, String purchaseToken) async {
    setState(() {
      loading = true;
    });
    HttpHelper<TransactionVerifyReponse>(TransactionVerifyReponse.new)
        .post(apiVerifyGoogleTransaction, {
      "product_id": productID,
      "product_name": productName,
      "purchase_token": purchaseToken
    }, onResponse: (response) {
      if (context.mounted) {
        setState(() {
          loading = false;
        });
        deliverProduct(response);
      }
    }, onError: (et, em) {
      if (context.mounted) {
        setState(() {
          loading = false;
        });
      }
      Logger.log(em);
    });
  }

  void verifyIosPurchase(String? transactionId) async {
    setState(() {
      loading = true;
    });
    //todo check
    HttpHelper<TransactionVerifyReponse>(TransactionVerifyReponse.new).post(
      apiVerifyIosTransaction,
      {'trans_id': transactionId, 'type': 1},
      onResponse: (response) {
        if (context.mounted) {
          setState(() {
            loading = false;
          });
        }
        deliverProduct(response);
      },
      onError: (et, em) {
        if (context.mounted) {
          setState(() {
            loading = false;
          });
        }
        Logger.log(em);
      },
    );
  }

  void getIapProductList(bool loadGoogleProducts) async {
    setState(() {
      loading = true;
    });
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (!mounted) {
      return;
    }
    if (!isAvailable && PlatformConfig.current != AppPlatform.china) {
      Logger.log("IAP not available");
      // toast 提示 用户支付环境不支持
      ToastHelper.show(
          AppLocalizations.of(context)!.textGooglePlayProductUnavailable);

      if (loadGoogleProducts) {
        getSubscriptionItems();
        return;
      }
      setState(() {
        loading = false;
      });
      return;
    }

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(loadGoogleProducts ? googleIdList : appleIdList);
    if (!mounted) {
      return;
    }
    if (response.error != null) {
      Logger.log(response.error.toString());
      if (loadGoogleProducts) {
        getSubscriptionItems();
      } else {
        setState(() {
          loading = false;
        });
      }
      return;
    }

    if (response.productDetails.isEmpty) {
      Logger.log("Product details empty.");
      if (loadGoogleProducts) {
        getSubscriptionItems();
      } else {
        setState(() {
          loading = false;
        });
      }
      return;
    }

    List<ProductDetails> products = response.productDetails;
    setState(() {
      loading = false;
      for (ProductDetails detail in products) {
        iapProductList.add(detail);
      }
      //the product list doesn't come with sorted price
      //so we have to sort them with price in accending order
      iapProductList.sort((p1, p2) {
        return p1.rawPrice <= p2.rawPrice ? -1 : 1;
      });
      getSubscriptionItems();
      //select last item by default
      selectedProductId = iapProductList.last.id;
    });
  }

  void onPurchaseUpdate(List<PurchaseDetails> purchaseList) async {
    for (var details in purchaseList) {
      if (details.status == PurchaseStatus.pending) {
        setState(() {
          loading = true;
        });
      } else {
        setState(() {
          loading = false;
        });
        if (details.status == PurchaseStatus.error) {
          _handleError(details.error!);
        } else if (details.status == PurchaseStatus.purchased ||
            details.status == PurchaseStatus.restored) {
          // if (details.status == PurchaseStatus.restored &&
          //     transactionVerified) {
          //   return;
          // }
          Logger.log(
              'verify purchase id(${details.status.name}): ${details.purchaseID} ');

          if (details.verificationData.source == 'google_play') {
            String productName = '';
            for (SubscriptionProductItem detail in productList) {
              if (detail.id == details.productID) {
                productName = detail.name;
              }
            }
            verifyGooglePurchase(details.productID, productName,
                details.verificationData.serverVerificationData);
          } else if (details.verificationData.source == '') {
            verifyIosPurchase(details.purchaseID);
          }
          await InAppPurchase.instance.completePurchase(details);
        }
        if (details.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(details);
        }
      }
    }
  }

  void _handleError(IAPError error) {
    Logger.log('${error.code}: ${error.message}');
    ToastHelper.show('${error.code}: ${error.message}');
  }

  void showCheckAgreementBox() {
    Alert.show(
        context,
        AppLocalizations.of(context)!.alertCheckMembershipAgreementTitle,
        AppLocalizations.of(context)!.alertCheckMembershipAgreement,
        AppLocalizations.of(context)!.textButtonAgree,
        AppLocalizations.of(context)!.textButtonCancel, () {
      setState(() {
        agreementChecked = true;
      });
      Navigator.pop(context);
    });
  }

  void showLoginAlert() {
    Alert.show(
      context,
      AppLocalizations.of(context)!.alertLoginTitle,
      Platform.isIOS
          ? AppLocalizations.of(context)!.alertLoginMsgIos
          : AppLocalizations.of(context)!.alertLoginMsg,
      AppLocalizations.of(context)!.textButtonOK,
      AppLocalizations.of(context)!.textButtonCancel,
      () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginRegisterPage()),
        );
      },
      onCancel: () {
        userManager.logout();
        if (Platform.isIOS) {
          purchaseAsGuest = true;
          purchaseSelectedProduct();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (Platform.isIOS) {
      subscriptions.cancel();
    }
    if (Platform.isAndroid) {
      wechatPayHelper.dispose();
    }
  }

  /// 布局与 [MembershipRightsView] 一致：isVerticalUI 为 Row + MongolText，否则 Column + Text。
  Widget _buildSubscriptionNotice(BuildContext context) {
    // 国内平台不显示订阅说明
    if (PlatformConfig.current == AppPlatform.china) {
      return const SizedBox.shrink();
    }
    final bool isVerticalUI = UiHelper.isVerticalUI();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final double dividerW = UiHelper.getDividerWidth(context);

    // 订阅说明标题
    final String titleText =
        AppLocalizations.of(context)!.textSubscriptionTerms;
    // 订阅说明内容

    String bodyText = PlatformConfig.current == AppPlatform.google
        ? AppLocalizations.of(context)!.textSubscriptionAutoRenewGoogle
        : AppLocalizations.of(context)!.textSubscriptionAutoRenewApple;

    final TextStyle titleStyleMo = TextStyle(
      fontSize: 18,
      fontFamily: 'NotoSans',
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    );
    final TextStyle bodyStyleMo = TextStyle(
      fontSize: 13,
      height: 1.5,
      fontFamily: 'NotoSans',
      color: cs.onSurface.withValues(alpha: 0.82),
    );
    final TextStyle titleStyleH = theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ) ??
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        );
    final TextStyle bodyStyleH = TextStyle(
      fontSize: 13,
      height: 1.5,
      color: cs.onSurface.withValues(alpha: 0.82),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: isVerticalUI
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
              ),
      ),
      child: isVerticalUI
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MongolText(titleText, style: titleStyleMo),
                const SizedBox(width: 5),
                MongolText(bodyText, style: bodyStyleMo),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(titleText, style: titleStyleH),
                ),
                const SizedBox(height: 20),
                Text(bodyText, style: bodyStyleH),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbyAppBar(
        titleText: AppLocalizations.of(context)!.titleMembership,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(
            CupertinoIcons.arrow_left,
          ),
        ),
      ),
      body: UiHelper.isVerticalUI() ? _buildVerticalUI() : _buildHorizontalUI(),
    );
  }

  Widget _buildVerticalUI() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder<UserInfo?>(
        valueListenable: userManager.notifier,
        builder: (BuildContext context, UserInfo? userInfo, Widget? child) {
          return Stack(
            children: [
              Positioned(
                left: 46,
                top: 0,
                bottom: 0,
                right: 60, // Leave space for the right-side container
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UserBanner(userInfo: userInfo),
                          const SizedBox(width: 20),
                          ProductListView(
                              products: productList,
                              selectedProductId: selectedProductId,
                              onSelectProduct: (String id) {
                                setState(() {
                                  selectedProductId = id;
                                });
                              }),
                          const SizedBox(width: 20),
                          _buildSubscriptionNotice(context),
                          PlatformConfig.current == AppPlatform.china
                              ? const SizedBox.shrink()
                              : const SizedBox(width: 20),
                          const MembershipRightsView(),
                          AdaptiveListView(children: [
                            ListGroup(dividerMargin: 48, children: [
                              ListItem(
                                icon:
                                    'assets/images/icons/icon_membership_faq.png',
                                text: AppLocalizations.of(context)!.textFaq,
                                onClick: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FaqList(
                                                type: FaqList.typeMembership,
                                              )));
                                },
                              ),
                              ListItem(
                                icon:
                                    'assets/images/icons/icon_purchase_history.png',
                                text: AppLocalizations.of(context)!
                                    .textPurchaseHistory,
                                onClick: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TransactionList()));
                                },
                              ),
                              if (showRestore) ...[
                                ListItem(
                                  icon:
                                      'assets/images/icons/icon_restore_purchase.png',
                                  text: AppLocalizations.of(context)!
                                      .textButtonRestorePurchase,
                                  onClick: () {
                                    restorePurchase();
                                  },
                                )
                              ],
                            ]),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 46,
                  child: VerticalTitle(
                      text: AppLocalizations.of(context)!.titleMembership)),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: 60,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                          left: BorderSide(
                              width: UiHelper.getDividerWidth(context),
                              color: Theme.of(context).colorScheme.outline))),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                              shape: const CircleBorder(),
                              checkColor: Colors.white,
                              fillColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context).colorScheme.primary;
                                }
                                return Colors.white12;
                              }),
                              side: BorderSide(
                                  width: UiHelper.getDividerWidth(context)),
                              value: agreementChecked,
                              onChanged: (checked) {
                                setState(() {
                                  agreementChecked = checked!;
                                });
                              }),
                        ),
                        Flexible(
                          child: Transform.translate(
                            offset: Offset(2, 0),
                            child: MembershipAgreementText(),
                          ),
                        ),
                        Spacer(),
                        GoPremiumButton(
                          loading: loading,
                          onClick: () => purchaseSelectedProduct(),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalUI() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder<UserInfo?>(
        valueListenable: userManager.notifier,
        builder: (BuildContext context, UserInfo? userInfo, Widget? child) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            UserBanner(userInfo: userInfo),
                            const SizedBox(
                              height: 20,
                            ),
                            ProductListView(
                                products: productList,
                                selectedProductId: selectedProductId,
                                onSelectProduct: (String id) {
                                  setState(() {
                                    selectedProductId = id;
                                  });
                                }),
                            const SizedBox(
                              height: 20,
                            ),
                            _buildSubscriptionNotice(context),
                            PlatformConfig.current == AppPlatform.china
                                ? const SizedBox.shrink()
                                : const SizedBox(height: 20),
                            const MembershipRightsView(),
                            AdaptiveListView(
                              children: [
                                ListGroup(
                                  dividerMargin: 48,
                                  children: [
                                    ListItem(
                                      icon:
                                          'assets/images/icons/icon_membership_faq.png',
                                      text:
                                          AppLocalizations.of(context)!.textFaq,
                                      onClick: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FaqList(
                                                      type: FaqList
                                                          .typeMembership,
                                                    )));
                                      },
                                    ),
                                    ListItem(
                                      icon:
                                          'assets/images/icons/icon_purchase_history.png',
                                      text: AppLocalizations.of(context)!
                                          .textPurchaseHistory,
                                      onClick: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const TransactionList()));
                                      },
                                    ),
                                    showRestore
                                        ? ListItem(
                                            icon:
                                                'assets/images/icons/icon_restore_purchase.png',
                                            text: AppLocalizations.of(context)!
                                                .textButtonRestorePurchase,
                                            onClick: () {
                                              restorePurchase();
                                            },
                                          )
                                        : null
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                          top: BorderSide(
                              width: UiHelper.getDividerWidth(context),
                              color: Theme.of(context).colorScheme.outline))),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                    shape: const CircleBorder(),
                                    checkColor: Colors.white,
                                    fillColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary;
                                      }
                                      return Colors.white12;
                                    }),
                                    side: BorderSide(
                                        width:
                                            UiHelper.getDividerWidth(context)),
                                    value: agreementChecked,
                                    onChanged: (checked) {
                                      setState(() {
                                        agreementChecked = checked!;
                                      });
                                    }),
                              ),
                              const Flexible(child: MembershipAgreementText()),
                            ],
                          ),
                        ),
                        GoPremiumButton(
                          loading: loading,
                          onClick: () => purchaseSelectedProduct(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void restorePurchase() async {
    UserInfo? userInfo = userManager.getCurrentUser();
    String? uuid = userInfo?.uuid;
    setState(() {
      loading = true;
    });
    await InAppPurchase.instance.restorePurchases(applicationUserName: uuid);
  }

  void purchaseSelectedProduct() {
    for (SubscriptionProductItem detail in productList) {
      if (detail.id == selectedProductId) {
        onClickBuy(detail);
        return;
      }
    }
  }

  ProductDetails? getIapProductDetail(SubscriptionProductItem item) {
    String storeProductId = '';
    if (Platform.isIOS) {
      storeProductId = item.appStoreId;
    } else if (Platform.isAndroid &&
        PlatformConfig.current == AppPlatform.google) {
      storeProductId = item.playStoreId;
    }

    if (storeProductId.isEmpty) {
      return null;
    }

    for (final detail in iapProductList) {
      if (detail.id == storeProductId) {
        return detail;
      }
    }
    return null;
  }

  String getProductDisplayPrice(SubscriptionProductItem item) {
    final ProductDetails? iapDetail = getIapProductDetail(item);
    if (iapDetail != null && iapDetail.price.isNotEmpty) {
      return iapDetail.price;
    }
    return '${item.currency}${item.price}';
  }

  void getSubscriptionItems() {
    HttpHelper<SubscriptionProductResponse>(SubscriptionProductResponse.new)
        .post(apiGetSubscriptionProducts, {}, onResponse: (response) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        loading = false;
        productList = response.products.map((item) {
          return SubscriptionProductItem(
              id: item.id,
              name: item.name,
              price: getProductDisplayPrice(item),
              currency: item.currency,
              appStoreId: item.appStoreId,
              playStoreId: item.playStoreId);
        }).toList();
      });
      if (productList.isNotEmpty) {
        selectedProductId = productList.last.id;
      }
    }, onError: (code, msg) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        loading = false;
      });
      ToastHelper.show(msg);
    });
  }
}

class MembershipRightsView extends StatelessWidget {
  const MembershipRightsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: isVerticalUI
              ? Border.symmetric(
                  vertical: BorderSide(
                      width: UiHelper.getDividerWidth(context),
                      color: Theme.of(context).colorScheme.outline))
              : Border.symmetric(
                  horizontal: BorderSide(
                      width: UiHelper.getDividerWidth(context),
                      color: Theme.of(context).colorScheme.outline))),
      child: isVerticalUI
          ? _buildVerticalLayout(context)
          : _buildHorizontalLayout(context),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MongolText(
          AppLocalizations.of(context)!.titleMembershipRight,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_trans.png',
                name: AppLocalizations.of(context)!
                    .textMembershipRightTranslation,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightTranslationDesc),
            Container(
                color: Theme.of(context).colorScheme.outline,
                height: UiHelper.getDividerWidth(context),
                width: 120),
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_history.png',
                name: AppLocalizations.of(context)!.textMembershipRightHistory,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightHistoryDesc),
            Container(
                color: Theme.of(context).colorScheme.outline,
                height: UiHelper.getDividerWidth(context),
                width: 120),
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_fav.png',
                name:
                    AppLocalizations.of(context)!.textMembershipRightFavourites,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightFavouritesDesc),
          ],
        ),
        const SizedBox(width: 20),
        PremiumRightsTable(),
        const SizedBox(width: 20),
        RightDescriptionView(
            name: AppLocalizations.of(context)!.textMembershipRightBasic,
            desc: AppLocalizations.of(context)!.textMembershipRightBasicDesc),
        RightDescriptionView(
            name: AppLocalizations.of(context)!.textMembershipRightPremium,
            desc: AppLocalizations.of(context)!.textMembershipRightPremiumDesc),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)!.titleMembershipRight,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_trans.png',
                name: AppLocalizations.of(context)!
                    .textMembershipRightTranslation,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightTranslationDesc),
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_history.png',
                name: AppLocalizations.of(context)!.textMembershipRightHistory,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightHistoryDesc),
            PremiumRightItemWithIcon(
                icon: 'assets/images/icon_membership_right_fav.png',
                name:
                    AppLocalizations.of(context)!.textMembershipRightFavourites,
                limit: -1,
                desc: AppLocalizations.of(context)!
                    .textMembershipRightFavouritesDesc),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const PremiumRightsTable(),
        const SizedBox(
          height: 20,
        ),
        RightDescriptionView(
            name: AppLocalizations.of(context)!.textMembershipRightBasic,
            desc: AppLocalizations.of(context)!.textMembershipRightBasicDesc),
        RightDescriptionView(
            name: AppLocalizations.of(context)!.textMembershipRightPremium,
            desc: AppLocalizations.of(context)!.textMembershipRightPremiumDesc),
      ],
    );
  }
}

class RightDescriptionView extends StatelessWidget {
  final String name;
  final String desc;

  const RightDescriptionView(
      {super.key, required this.name, required this.desc});
  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return Container(
      padding: isVerticalUI
          ? const EdgeInsets.symmetric(vertical: 16.0)
          : const EdgeInsets.symmetric(horizontal: 16.0),
      child: isVerticalUI
          ? _buildVerticalLayout(context)
          : _buildHorizontalLayout(context),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return MongolText.rich(
        style: TextStyle(fontFamily: 'NotoSans', fontSize: 14, height: 1.8),
        TextSpan(children: [
          TextSpan(
            text: '$name: ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          TextSpan(
              text: desc,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary))
        ]));
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return RichText(
        text: TextSpan(children: [
      TextSpan(
        text: '$name: ',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurface),
      ),
      TextSpan(
          text: desc,
          style: TextStyle(
              height: 1.4,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSecondary))
    ]));
  }
}

class PremiumRightsTable extends StatelessWidget {
  const PremiumRightsTable({super.key});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI
        ? _buildVerticalTable(context)
        : _buildHorizontalTable(context);
  }

  Widget _buildVerticalTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final rowCount = 3; // Header row + Basic row + Premium row
        final rowHeight = availableHeight > 0
            ? (availableHeight / rowCount).roundToDouble()
            : 100.0;

        return Table(
          defaultColumnWidth: const FixedColumnWidth(40),
          border: TableBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              top: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
              bottom: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
              left: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
              right: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline),
              verticalInside: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline)),
          children: [
            getVerticalRow(
              context,
              AppLocalizations.of(context)!.textMembershipRightRights,
              [
                AppLocalizations.of(context)!.textMembershipRightTranslation,
                AppLocalizations.of(context)!.textMembershipRightPhrasebook,
                AppLocalizations.of(context)!.textMembershipRightHistory,
                AppLocalizations.of(context)!.textMembershipRightFavourites,
              ],
              rowHeight: rowHeight,
              textColor: Theme.of(context).colorScheme.onSurface,
              titleRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
            ),
            getVerticalRow(
                context,
                AppLocalizations.of(context)!.textMembershipRightBasic,
                [
                  '10,000',
                  '∞',
                  '100',
                  '100',
                ],
                rowHeight: rowHeight,
                textColor: Theme.of(context).colorScheme.onSurface),
            getVerticalRow(
              context,
              AppLocalizations.of(context)!.textMembershipRightPremium,
              [
                '∞',
                '∞',
                '∞',
                '∞',
              ],
              rowHeight: rowHeight,
              textColor: Theme.of(context).colorScheme.primary,
              titleRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(6)),
            )
          ],
        );
      },
    );
  }

  Widget _buildHorizontalTable(BuildContext context) {
    return Table(
      border: TableBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          top: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline),
          bottom: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline),
          left: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline),
          right: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline),
          horizontalInside: BorderSide(
              width: UiHelper.getDividerWidth(context),
              color: Theme.of(context).colorScheme.outline)),
      children: [
        getRow(
          context,
          AppLocalizations.of(context)!.textMembershipRightRights,
          AppLocalizations.of(context)!.textMembershipRightBasic,
          AppLocalizations.of(context)!.textMembershipRightPremium,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          ),
        ),
        getRow(
            context,
            AppLocalizations.of(context)!.textMembershipRightTranslation,
            '10,000',
            '∞'),
        getRow(
            context,
            AppLocalizations.of(context)!.textMembershipRightPhrasebook,
            '∞',
            '∞'),
        getRow(
            context,
            AppLocalizations.of(context)!.textMembershipRightHistory,
            '100',
            '∞'),
        getRow(
            context,
            AppLocalizations.of(context)!.textMembershipRightFavourites,
            '100',
            '∞'),
      ],
    );
  }

  TableRow getVerticalRow(
      BuildContext context, String title, List<String> contents,
      {double rowHeight = 100.0,
      Color textColor = Colors.black,
      BorderRadius titleRadius = const BorderRadius.only()}) {
    return TableRow(
      children: [
            getVerticalCell(
              title,
              TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'NotoSans',
                  color: textColor),
              height: rowHeight,
              decoration: BoxDecoration(
                  borderRadius: titleRadius,
                  color: Theme.of(context).scaffoldBackgroundColor),
            )
          ] +
          contents
              .map(
                (content) => getVerticalCell(
                  content,
                  TextStyle(
                      fontSize: 14, fontFamily: 'NotoSans', color: textColor),
                  height: rowHeight,
                ),
              )
              .toList(),
    );
  }

  TableRow getRow(
      BuildContext context, String name, String basic, String premium,
      {BoxDecoration decoration = const BoxDecoration()}) {
    return TableRow(decoration: decoration, children: [
      getCell(
          name,
          TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface)),
      getCell(
          basic,
          TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onSecondary)),
      getCell(
          premium,
          TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary)),
    ]);
  }

  Widget getCell(String content, TextStyle style) {
    return SizedBox(
      height: 34,
      child: Align(
        alignment: Alignment.center,
        child: Text(textAlign: TextAlign.center, content, style: style),
      ),
    );
  }

  Widget getVerticalCell(String content, TextStyle style,
      {double height = 118.0,
      BoxDecoration decoration = const BoxDecoration()}) {
    return Container(
      width: 40,
      height: height,
      decoration: decoration,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Transform.translate(
        offset: Offset(2, 0),
        child: MongolText(
          content,
          style: style,
        ),
      ),
    );
  }
}

class PremiumRightItemWithIcon extends StatelessWidget {
  final String icon;
  final String name;
  final int limit;
  final String desc;
  const PremiumRightItemWithIcon(
      {super.key,
      required this.icon,
      required this.name,
      required this.limit,
      required this.desc});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI
        ? _buildVerticalLayout(context)
        : _buildHorizontalLayout(context);
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return SizedBox(
      height: 154,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(5, 255, 0, 0),
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: Center(
                  child: MongolText(
                    name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ),
            ],
          ),
          MongolText(
            limit == -1 ? '∞' : '$limit',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans',
                color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: MongolText(
                desc,
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'NotoSans',
                    color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(5, 255, 0, 0),
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          Text(
            name,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          Text(
            limit == -1 ? '∞' : '$limit',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(
            width: 80,
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItemView extends StatelessWidget {
  final String id;
  final String icon;
  final String name;
  final String price;
  final bool selected;
  final Function(String id) onClick;
  const ProductItemView(
      {super.key,
      required this.id,
      required this.icon,
      required this.name,
      required this.price,
      required this.selected,
      required this.onClick});
  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return GestureDetector(
      onTap: () {
        onClick(id);
      },
      child: Container(
        width: 120,
        height: 180,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
              width: UiHelper.getDividerWidth(context),
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline),
          color: selected
              ? const Color.fromARGB(100, 255, 242, 242)
              : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                icon,
                width: 32,
                height: 32,
              ),
              isVerticalUI
                  ? SizedBox(
                      height: 70,
                      child: MongolText(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : Text(
                      textAlign: TextAlign.center,
                      name,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
              Text(
                price,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary),
              ),
            ]),
      ),
    );
  }
}

class ProductListView extends StatefulWidget {
  final List<SubscriptionProductItem> products;
  final Function(String) onSelectProduct;
  final String selectedProductId;
  const ProductListView({
    super.key,
    required this.products,
    required this.onSelectProduct,
    required this.selectedProductId,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProductListState();
  }
}

class _ProductListState extends State<ProductListView> {
  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return widget.products.isEmpty
        ? SizedBox(
            width: 120,
            height: 180,
            child: Center(
              child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.outline,
                  )),
            ),
          )
        : isVerticalUI
            ? _buildVerticalProductList(context)
            : _buildHorizontalProductList(context);
  }

  Widget _buildVerticalProductList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: widget.products.map((product) {
        return ProductItemView(
          id: product.id,
          icon: getIcon(product.id),
          name: product.name,
          price: product.price,
          selected: product.id == widget.selectedProductId,
          onClick: widget.onSelectProduct,
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalProductList(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: widget.products.map((product) {
        return ProductItemView(
          id: product.id,
          icon: getIcon(product.id),
          name: product.name,
          price: product.price,
          selected: product.id == widget.selectedProductId,
          onClick: widget.onSelectProduct,
        );
      }).toList(),
    );
  }

  String getIcon(String id) {
    if (id == appleIdList.first ||
        id == androidIdList.first ||
        id == googleIdList.first) {
      return 'assets/images/icon_membership_month.png';
    } else if (id == appleIdList.last ||
        id == androidIdList.last ||
        id == googleIdList.last) {
      return 'assets/images/icon_membership_year.png';
    } else {
      return 'assets/images/icon_membership_season.png';
    }
  }
}

class UserBanner extends StatelessWidget {
  final UserInfo? userInfo;
  const UserBanner({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI
        ? _buildVerticalUserBanner(context)
        : _buildHorizontalUserBanner(context);
  }

  Widget _buildVerticalUserBanner(BuildContext context) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(
        userInfo != null ? userInfo!.membershipExpireDate : 0);
    var date = DateFormat('yyyy-MM-dd').format(dateTime);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.symmetric(
              vertical: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(userInfo == null
                  ? GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_no_login_dark.png'
                      : 'assets/images/avatar_no_login_light.png'
                  : GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_login_dark.png'
                      : 'assets/images/avatar_login_light.png')),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: MongolText(
                        userInfo == null
                            ? AppLocalizations.of(context)!.textLoginPlaceholder
                            : userInfo!.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 4,
                  ),
                  userInfo == null
                      ? Container()
                      : SizedBox(
                          width: 18,
                          height: 18,
                          child: Image.asset(membershipBadgeAsset(userInfo!)),
                        )
                ],
              ),
              const SizedBox(width: 4),
              userInfo == null
                  ? Container()
                  : MongolText(
                      userInfo!.isMember()
                          ? '${AppLocalizations.of(context)!.textMembershipExpirePrefix}$date${AppLocalizations.of(context)!.textMembershipExpireSuffix}'
                          : AppLocalizations.of(context)!.textNotMembership,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 14,
                          fontFamily: 'NotoSans'),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalUserBanner(BuildContext context) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(
        userInfo != null ? userInfo!.membershipExpireDate : 0);
    var date = DateFormat('yyyy-MM-dd').format(dateTime);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.symmetric(
              horizontal: BorderSide(
                  width: UiHelper.getDividerWidth(context),
                  color: Theme.of(context).colorScheme.outline))),
      child: Row(
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(userInfo == null
                  ? GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_no_login_dark.png'
                      : 'assets/images/avatar_no_login_light.png'
                  : GetIt.I<SystemSetting>().isDarkMode(context)
                      ? 'assets/images/avatar_login_dark.png'
                      : 'assets/images/avatar_login_light.png')),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                        userInfo == null
                            ? AppLocalizations.of(context)!.textLoginPlaceholder
                            : userInfo!.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(
                      width: 8,
                    ),
                    userInfo == null
                        ? Container()
                        : SizedBox(
                            width: 18,
                            height: 18,
                            child: Image.asset(membershipBadgeAsset(userInfo!)),
                          )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                userInfo == null
                    ? Container()
                    : Text(
                        userInfo!.isMember()
                            ? '${AppLocalizations.of(context)!.textMembershipExpirePrefix}$date${AppLocalizations.of(context)!.textMembershipExpireSuffix}'
                            : AppLocalizations.of(context)!.textNotMembership,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 14),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MembershipAgreementText extends StatelessWidget {
  const MembershipAgreementText({super.key});

  @override
  Widget build(BuildContext context) {
    bool isVerticalUI = UiHelper.isVerticalUI();
    return isVerticalUI
        ? MongolText.rich(
            _getTextSpan(context),
            style: TextStyle(fontFamily: 'NotoSans'),
          )
        : RichText(
            text: _getTextSpan(context),
          );
  }

  TextSpan _getTextSpan(BuildContext context) {
    return TextSpan(
        text: AppLocalizations.of(context)!.textMembershipAgreementPrefix,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary, fontSize: 14),
        children: [
          TextSpan(
              text: AppLocalizations.of(context)!.textMembershipAgreement,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  openLink(context, Constants.membershipAgreementUrl);
                },
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          TextSpan(
              text:
                  AppLocalizations.of(context)!.textMembershipAgreementSuffix),
        ]);
  }

  void openLink(BuildContext context, String url) {
    showCupertinoModalBottomSheet(
        context: context,
        enableDrag: false,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => WebView(url: url));
  }
}

class GoPremiumButton extends StatefulWidget {
  final bool loading;
  final Function() onClick;
  const GoPremiumButton(
      {super.key, required this.loading, required this.onClick});
  @override
  State<StatefulWidget> createState() {
    return GoPremiumButtonState();
  }
}

class GoPremiumButtonState extends State<GoPremiumButton> {
  @override
  Widget build(BuildContext context) {
    var forgroundColor = Colors.white;
    bool isVerticalUI = UiHelper.isVerticalUI();
    return InkWell(
      onTap: () {
        widget.onClick();
      },
      child: Container(
        height: isVerticalUI ? 160 : 48,
        width: isVerticalUI ? 48 : 160,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(24))),
        child: widget.loading
            ? Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: forgroundColor,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Center(
                child: isVerticalUI
                    ? Transform.translate(
                        offset: Offset(3, 0),
                        child: MongolText(
                          AppLocalizations.of(context)!.textButtonGoPremium,
                          style: TextStyle(
                              fontSize: 16,
                              color: forgroundColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.textButtonGoPremium,
                        style: TextStyle(
                            fontSize: 18,
                            color: forgroundColor,
                            fontWeight: FontWeight.bold),
                      ),
              ),
      ),
    );
  }
}
