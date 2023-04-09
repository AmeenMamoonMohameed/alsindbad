import 'package:akarak/app_properties.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/screens/order_list/order_list.dart';
import 'package:akarak/widgets/analytic_cards.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../../widgets/widget.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() {
    return _AccountState();
  }
}

class _AccountState extends State<Account> {
  // BannerAd? _bannerAd;
  // InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    if (Application.setting.useViewAdmob) {
      _createBannerAd();
      _createInterstitialAd();
    }
  }

  @override
  void dispose() {
    // _bannerAd?.dispose();
    // _interstitialAd?.dispose();
    super.dispose();
  }

  ///Create BannerAd
  void _createBannerAd() {
    // final banner = BannerAd(
    //   size: AdSize.fullBanner,
    //   request: const AdRequest(),
    //   adUnitId: Ads.bannerAdUnitId,
    //   listener: BannerAdListener(
    //     onAdLoaded: (ad) {
    //       setState(() {
    //         _bannerAd = ad as BannerAd?;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //     },
    //     onAdOpened: (ad) {},
    //     onAdClosed: (ad) {},
    //   ),
    // );
    // banner.load();
  }

  ///Create InterstitialAd
  void _createInterstitialAd() async {
    // await InterstitialAd.load(
    //   adUnitId: Ads.interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _interstitialAd = ad;
    //     },
    //     onAdFailedToLoad: (error) {},
    //   ),
    // );
  }

  ///Show InterstitialAd
  void _showInterstitialAd() async {
    // if (_interstitialAd != null) {
    //   _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    //     onAdShowedFullScreenContent: (ad) {},
    //     onAdDismissedFullScreenContent: (ad) {
    //       ad.dispose();
    //       _createInterstitialAd();
    //     },
    //     onAdFailedToShowFullScreenContent: (ad, error) {
    //       ad.dispose();
    //       _createInterstitialAd();
    //     },
    //   );
    //   await _interstitialAd!.show();
    //   _interstitialAd = null;
    // }
  }

  ///On logout
  void _onLogout() async {
    _showInterstitialAd();
    AppBloc.loginCubit.onLogout();
  }

  ///On deactivate
  void _onDeactivate() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('deactivate')),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Text(
                Translate.of(context).translate('would_you_like_deactivate'),
                style: Theme.of(context).textTheme.bodyText2,
              );
            },
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.pop(context, false);
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    if (result == true) {
      _confirmDeactivation();
      // AppBloc.loginCubit.onDeactivate("");
    }
  }

  ///On show message deactivate reason
  Future<String?> _confirmDeactivation() async {
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? reason;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('deactive_account'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('help_us_improve_service_quality'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 8,
                ),
                AppTextInput(
                  maxLines: 6,
                  hintText: Translate.of(context)
                      .translate('reason_for_account_deactivation'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      reason = text;
                      // _errorContent = UtilValidator.validate(
                      //   text,
                      //   allowEmpty: true
                      // );
                    });
                  },
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      // _textContentController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () {
                Navigator.pop(context, reason);
                AppBloc.loginCubit.onDeactivate(reason);
              },
            ),
          ],
        );
      },
    );
  }

  ///On navigation
  void _onNavigate(String route) {
    Navigator.pushNamed(context, route);
  }

  ///On Preview Profile
  void _onProfile(UserModel user) {
    Navigator.pushNamed(context, Routes.profile, arguments: user.userId);
  }

  ///Build Banner Ads
  Widget buildBanner() {
    // if (_bannerAd != null) {
    //   return SizedBox(
    //     width: _bannerAd!.size.width.toDouble(),
    //     height: _bannerAd!.size.height.toDouble(),
    //     child: AdWidget(ad: _bannerAd!),
    //   );
    // }
    return Container();
  }

  List getDataCardsMembership() {
    List analyticData = [
      AnalyticInfo(
        iconType: AnalyticInfoIconType.body,
        routeName: Routes.views,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Translate.of(context).translate('رقم العضوية'),
                    style: Theme.of(context).textTheme.caption
                    //  const TextStyle(
                    //   color: textColor,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.w800,
                    // ),
                    ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppBloc.userCubit.state!.membershipNo.toString(),
                    style: Theme.of(context).textTheme.headline6
                    //  const TextStyle(
                    //   color: textColor,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.w800,
                    // ),
                    ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary),
                      fixedSize: MaterialStateProperty.all<Size>(Size(
                          MediaQuery.of(context).size.width < 650
                              ? (MediaQuery.of(context).size.width / 2) -
                                  (MediaQuery.of(context).size.width * 0.13)
                              : (MediaQuery.of(context).size.width / 4) -
                                  (MediaQuery.of(context).size.width * 0.13),
                          double.infinity))),
                  onPressed: () {
                    _onNavigate(Routes.accountDetails);
                  },
                  child: Text(Translate.of(context).translate('تفاصيل الحساب')),
                ),

                // Icon(
                //   color: Colors.blueAccent[400],
                //   AppLanguage.isRTL()
                //       ? Icons.arrow_forward_rounded
                //       : Icons.arrow_back_rounded,
                // )
              ],
            ),
          ],
        ),
      ),
      AnalyticInfo(
        iconType: AnalyticInfoIconType.body,
        routeName: Routes.views,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Translate.of(context).translate('نوع العضوية'),
                    style: Theme.of(context).textTheme.caption
                    //  const TextStyle(
                    //   color: textColor,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.w800,
                    // ),
                    ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Translate.of(context).translate('مجاني'),
                    style: Theme.of(context).textTheme.headline6
                    //  const TextStyle(
                    //   color: textColor,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.w800,
                    // ),
                    ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1,
                          style: BorderStyle.solid)),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      fixedSize: MaterialStateProperty.all<Size>(Size(
                          MediaQuery.of(context).size.width < 650
                              ? (MediaQuery.of(context).size.width / 2) -
                                  (MediaQuery.of(context).size.width * 0.13)
                              : (MediaQuery.of(context).size.width / 4) -
                                  (MediaQuery.of(context).size.width * 0.13),
                          double.infinity))),
                  onPressed: () {},
                  child: Text(Translate.of(context).translate('افتح متجر')),
                ),

                // Icon(
                //   color: Colors.blueAccent[400],
                //   AppLanguage.isRTL()
                //       ? Icons.arrow_forward_rounded
                //       : Icons.arrow_back_rounded,
                // )
              ],
            ),
          ],
        ),
      ),
    ];
    return analyticData;
  }

  List getAnalyticData() {
    List analyticData = [
      AnalyticInfo(
        iconType: AnalyticInfoIconType.svg,
        title: "المشاهدات",
        count: AppBloc.userCubit.state!.views.toDouble(),
        src: "assets/icons/View.png",
        color: orange,
        routeName: Routes.views,
      ),
      AnalyticInfo(
        iconType: AnalyticInfoIconType.svg,
        title: "التقييم",
        count: AppBloc.userCubit.state!.ratingAvg,
        src: AppBloc.userCubit.state!.ratingAvg.toInt() == 0
            ? "assets/icons/Rating0.png"
            : AppBloc.userCubit.state!.ratingAvg.toInt() == 1
                ? "assets/icons/Rating1.png"
                : AppBloc.userCubit.state!.ratingAvg.toInt() == 2
                    ? "assets/icons/Rating2.png"
                    : AppBloc.userCubit.state!.ratingAvg.toInt() == 3
                        ? "assets/icons/Rating3.png"
                        : AppBloc.userCubit.state!.ratingAvg.toInt() == 4
                            ? "assets/icons/Rating4.png"
                            : "assets/icons/Rating5.png",
        routeName: Routes.review,
        color: green,
      ),
      AnalyticInfo(
        iconType: AnalyticInfoIconType.svg,
        title: "سلة التسوق",
        count: AppBloc.userCubit.state!.shoppingCarts.toDouble(),
        src: Images.shoppingCart,
        color: Colors.yellow,
        routeName: Routes.shoppingCart,
      ),
      AnalyticInfo(
          iconType: AnalyticInfoIconType.svg,
          title: "الطلبات",
          count: AppBloc.userCubit.state!.orders.toDouble(),
          src: Images.commercialInvoices,
          color: orange,
          routeName: Routes.orderList),
      AnalyticInfo(
          iconType: AnalyticInfoIconType.svg,
          title: "طلبات العملاء",
          count: AppBloc.userCubit.state!.customerOrders.toDouble(),
          src: Images.orders,
          color: grey,
          routeName: Routes.customerOrderList),
      AnalyticInfo(
          iconType: AnalyticInfoIconType.svg,
          title: "العناوين",
          count: AppBloc.userCubit.state!.addresses.toDouble(),
          src: Images.address,
          color: grey,
          routeName: Routes.addressList),
    ];
    return analyticData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Application.scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: false,
        title: Text(
          Translate.of(context).translate('account'),
        ),
        actions: [
          AppButton(
            Translate.of(context).translate('sign_out'),
            mainAxisSize: MainAxisSize.max,
            onPressed: _onLogout,
            type: ButtonType.text,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: BlocBuilder<UserCubit, UserModel?>(
            builder: (context, user) {
              if (user == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          top:
                              BorderSide(width: 1, color: Colors.grey.shade400),
                          left:
                              BorderSide(width: 1, color: Colors.grey.shade400),
                          right:
                              BorderSide(width: 1, color: Colors.grey.shade400),
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade400),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      child: AppUserInfo(
                        user: user,
                        type: UserViewType.information,
                        onPressed: () {
                          _onProfile(user);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnalyticCards(
                      childAspectRatioMobile:
                          MediaQuery.of(context).size.width < 650 ? 1.5 : 1.3,
                      childAspectRatioTablet:
                          MediaQuery.of(context).size.width < 650 ? 1.5 : 1.3,
                      analyticData: getDataCardsMembership(),
                    ),

                    const SizedBox(height: 16),
                    BlocBuilder<RealTimeCubit, RealTimeState>(
                        builder: (context, state) {
                          if (state is NotifyNewView) {
                            AppBloc.userCubit.state?.views += 1;
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          if (state is NotifyNewShoppingCart) {
                            AppBloc.userCubit.state?.shoppingCarts += 1;
                            AppBloc.userCubit.onFetchUser();
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          if (state is NotifyNewOrder) {
                            AppBloc.userCubit.state?.orders += 1;
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          if (state is NotifyCustomerOrder) {
                            AppBloc.userCubit.state?.customerOrders += 1;
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          if (state is NotifyNewAddress) {
                            AppBloc.userCubit.state?.addresses += 1;
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          if (state is NotifyNewReview) {
                            AppBloc.userCubit.state?.ratingAvg = state.rating;
                            AppBloc.userCubit.onFetchUser();
                            return AnalyticCards(
                              analyticData: getAnalyticData(),
                            );
                          }
                          return AnalyticCards(
                            analyticData: getAnalyticData(),
                          );
                        },
                        bloc: AppBloc.realTimeCubit),
                    const SizedBox(height: 16),
                    // Column(children: <Widget>[
                    // ListTile(
                    //   title: const Text('Settings'),
                    //   subtitle: const Text('Privacy and logout'),
                    //   leading: Image.asset(
                    //     Images.facebook,
                    //     fit: BoxFit.scaleDown,
                    //     width: 30,
                    //     height: 30,
                    //   ),
                    //   trailing:
                    //       const Icon(Icons.chevron_right, color: yellow),
                    //   onTap: () => Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (_) => const OrderList())),
                    // ),
                    // const Divider(),
                    // ListTile(
                    //   title: const Text('Help & Support'),
                    //   subtitle: const Text('Help center and legal support'),
                    //   leading: Image.asset(Images.facebook),
                    //   trailing: const Icon(
                    //     Icons.chevron_right,
                    //     color: yellow,
                    //   ),
                    // ),
                    // ]),
                    const SizedBox(height: 16),
                    Column(
                      children: <Widget>[
                        if (!AppBloc.userCubit.state!.phoneNumberConfirmed)
                          AppListTitle(
                            title: Translate.of(context).translate(
                              'confirm_phone_number',
                            ),
                            trailing: RotatedBox(
                              quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                              child: Icon(
                                AppLanguage.isRTL()
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_left,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.otp,
                                arguments: {
                                  "userId": AppBloc.userCubit.state!.userId,
                                  "routeName": null
                                },
                              );
                            },
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        AppListTitle(
                          title: Translate.of(context).translate(
                            'edit_profile',
                          ),
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          onPressed: () {
                            _onNavigate(Routes.editProfile);
                          },
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate(
                            'change_password',
                          ),
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          onPressed: () {
                            _onNavigate(Routes.changePassword);
                          },
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate(
                            'my_purchases',
                          ),
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          onPressed: () {
                            _onNavigate(Routes.orderList);
                          },
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate('setting'),
                          onPressed: () {
                            _onNavigate(Routes.setting);
                          },
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate(
                            'contact_us',
                          ),
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          onPressed: () {
                            _onNavigate(Routes.contactUs);
                          },
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate(
                            'about_us',
                          ),
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          onPressed: () {
                            _onNavigate(Routes.aboutUs);
                          },
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate('deactivate'),
                          onPressed: _onDeactivate,
                          trailing: RotatedBox(
                            quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          border: false,
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    buildBanner(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
