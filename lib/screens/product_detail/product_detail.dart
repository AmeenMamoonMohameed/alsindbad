import 'dart:async';
import 'dart:io';

import 'package:akarak/utils/translate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:share/share.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../notificationservice_.dart';
import '../../packages/chat/models/attachment_message.dart';
import '../../repository/chat_repository.dart';
import '../../widgets/card_header_widget.dart';
import '../../widgets/widget.dart';
import '../screen.dart';
import 'product_detail_tab.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key, required this.id, required this.categoryId})
      : super(key: key);

  final int id;
  final int categoryId;

  @override
  _ProductDetailState createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _productDetailCubit = ProductDetailCubit();
  late StreamSubscription _reviewSubscription;

  Color? _iconColor = Colors.white;
  bool _hasMap = false;
  bool _showHour = true;
  bool _showFile = true;
  bool _showSocial = true;
  List<String?> selectedColors = [];

  TabController? _tabController;
  int _indexTab = 0;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _productDetailCubit.onLoad(widget.id);
    _hasMap = Application.submitSetting.categories
        .singleWhere((element) => element.id == widget.categoryId)
        .hasMap;
    _tabController = TabController(
      length: _hasMap ? 3 : 2,
      vsync: this,
    );
    _tabController!.addListener(_onTap);
    // _productDetailCubit.onLoad(widget.id);
    // _scrollController.addListener(_onScroll);
    // _tabController = TabController(
    //   length: 3,
    //   vsync: this,
    // );
    // _tabController!.addListener(_onTap);
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewByIdSuccess &&
          state.productId != null &&
          state.productId == widget.id) {
        _productDetailCubit.onLoad(widget.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _reviewSubscription.cancel();
    _productDetailCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  ///Handle icon theme
  void _onScroll() {
    Color? color;
    if (_scrollController.position.extentBefore < 110) {
      color = Colors.white;
    }
    if (color != _iconColor) {
      setState(() {
        _iconColor = color;
      });
    }
  }

  ///On Change Tab
  void _onTap() {
    setState(() {
      _indexTab = _tabController!.index;
    });
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    if (item.category?.hasMap ?? false) {
      Navigator.pushNamed(
        context,
        Routes.productDetail,
        arguments: {"id": item.id, "categoryId": item.category?.id},
      );
    } else {
      Navigator.pushNamed(
        context,
        Routes.productScreen,
        arguments: {"id": item.id, "categoryId": item.category?.id},
      );
    }
  }

  ///On Preview Profile
  void _onProfile(UserModel user) {
    Navigator.pushNamed(context, Routes.profile, arguments: user.userId);
  }

  ///On navigate map
  void _onLocation(ProductModel item) {
    Navigator.pushNamed(
      context,
      Routes.location,
      arguments: item.coordinate,
    );
  }

  ///On Share
  Future<void> _onShare(ProductModel item) async {
    Share.share(
      await UtilOther.createDynamicLink(
          "${Application.dynamicLink}/product/${item.category!.id}/${item.id}",
          false),
      // 'Check out my item ${item.link}',
      subject: 'ArmaSoft',
    );
  }

  ///On navigate gallery
  void _onPhotoPreview(ProductModel item) {
    Navigator.pushNamed(
      context,
      Routes.gallery,
      arguments: item,
    );
  }

  ///On navigate review
  void _onReview(ProductModel product) async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }

    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Routes.productReview,
      arguments: product,
    );
  }

  ///On report product
  void _onReport(BuildContext context_) async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }
    String? errorTitle;
    String? errorDescription;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? title;
        String? description;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('report'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('specify_the_main_reason_for_reporting'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 2,
                  errorText: errorTitle,
                  hintText: errorTitle ??
                      Translate.of(context).translate('report_title'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      title = text;
                      errorTitle =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 10,
                  errorText: errorDescription,
                  hintText: errorDescription ??
                      Translate.of(context).translate('report_description'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      description = text;
                      errorDescription =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
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
              onPressed: () async {
                errorTitle =
                    UtilValidator.validate(title ?? "", allowEmpty: false);
                errorDescription = UtilValidator.validate(description ?? "",
                    allowEmpty: false);
                setState(() {});
                if (errorTitle == null && errorDescription == null) {
                  Navigator.pop(context, description);
                  final result = await ChatRepository.sendReport(ReportModel(
                      reportedId: widget.id.toString(),
                      name: title!,
                      description: description!,
                      type: ReportType.product));
                  if (result != null) {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate('the_message_has_been_sent'));
                  } else {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate(
                            'an_error_occurred,_the_message_was_not_sent'));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  ///On like product
  void _onFavorite() async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    _productDetailCubit.onFavorite();
  }

  ///On Add Cart
  void _onAddCart() async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }

    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    _productDetailCubit.onAddDeleteCart();
  }

  ///On Order
  void _onOrder() async {
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Routes.order,
      arguments: widget.id,
    );
  }

  ///Phone action
  void _phoneAction() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: AppListTitle(
                            title: 'call',
                            leading: SizedBox(
                              height: 24,
                              width: 24,
                              child: Image.asset(Images.phone),
                            ),
                            onPressed: () {
                              _makeAction(
                                  'tel:${_productDetailCubit.product!.extendedAttributes.singleWhere((e) => e.key == "phone").text}');
                            },
                          ),
                        ),
                        AppListTitle(
                          title: 'Whatsapp',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.whatsapp),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "Whatsapp");
                          },
                        ),
                        AppListTitle(
                          title: 'Viber',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.viber),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "Viber");
                          },
                        ),
                        AppListTitle(
                          title: 'Telegram',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.telegram),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "Telegram");
                          },
                          border: false,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      String url = '';

      switch (result) {
        case "Whatsapp":
          if (Platform.isAndroid) {
            url =
                "whatsapp://wa.me/${_productDetailCubit.product!.createdBy!.phoneNumber}";
          } else {
            url =
                "whatsapp://api.whatsapp.com/send?phone=${_productDetailCubit.product!.createdBy!.phoneNumber}";
          }
          break;
        case "Viber":
          url =
              "viber://contact?number=${_productDetailCubit.product!.createdBy!.phoneNumber}";
          break;
        case "Telegram":
          url =
              "tg://msg?to=${_productDetailCubit.product!.createdBy!.phoneNumber}";
          break;
        default:
          break;
      }

      _makeAction(url);
    }
  }

  ///Make action
  void _makeAction(String url) async {
    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('explore_product'),
        message: Translate.of(context).translate('cannot_make_action'),
      );
    }
  }

  ///Build social image
  String _exportSocial(String type) {
    switch (type) {
      case "telegram":
        return Images.telegram;
      case "twitter":
        return Images.twitter;
      case "flickr":
        return Images.flickr;
      case "google_plus":
        return Images.google;
      case "tumblr":
        return Images.tumblr;
      case "linkedin":
        return Images.linkedin;
      case "pinterest":
        return Images.pinterest;
      case "youtube":
        return Images.youtube;
      case "instagram":
        return Images.instagram;

      default:
        return Images.facebook;
    }
  }

  ///Build Colors Options
  Widget _buildColorOptions(ProductModel? product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.tertiary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
              alignment: WrapAlignment.center,
              children: product!.extendedAttributes
                  .where((item) => item.key == 'color')
                  .map((item) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () {
                      if (selectedColors.contains(item.text)) {
                        selectedColors.remove(item.text);
                      } else {
                        selectedColors.add(item.text);
                      }
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: selectedColors.contains(item.text)
                            ? Border.all(
                                color: Theme.of(context).primaryColor, width: 2)
                            : null,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7)),
                      ),
                      child: ColorOption(
                        Color(int.parse('0x${item.text}')),
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                );
              }).toList()),
        ),
      ),
    );
  }

  ///Build Size Options
  Widget _buildSizeOptions(ProductModel? product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.tertiary,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: 15,
              right: AppLanguage.isRTL() ? 5 : 0,
              left: AppLanguage.isRTL() ? 0 : 5),
          child: Wrap(
              alignment: WrapAlignment.center,
              children: product!.extendedAttributes
                  .where((item) => item.key == 'size')
                  .map((item) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () {
                      if (selectedColors.contains(item.text)) {
                        selectedColors.remove(item.text);
                      } else {
                        selectedColors.add(item.text);
                      }
                      setState(() {});
                    },
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              border: selectedColors.contains(item.text)
                                  ? Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2)
                                  : null,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(item.text!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(color: Colors.white)),
                            ),
                          ),
                        ),
                        if (product.priceType == PriceType.bySize &&
                            item.double_ != null)
                          Positioned(
                            right: 4,
                            left: 4,
                            bottom: -4,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                    '${item.double_} ${product.currency?.code}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(color: Colors.white)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList()),
        ),
      ),
    );
  }

  ///Build content UI
  Widget _buildContent(ProductModel? product) {
    ///Build UI loading
    Widget describtion = Container();
    Widget phone = Container();
    Widget email = Container();
    Widget website = Container();
    Widget openHours = Container();
    Widget attachments = Container();
    Widget socials = Container();
    Widget info = AppPlaceholder(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 16,
              width: 150,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 16,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 20,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
          ],
        ),
      ),
    );

    Widget mainData = AppPlaceholder(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 16,
              width: 150,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 16,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 20,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
          ],
        ),
      ),
    );

    Widget status = Container();
    Widget tags = Container();
    Widget latest = Container();
    List<Widget> properties = [];
    Widget feature = AppPlaceholder(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(height: 10, color: Colors.white),
          ],
        ),
      ),
    );
    Widget related = Container();
    Widget dateEstablish = Container();
    Widget price = Container();
    Widget priceLocal = Container();
    Widget order = Container();
    Widget? videoUrl;

    ///Loading List Product
    Widget content = SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AppPlaceholder(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: 15,
      ),
    );

    final List<Widget> rateWidget = <Widget>[
      AppTag(
        product == null ? "0.0" : "${product.rate}",
        type: TagType.rate,
      ),
      const SizedBox(width: 4),
      RatingBar.builder(
        initialRating: product == null ? 0.0 : product.rate,
        minRating: 1,
        allowHalfRating: true,
        unratedColor: Colors.amber.withAlpha(100),
        itemCount: 5,
        itemSize: 14.0,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rate) {},
        ignoreGestures: true,
      ),
      const SizedBox(width: 4),
    ];

    if (product != null && product.activeReviews == ActiveReviewType.open) {
      rateWidget.add(Text(
        "(${product.numRate})",
        style: Theme.of(context).textTheme.bodyText1,
      ));
      rateWidget.add(const SizedBox(width: 4));
    }

    /// Build Detail
    if (product != null) {
      ///Status
      if (product.statusText.isNotEmpty) {
        status = AppTag(
          product.statusText,
          type: TagType.status,
        );
      }

      ///Latest
      if (product.latest.isNotEmpty) {
        latest = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Translate.of(context).translate('latest'),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final ProductModel item = product.latest[index];
                  return Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AppProductItem(
                      onPressed: () {
                        _onProductDetail(item);
                      },
                      item: item,
                      type: ProductViewType.grid,
                    ),
                  );
                },
                itemCount: product.latest.length,
              ),
            )
          ],
        );
      }

      ///Related list
      if (product.related.isNotEmpty) {
        related = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate('related'),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = product.related[index];
                  return AppProductItem(
                    onPressed: () {
                      _onProductDetail(item);
                    },
                    item: item,
                    type: ProductViewType.small,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
                itemCount: product.related.length,
              ),
            ],
          ),
        );
      }

      ///Feature
      if (product.features.isNotEmpty) {
        feature = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // const Divider(),
            // const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('featured'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.features.map((item) {
                return IntrinsicWidth(
                  child: AppTag(
                    item.name,
                    type: TagType.chip,
                    icon: Icon(
                      item.icon,
                      size: 10,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      } else {
        feature = Container();
      }

      ///Tags
      if (product.tags.isNotEmpty) {
        tags = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('tags'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.tags.map((item) {
                return IntrinsicWidth(
                  child: AppTag(
                    item,
                    type: TagType.chip,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      ///socials
      if (product.extendedAttributes.any((item) => item.group == "social")) {
        attachments = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  _showSocial = !_showSocial;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.link,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translate.of(context).translate('social_network'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showSocial
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showSocial,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.extendedAttributes
                      .where((item) => item.group == "social")
                      .map((item) {
                    return InkWell(
                      onTap: () {
                        _makeAction(item.text ?? "");
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              _exportSocial(item.key),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }

      ///Phone
      if (product.extendedAttributes
          .any((e) => e.key == "phone" && e.text != null && e.text != "")) {
        phone = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                _makeAction(
                    'tel:${product.extendedAttributes.singleWhere((e) => e.key == "phone").text}');
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.phone_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      ///Email
      if (product.extendedAttributes
          .any((e) => e.key == "email" && e.text != null && e.text != "")) {
        email = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                _makeAction(
                    'mailto:${product.extendedAttributes.singleWhere((e) => e.key == "email").text}');
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('email'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          product.extendedAttributes
                              .singleWhere((e) => e.key == "email")
                              .text!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Website
      if (product.extendedAttributes
          .any((e) => e.key == "website" && e.text != null && e.text != "")) {
        website = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                _makeAction(product.extendedAttributes
                    .singleWhere((e) => e.key == "website")
                    .text!);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.language_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('website'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          product.extendedAttributes
                              .singleWhere((e) => e.key == "website")
                              .text!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Open hours
      if (product.openHours.isNotEmpty) {
        openHours = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  _showHour = !_showHour;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.access_time_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translate.of(context).translate('open_time'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showHour
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showHour,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: product.openHours.map((item) {
                  final hour = item.schedule
                      .map((e) {
                        return '${e.start.viewTime}-${e.end.viewTime}';
                      })
                      .toList()
                      .join(",");
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    margin: const EdgeInsets.only(left: 42),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate(item.key),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hour,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }

      ///File attachments
      if (product.attachments.isNotEmpty) {
        socials = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  _showFile = !_showFile;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.file_copy_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Translate.of(context).translate('attachments'),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              '${product.attachments.length} ${Translate.of(context).translate('files')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showFile
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showFile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: product.attachments.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(left: 42),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${item.name}.${item.type}',
                            style: Theme.of(context).textTheme.caption,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              item.size,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            AppDownloadFile(file: item),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }

      ///Date established
      if (product.date.isNotEmpty) {
        dateEstablish = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Translate.of(context).translate(
                      'date_established',
                    ),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ]),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    product.date,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.bold),
                  )
                ]),
          ],
        );
      }

      ///Price Local
      if (product.price.isNotEmpty && !product.currency!.isDefault) {
        priceLocal = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${Translate.of(context).translate('price')} (${Application.submitSetting.currencies.singleWhere((cur) => cur.isDefault).code})",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ]),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    (double.parse(product.price) *
                            Application.submitSetting.currencies
                                .singleWhere(
                                    (cur) => cur.id == product.currency?.id)
                                .exchange)
                        .toString(),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ]),
          ],
        );
      }

      ///Price
      if (product.price.isNotEmpty) {
        price = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${Translate.of(context).translate('price')} (${Application.submitSetting.currencies.singleWhere((cur) => cur.id == product.currency?.id).code})",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ]),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    product.price,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ]),
          ],
        );
      }

      ///Order button
      if (product.category?.hasOrder == true && product.orderUse) {
        order = InkWell(
          onTap: _onOrder,
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            child: Text(
              Translate.of(context).translate('book_now'),
              style: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
          ),
        );
      }

      if (product.extendedAttributes
          .any((item) => item.key == "youtubeVideo")) {
        videoUrl = AppVideo(
            isYouTube: true,
            url: product.extendedAttributes
                .singleWhere((item) => item.key == "youtubeVideo")
                .text!);
      }

      int g = 0, p = 0;

      ///Properties
      product.category?.groups?.forEach((group) {
        if (g > 0) {
          properties.add(
            Container(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(group.name, textAlign: TextAlign.center))
                ],
              ),
            ),
          );
          properties.add(
            const Divider(height: 0),
          );
          properties.add(
            const SizedBox(
              height: 10,
            ),
          );
        }

        g++;
        p = 0;
        int propCount = group.properties
                ?.where(
                    (property) => property.propertyType == PropertyType.entity)
                .where((e) => e.section == product.section)
                .length ??
            0;
        group.properties
            ?.where((property) => property.propertyType == PropertyType.entity)
            .where((e) => e.section == product.section)
            .forEach((property) {
          p++;
          properties.add(
            Padding(
                padding: const EdgeInsets.only(right: 5, left: 3),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.36,
                          color: Colors.white,
                          child: Text(
                            // " csas",
                            property.name,
                            maxLines: 3,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                    Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[]),
                    // Divider(height: 20, color: Theme.of(context).primaryColor),
                    if (product.extendedAttributes.isNotEmpty &&
                        product.extendedAttributes
                            .any((item) => item.key == property.key))
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.36,
                            color: Colors.white,
                            child: Text(
                              product.extendedAttributes
                                  .where((item) => item.key == property.key)
                                  .first
                                  .getValue()
                                  .toString(),
                              textAlign: TextAlign.end,
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                  ],
                )),
          );
          if (p != propCount && propCount > 0) {
            properties.add(const Divider());
          }
        });
        if (g != product.category?.groups?.length) {
          properties.add(
            const SizedBox(
              height: 10,
            ),
          );
          properties.add(
            const Divider(height: 0),
          );
        }
      });

      ///Main Data
      mainData = Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Translate.of(context).translate('rating'),
                  style: Theme.of(context).textTheme.caption,
                ),
                InkWell(
                  onTap: () {
                    _onReview(product);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: rateWidget,
                  ),
                ),
              ],
            ),
            const Divider(),
            price,
            if (product.currency?.isDefault == false) ...[
              const Divider(),
              priceLocal,
            ],
            const Divider(),
            dateEstablish,
            const Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: properties,
            ),
            if (product.features.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              feature,
            ],
            if (product.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              tags,
            ],
            const SizedBox(height: 16),
            const Divider(height: 0),

            // const Divider(height: 0),
            // AppUserInfo(
            //   user: product.createdBy,
            //   type: UserViewType.informationAdv,
            //   onPressed: () {
            //     _onProfile(product.createdBy!);
            //   },
            // ),
            // const SizedBox(height: 24),
            // socials,
          ],
        ),
      );
    }

    ///Loading List Review
    if (_indexTab == 1) {
      if (product != null) {
        describtion = Text(
          product.content,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.3,
              ),
        );
        content = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  describtion,
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  if (videoUrl != null) ...[
                    Container(
                        child: Text(
                      Translate.of(context).translate('video'),
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    const SizedBox(height: 8),
                    videoUrl,
                  ],
                  InkWell(
                    onTap: () {},
                    child: Material(
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Translate.of(context).translate('compare'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.compare_arrows_outlined,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  // const Divider(height: 0),
                  InkWell(
                    onTap: () {
                      _onReport(context);
                    },
                    child: Material(
                      color: Theme.of(context).colorScheme.onTertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Translate.of(context).translate('report'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.flag_outlined,
                              color: Theme.of(context).errorColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  AppUserInfo(
                    user: product.createdBy,
                    type: UserViewType.informationAdv,
                    onPressed: () {
                      _onProfile(product.createdBy!);
                    },
                  ),
                  const SizedBox(height: 24),
                  socials,
                ],
              );
            },
            childCount: 1,
          ),
        );
      } else {
        content = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return AppPlaceholder(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 1.1,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 1.1,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 1.1,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 1.3,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width / 1.7,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 150,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              );
            },
            childCount: 15,
          ),
        );
      }
    }

    ///Loading List Review
    if (_indexTab == 2) {
      if (product != null) {
        content = SliverToBoxAdapter(
            child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 200),
          child: Location(
            location: product.coordinate!,
            isTab: true,
          ),
        ));
      } else {
        content = Container();
      }
    }

    ///Build List Product
    if (_indexTab == 0) {
      ///Address
      if (product != null) {
        if (product.extendedAttributes.isNotEmpty) {
          content = SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(children: [
                  mainData,
                  if (product.extendedAttributes
                      .any((item) => item.key == 'color'))
                    _buildColorOptions(product),
                  if (product.extendedAttributes
                      .any((item) => item.key == 'size'))
                    _buildSizeOptions(product),
                  InkWell(
                    onTap: () {},
                    child: Material(
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Translate.of(context).translate('compare'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.compare_arrows_outlined,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  // const Divider(height: 0),
                  InkWell(
                    onTap: () {
                      _onReport(context);
                    },
                    child: Material(
                      color: Theme.of(context).colorScheme.onTertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Translate.of(context).translate('report'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.flag_outlined,
                              color: Theme.of(context).errorColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  AppUserInfo(
                    user: product.createdBy,
                    type: UserViewType.informationAdv,
                    onPressed: () {
                      _onProfile(product.createdBy!);
                    },
                  ),
                  const SizedBox(height: 24),
                  socials,
                ]);
              },
              childCount: 1,
            ),
          );
        } else {
          content = SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container();
              },
              childCount: 1,
            ),
          );
        }
      }
    }

    return content;
  }

  Widget buildLocation() {
    if (_productDetailCubit.product == null) {
      return AppPlaceholder(
          child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            color: Colors.white,
          ),
          const Text(">"),
          Container(
            width: 10,
            height: 10,
            color: Colors.white,
          ),
          const Text(">"),
          Container(
            width: 10,
            height: 10,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              _makeAction(
                'https://www.google.com/maps/search/?api=1&query=${_productDetailCubit.product!.coordinate!.latitude},${_productDetailCubit.product!.coordinate!.longitude}',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  child: Text(
                    // _productDetailCubit.product!.extendedAttributes
                    //         .singleWhere((e) => e.key == "address")
                    //         .text ??
                    "",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ));
    }
    bool islooping = _productDetailCubit.product!.category!.parentId != null;
    List<Widget> list = [];
    list.add(
      InkWell(
        onTap: () {},
        child: Text(
          _productDetailCubit.product!.category!.name,
          style: Theme.of(context).textTheme.caption!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
    list.add(Text(
      "  <  ",
      style: Theme.of(context).textTheme.caption!.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
    ));
    while (islooping) {
      if (Application.submitSetting.categories.any((item) =>
          item.id == _productDetailCubit.product!.category!.parentId)) {
        list.add(
          InkWell(
            onTap: () {},
            child: Text(
              Application.submitSetting.categories
                  .singleWhere((item) =>
                      item.id ==
                      _productDetailCubit.product!.category!.parentId)
                  .name,
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );

        if (Application.submitSetting.categories
            .any((item) => item.parentId == null)) {
          islooping = false;
        } else {
          list.add(Text("  <  ",
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  )));
        }
      }
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              _productDetailCubit.product!.createdBy?.accountName ?? "",
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          // const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: list,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // _makeAction(
              //   'https://www.google.com/maps/search/?api=1&query=${_productDetailCubit.product!.coordinate!.latitude},${_productDetailCubit.product!.coordinate!.longitude}',
              // );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  child: Text(
                    "${_productDetailCubit.product!.city!.name}, ${_productDetailCubit.product!.state!.name} , ${_hasMap ? (_productDetailCubit.product!.extendedAttributes.singleWhere((e) => e.key == "address").text ?? "") : ""}",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ]);
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "productDetailScreen");

  @override
  Widget build(BuildContext context) {
    Widget actionGalleries = Container();
    Widget actionMapView = Container();
    Widget actionFavorite = Container();
    Widget actionAddCart = Container();
    Widget actionShare = Container();
    Widget background = AppPlaceholder(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
      ),
    );
    Color? backgroundAction;
    backgroundAction = Colors.grey.withOpacity(0.3);
//     if (_iconColor == Colors.white) {
//       backgroundAction = Colors.grey.withOpacity(0.3);
//     }

    return BlocProvider(
        create: (context) => _productDetailCubit,
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
            builder: (context, state) {
          if (state is ProductDetailSuccess) {
            ///Action Map View
            if (state.product.coordinate != null) {
              actionMapView = Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundAction,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () {
                        _onLocation(state.product);
                      },
                    ),
                  ),
                ],
              );
            }

            ///Action Galleries
            if (state.product.gallery.isNotEmpty) {
              actionGalleries = Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _onPhotoPreview(state.product);
                      },
                    ),
                  ),
                ],
              );
            }

            ///Action Favorite
            if (AppBloc.userCubit.state != null) {
              actionFavorite = Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      state.product.favorite ? Icons.star : Icons.star_border,
                      color: state.product.favorite
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    onPressed: _onFavorite,
                  ),
                ],
              );
            }

            ///Action AddCart
            if (AppBloc.userCubit.state != null) {
              actionAddCart = Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      state.product.isAddedCart
                          ? Icons.remove_shopping_cart
                          : Icons.add_shopping_cart_sharp,
                      color: state.product.isAddedCart
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    onPressed: _onAddCart,
                  ),
                ],
              );
            }

            ///Action Share
            actionShare = Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    _onShare(state.product);
                  },
                ),
              ],
            );

            background = CachedNetworkImage(
              imageUrl: state.product.image.replaceAll("TYPE", "full"),
              placeholder: (context, url) {
                return AppPlaceholder(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                // return Padding(
                //   padding: const EdgeInsets.only(bottom: 50),
                //   child: Container(
                //     constraints: BoxConstraints(
                //         maxHeight: MediaQuery.of(context).size.height * 0.6),
                //     child: Image(
                //         width: MediaQuery.of(context).size.width,
                //         image: imageProvider,
                //         excludeFromSemantics: true,
                //         fit: BoxFit.fill,
                //         centerSlice: Rect.largest),
                //   ),
                // );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.6),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                        centerSlice: Rect.largest,
                      ),
                    ),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return AppPlaceholder(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.error),
                  ),
                );
              },
            );

            ///Video
            // if (state.product.videoURL.isNotEmpty) {
            //   background =
            //       AppVideo(isYouTube: true, url: state.product.videoURL);
            // }

          }
          return Scaffold(
            appBar: AppBar(
                title: Text(Translate.of(context).translate('details')),
                actions: [
                  actionFavorite,
                  actionShare,
                  actionAddCart,
                ]),
            body: CustomScrollView(
              clipBehavior: Clip.none,
              // scrollDirection: Axis.vertical,
              shrinkWrap: true,
              controller: _scrollController,
              physics: const ClampingScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: <Widget>[
                MultiSliver(children: [
                  // Card For Title
                  SliverPinnedHeader(
                    child: Card(
                      surfaceTintColor: Colors.black,
                      semanticContainer: false,
                      margin: const EdgeInsets.all(0),
                      shadowColor: Theme.of(context).shadowColor,
                      color: Theme.of(context).colorScheme.onTertiary,
                      child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            _productDetailCubit.product?.name ?? "",
                            textAlign: TextAlign.center,
                          )),
                      // CardHeaderWidget(
                      //     title: _productDetailCubit.product?.title ?? ""),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        background,
                        StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          // crossAxisSpacing: 4,
                          children: [
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: Container(
                                child: Center(
                                  child: actionGalleries,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 10,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                  if (_hasMap)
                                    Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: buildLocation(),
                                      ),
                                    ),
                                ],
                              ),
                              if (_productDetailCubit.product != null)
                                Positioned(
                                  top: 2,
                                  right: AppLanguage.isRTL() ? 20 : null,
                                  left: AppLanguage.isRTL() ? null : 20,
                                  child: Image.asset(Images.authenticated),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
//                   SliverStack(
//                       // positionedAlignment: AppLanguage.isRTL()
//                       //     ? Alignment.bottomRight
//                       //     : Alignment.bottomLeft,
//                       children: [

//                         SliverAppBar(
//                           excludeHeaderSemantics: true,
//                           backgroundColor: Theme.of(context).cardColor,
//                           toolbarHeight: 0,
//                           // floating: true,
//                           automaticallyImplyLeading: false,
//                           forceElevated: true,
//                           elevation: 0,
//                           expandedHeight: 280,
//                           iconTheme: Theme.of(context)
//                               .iconTheme
//                               .copyWith(color: _iconColor),
//                           flexibleSpace: FlexibleSpaceBar(
//                             collapseMode: CollapseMode.none,
//                             background: background,
//                           ),
//                         ),
//                         SliverPositioned(
//                           right: 2,
//                           bottom: 2,
//                           child: SliverToBoxAdapter(
//                             child: actionGalleries,
//                           ),
//                         ),
//                         SliverPositioned(
//                           left: 2,
//                           right: 2,
//                           bottom: 2,
//                           child: SliverToBoxAdapter(
//                             child: Container(
//                               width: MediaQuery.of(context).size.width,
//                               height: 10,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.rectangle,
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .onTertiaryContainer,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ]),
                  // SliverPadding(
                  //     padding: const EdgeInsets.all(0),
                  //     sliver: SliverToBoxAdapter(
                  //         child: Stack(
                  //       children: [
                  //         AppBar(
                  //           excludeHeaderSemantics: true,
                  //           backgroundColor: Theme.of(context).cardColor,
                  //           toolbarHeight: 0,
                  //           // floating: true,
                  //           automaticallyImplyLeading: false,
                  //           elevation: 0,
                  //           scrolledUnderElevation: 280,
                  //           iconTheme: Theme.of(context)
                  //               .iconTheme
                  //               .copyWith(color: _iconColor),
                  //           flexibleSpace: FlexibleSpaceBar(
                  //             collapseMode: CollapseMode.none,
                  //             background: background,
                  //           ),
                  //         ),
                  //         Positioned(child: actionGalleries),
                  //         Positioned(
                  //           child: Container(
                  //             width: MediaQuery.of(context).size.width,
                  //             height: 10,
                  //             alignment: Alignment.center,
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.rectangle,
                  //               color: Theme.of(context)
                  //                   .colorScheme
                  //                   .onTertiaryContainer,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ))),
                  // Header For Location And Address
                  // SliverPadding(
                  //     padding: const EdgeInsets.all(0),
                  //     sliver: SliverToBoxAdapter(
                  //         child: Container(
                  //             color: Theme.of(context).colorScheme.onTertiary,
                  //             child: Column(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               mainAxisSize: MainAxisSize.max,
                  //               children: [
                  //                 Container(
                  //                   width: MediaQuery.of(context).size.width,
                  //                   height: 10,
                  //                   alignment: Alignment.center,
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.rectangle,
                  //                     color: Theme.of(context)
                  //                         .colorScheme
                  //                         .onTertiaryContainer,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 5),
                  //                 if (_hasMap) buildLocation(),
                  //               ],
                  //             )))),
                  // Header For Tabs
                  SliverPersistentHeader(
                    delegate: ProductDetailTab(
                        height: 55,
                        tabController: _tabController,
                        hasMap: _hasMap),
                    pinned: true,
                  ),

                  // Tab View
                  SliverSafeArea(
                    top: false,
                    bottom: false,
                    right: false,
                    left: false,
                    sliver: SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        sliver: _buildContent(_productDetailCubit.product)),
                  ),
                ]),
              ],
            ),
            bottomNavigationBar: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.1),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_productDetailCubit.product != null)
                        if (_productDetailCubit.product != null &&
                            AppBloc.userCubit.state != null &&
                            AppBloc.userCubit.state!.userId !=
                                _productDetailCubit
                                    .product!.createdBy!.userId) ...[
                          if (_productDetailCubit.product != null &&
                              _productDetailCubit.product!.isAddedCart)
                            ElevatedButton(
                                style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all<
                                        Color>(Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        Size(
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                            double.infinity))),
                                onPressed: () {
                                  Navigator.pushNamed(
                                          context, Routes.shoppingCart)
                                      .then((value) {
                                    if (value == true) {
                                      _productDetailCubit.onLoad(widget.id);
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    Theme.of(context).colorScheme.secondary),
                                fixedSize: MaterialStateProperty.all<Size>(Size(
                                    MediaQuery.of(context).size.width * 0.3,
                                    double.infinity))),
                            onPressed: _phoneAction,
                            child: Text(
                                Translate.of(context).translate('contact')),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    Theme.of(context).colorScheme.secondary),
                                fixedSize: MaterialStateProperty.all<Size>(Size(
                                    MediaQuery.of(context).size.width * 0.3,
                                    double.infinity))),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.chat,
                                arguments: {
                                  'user': ChatUserModel(
                                      userId: _productDetailCubit
                                          .product!.createdBy!.userId,
                                      userName: _productDetailCubit
                                          .product!.createdBy!.userName,
                                      profilePictureDataUrl: _productDetailCubit
                                          .product!
                                          .createdBy!
                                          .profilePictureDataUrl,
                                      accountName: _productDetailCubit
                                          .product!.createdBy!.accountName,
                                      fullName: _productDetailCubit
                                          .product!.createdBy!.fullName),
                                  'question': AttachmentMessage(
                                    image: _productDetailCubit.product!.image
                                        .replaceAll("TYPE", "thumb"),
                                    id: _productDetailCubit.product!.id
                                        .toString(),
                                    name: _productDetailCubit.product!.name,
                                    description:
                                        _productDetailCubit.product!.content,
                                    data: {
                                      "categoryId": _productDetailCubit
                                          .product!.category!.id
                                    },
                                  ),
                                },
                              );
                            },
                            child: Text(Translate.of(context)
                                .translate('send_message')),
                          ),
                        ],
                      // if (AppBloc.userCubit.state != null) actionReport,
                    ]),
              ),
            ),
          );
        }));
  }
}
