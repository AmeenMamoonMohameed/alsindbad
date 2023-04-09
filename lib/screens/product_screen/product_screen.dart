import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:akarak/blocs/app_bloc.dart';
import 'package:akarak/screens/category/category.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/bloc.dart';
import '../../configs/config.dart';
import '../../models/model.dart';
import '../../models/model_product.dart';
import '../../packages/chat/models/attachment_message.dart';
import '../../repository/repository.dart';
import '../../utils/other.dart';
import '../../utils/translate.dart';
import '../../utils/validate.dart';
import '../../widgets/app_tag.dart';
import '../../widgets/app_user_info.dart';
import '../../widgets/widget.dart';

String productId = "";
Map<String, dynamic> product = {};
Map<String, dynamic> category = {
  'sub_categories': {'sasa', 'sas', 'sasas'}
};
Map<String, dynamic> user = {};
List images = [];
int colorIndex = 0;
int sizeIndex = 0;

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key, required this.id, required this.categoryId})
      : super(key: key);

  final int id;
  final int categoryId;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  final _productDetailCubit = ProductDetailCubit();
  late StreamSubscription _reviewSubscription;

  bool _hasMap = false;

  List<String?> selectedColors = [];

  Future<void> _getProduct() async {
    String result;
    // await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
    //   String token = await getToken() ?? "nothing";
    //   serverSocket.write("AUTH=" + token + ";GET_PRODUCT=" + productId + "\n");
    //   serverSocket.flush();
    //   serverSocket.listen((response) async {
    //     result = utf8.decode(response);
    //     final data = await json.decode(result);
    //     images = [];
    //     setState(() {
    //       product = data;
    //       for (int i = 1; i < product["images_count"] + 1; i++) {
    //         images.add("assets/products/$productId-$i.jpeg");
    //       }
    //     });
    //     product["image"] = await _getImage(product["image"]);
    //     _getCategory();
    //   });
    // });
    user['user_id'] = 145;
    product['images_count'] = 5;
    product['image'] =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/2012_Toyota_Camry_%28ASV50R%29_Altise_sedan_%282014-09-06%29.jpg/260px-2012_Toyota_Camry_%28ASV50R%29_Altise_sedan_%282014-09-06%29.jpg';
    product['product_id'] = '11';
    product['has_color'] = true;
    product['has_size'] = true;
    product['sub_category'] = 1;
    product['description'] = {'الخامة': 'صوف', 'الفئة': 'شتوي'};
    product['colors'] = [
      {'name': 'بنفسجي', 'color': '0xff001fff'},
      {'name': 'اسود', 'color': '0xff000000'}
    ];
    product['sizes'] = ['sm', 'l', 'xl', 'xxl'];
    product['seller_name'] = 'ameen mamoon';
    product['name'] = 'فنايل صوف شتوي';
    product['price'] = 4554.54;
    product['stars'] = 4;
    product['seller'] = 4521;
    product['stock'] = 32;
    setState(() {});
  }

  Future<void> _getUser() async {
    // await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
    //   String token = await getToken() ?? "nothing";
    //   serverSocket.write("AUTH=$token;GET_ME\n");
    //   serverSocket.flush();
    //   serverSocket.listen((response) async {
    //     final data = await json.decode(utf8.decode(response));
    //     setState(() {
    //       user = data;
    //     });
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    _productDetailCubit.onLoad(widget.id);
    _hasMap = Application.submitSetting.categories
        .singleWhere((element) => element.id == widget.categoryId)
        .hasMap;

    colorIndex = 0;
    sizeIndex = 0;
    product = {};
    category = {};
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getProduct();
      await _getUser();
    });
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
    if (_productDetailCubit.product!.isAddedCart) {
      Navigator.pushNamed(context, Routes.shoppingCart).then((value) {
        if (value == true) {
          _productDetailCubit.onLoad(widget.id);
        }
      });
    } else {
      _productDetailCubit.onAddDeleteCart();
    }
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

  Widget _productImage() {
    if (_productDetailCubit.product == null) return Container();
    final CarouselController controller = CarouselController();
    List<Widget> list = [];
    list.add(Image.network(
        _productDetailCubit.product!.image.replaceAll('TYPE', 'full')));
    if (_productDetailCubit.product!.gallery.isNotEmpty) {
      _productDetailCubit.product!.gallery.forEach(((element) {
        list.add(Image.network(element.replaceAll('TYPE', 'full')));
      }));
    }
    return CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.width,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 1,
        ),
        carouselController: controller,
        items: list
        // [
        //   product.isNotEmpty && (product["image"] as String).length > 1000
        //       ? Image.network(product["image"])
        //       : Image.network(
        //           'https://www.777736225.com/wp-content/uploads/2022/11/%D9%A2%D9%A0%D9%A2%D9%A2%D9%A1%D9%A1%D9%A1%D9%A5_%D9%A1%D9%A3%D9%A5%D9%A4%D9%A4%D9%A1.jpg.webp'),
        //   Image.network(
        //       'https://www.777736225.com/wp-content/uploads/2022/11/%D9%A2%D9%A0%D9%A2%D9%A2%D9%A1%D9%A1%D9%A1%D9%A5_%D9%A1%D9%A3%D9%A4%D9%A9%D9%A3%D9%A0-600x600.jpg.webp'),
        //   Image.network(
        //       'https://www.777736225.com/wp-content/uploads/2022/11/%D9%A2%D9%A0%D9%A2%D9%A2%D9%A1%D9%A1%D9%A1%D9%A5_%D9%A1%D9%A3%D9%A5%D9%A4%D9%A5%D9%A9.jpg.webp')
        //   // Container(
        //   //     child: Center(
        //   //       child: CircularProgressIndicator(color: Colors.grey.shade300),
        //   //     ),
        //   //   )
        // ],
        );
  }

  Widget _properties() {
    if (_productDetailCubit.product == null) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: AppPlaceholder(
                      child: Container(
                          width: 150, height: 20, color: Colors.white))),
              Align(
                  alignment: Alignment.centerLeft,
                  child: AppPlaceholder(
                      child: Container(
                          width: 120, height: 20, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: AppPlaceholder(
                      child: Container(
                          width: 110, height: 20, color: Colors.white))),
              Align(
                  alignment: Alignment.centerLeft,
                  child: AppPlaceholder(
                      child: Container(
                          width: 110, height: 20, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: AppPlaceholder(
                      child: Container(
                          width: 140, height: 20, color: Colors.white))),
              Align(
                  alignment: Alignment.centerLeft,
                  child: AppPlaceholder(
                      child: Container(
                          width: 130, height: 20, color: Colors.white))),
            ],
          )
        ],
      );
    }
    List<ExtendedAttributeModel> properties = _productDetailCubit
        .product!.extendedAttributes
        .where((element) => element.group == "property")
        .toList();
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                    verticalOffset: -25.0,
                    child: FadeInAnimation(
                        child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(properties[index].key,
                              style: Theme.of(context).textTheme.caption),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(properties[index].getValue().toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(color: Colors.black)),
                        ),
                        const SizedBox(height: 30)
                      ],
                    ))));
          }),
    );
  }

  Widget _colorWidget(Color color, {bool isSelected = false}) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: color.withAlpha(150),
      child: isSelected
          ? Icon(
              Icons.check_circle,
              color: color,
              size: 18,
            )
          : CircleAvatar(
              radius: 7,
              backgroundColor:
                  color == Color(0xffffffff) ? Colors.grey : color),
    );
  }

  Widget _sizeWidget(String size, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: isSelected
                  ? product["has_color"]
                      ? Color(int.parse(product["colors"][colorIndex]['color']))
                      : Colors.lightBlueAccent
                  : Colors.grey.withOpacity(0.5),
              spreadRadius: 1.5),
        ],
      ),
      child: Text(size,
          style: TextStyle(
              fontFamily: 'Beheshti',
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Colors.black)),
    );
  }

  Widget _availableColor() {
    if (_productDetailCubit.product == null) {
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppPlaceholder(
                    child:
                        Container(width: 120, height: 30, color: Colors.white)),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
                const SizedBox(width: 8),
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
                const SizedBox(width: 8),
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
              ],
            ),
          )
        ],
      );
    }
    if (_productDetailCubit.product!.category?.hasColors == false) {
      return Container();
    }
    List<ExtendedAttributeModel> colors = _productDetailCubit
        .product!.extendedAttributes
        .where((element) => element.key == 'color')
        .toList();
    List<Widget> colorWidgets = [];
    for (int i = 0; i < colors.length; i++) {
      colorWidgets.add(GestureDetector(
        onTap: () {
          setState(() {
            colorIndex = i;
          });
        },
        child: _colorWidget(Color(int.parse('0x${colors[i].text!}')),
            isSelected: i == colorIndex ? true : false),
      ));
      if (i != colors.length - 1) {
        colorWidgets.add(const SizedBox(width: 15));
      }
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("اللون:",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.black)),
              const SizedBox(width: 5),
              Text(colors[colorIndex].text!,
                  style: Theme.of(context).textTheme.caption?.copyWith(
                      color: int.parse('0x${colors[colorIndex].text!}') !=
                              0xffffff
                          ? Color(int.parse('0x${colors[colorIndex].text!}'))
                          : Colors.grey)),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            children: colorWidgets,
          ),
        )
      ],
    );
  }

  Widget _buildCategories() {
    if (_productDetailCubit.product == null) return Container();

    List<Widget> listA = [];
    List<Widget> listB = [];

    CategoryModel? category = _productDetailCubit.product?.category;
    bool isLooping = true;
    int i = 0;
    while (isLooping) {
      category = Application.submitSetting.categories
          .singleWhere((element) => element.id == category!.parentId);

      if (i != 0) {
        listA.add(Text(">",
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Colors.blue.withOpacity(0.5))));
        listA.add(
          const SizedBox(width: 5),
        );
      }
      listA.add(GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(
              // builder: (context) => CategoryScreen(
              //     product["sub_category"]
              //         .toString()
              //         .split("_")[0])));
              builder: (context) => Container()));
        },
        child: Text(
          category.name,
          style: Theme.of(context).textTheme.caption?.copyWith(
              fontWeight: FontWeight.normal, fontSize: 12, color: Colors.blue),
        ),
      ));
      listA.add(
        const SizedBox(width: 5),
      );

      if (category.parentId == null) {
        isLooping = false;
      }
      i++;
    }
    for (int j = listA.length - 1; j >= 0; j--) {
      listB.add(listA[j]);
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: listB);
  }

  Widget _availableSize() {
    if (_productDetailCubit.product == null) {
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppPlaceholder(
                    child:
                        Container(width: 120, height: 30, color: Colors.white)),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
                const SizedBox(width: 8),
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
                const SizedBox(width: 8),
                AppPlaceholder(
                    child: Container(
                  width: 20,
                  height: 30,
                  color: Colors.white,
                  // decoration: const BoxDecoration(shape: BoxShape.circle),
                )),
              ],
            ),
          )
        ],
      );
    }

    List<ExtendedAttributeModel> sizes = _productDetailCubit
        .product!.extendedAttributes
        .where((element) => element.key == 'size')
        .toList();

    List<Widget> sizeWidgets = [];
    for (int i = 0; i < sizes.length; i++) {
      sizeWidgets.add(GestureDetector(
        onTap: () {
          setState(() {
            sizeIndex = i;
          });
        },
        child: _sizeWidget(sizes[i].text!,
            isSelected: i == sizeIndex ? true : false),
      ));
      if (i != sizes.length - 1) {
        sizeWidgets.add(const SizedBox(width: 15));
      }
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Text("المقاس",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.black)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: sizeWidgets,
          ),
        )
      ],
    );
  }

  Widget _buyButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          _onAddCart();
        },
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            shadowColor: Colors.black.withOpacity(0.4),
            fixedSize: Size(MediaQuery.of(context).size.width * 0.5, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _productDetailCubit.product != null &&
                          _productDetailCubit.product!.isAddedCart
                      ? 'اكمال الشراء'
                      : 'اضف الى السلة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                    _productDetailCubit.product != null &&
                            _productDetailCubit.product!.isAddedCart
                        ? Icons.remove_shopping_cart
                        : Icons.add_shopping_cart,
                    color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _cancelBuyButton() {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 4,
          left: AppLanguage.isRTL() ? 10 : 0,
          right: AppLanguage.isRTL() ? 0 : 10),
      child: ElevatedButton(
        onPressed: () {
          _productDetailCubit.onAddDeleteCart();
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.red,
            shadowColor: Colors.white.withOpacity(0.5),
            fixedSize: Size(MediaQuery.of(context).size.width * 0.08, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            )),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Icon(Icons.remove_shopping_cart, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _chatButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.chat,
            arguments: {
              'user': ChatUserModel(
                  userId: _productDetailCubit.product!.createdBy!.userId,
                  userName: _productDetailCubit.product!.createdBy!.userName,
                  profilePictureDataUrl: _productDetailCubit
                      .product!.createdBy!.profilePictureDataUrl,
                  accountName:
                      _productDetailCubit.product!.createdBy!.accountName,
                  fullName: _productDetailCubit.product!.createdBy!.fullName),
              'question': AttachmentMessage(
                image: _productDetailCubit.product!.image
                    .replaceAll("TYPE", "thumb"),
                id: _productDetailCubit.product!.id.toString(),
                name: _productDetailCubit.product!.name,
                description: _productDetailCubit.product!.content,
                data: {
                  "categoryId": _productDetailCubit.product!.category!.id,
                  "hasMap": _productDetailCubit.product!.category!.hasMap
                },
              ),
            },
          );

          Navigator.pushNamed(
            context,
            Routes.chat,
            arguments: {
              'user': ChatUserModel(
                  userId: _productDetailCubit.product!.createdBy!.userId,
                  userName: _productDetailCubit.product!.createdBy!.userName,
                  profilePictureDataUrl: _productDetailCubit
                      .product!.createdBy!.profilePictureDataUrl,
                  accountName:
                      _productDetailCubit.product!.createdBy!.accountName,
                  fullName: _productDetailCubit.product!.createdBy!.fullName),
              'question': AttachmentMessage(
                image: _productDetailCubit.product!.image
                    .replaceAll("TYPE", "thumb"),
                id: _productDetailCubit.product!.id.toString(),
                name: _productDetailCubit.product!.name,
                description: _productDetailCubit.product!.content,
                data: {"categoryId": _productDetailCubit.product!.category!.id},
              ),
            },
          );
        },
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            shadowColor: Colors.black.withOpacity(0.5),
            fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "تواصل",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.message, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _outOfStockButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          Fluttertoast.showToast(
            msg: "نداریم دیگه مهندس",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
        style: ElevatedButton.styleFrom(
            primary: Color(0xffE6123D),
            shadowColor: Colors.black.withOpacity(0.5),
            fixedSize: Size(250, 50),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10),
            )),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "کالا ناموجود می‌باشد  :(",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getStars(int star) {
    List<Widget> stars = [];
    for (int i = 5 - star; i > 0; i--) {
      stars.add(const Icon(Icons.star_border, size: 17));
    }
    for (int i = 0; i < star; i++) {
      stars.add(const Icon(Icons.star, color: Color(0xFFF1EE52), size: 17));
    }
    return stars;
  }

  Widget _detailWidget() {
    return DraggableScrollableSheet(
      maxChildSize: .75,
      initialChildSize: .53,
      minChildSize: .53,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -10),
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: _buildCategories()),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _productDetailCubit.product != null
                                ? Text(
                                    _productDetailCubit
                                            .product?.createdBy!.accountName ??
                                        '',
                                    style: const TextStyle(
                                        fontFamily: 'Beheshti',
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xFF016FA0)))
                                : SizedBox(
                                    width: 60.0,
                                    height: 15.0,
                                    child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade50,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: 500.0,
                                          height: 500.0,
                                          color: Colors.white,
                                        )),
                                  ),
                            const SizedBox(width: 5),
                            const Icon(Icons.people,
                                size: 15, color: Color(0xFF016FA0))
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: _productDetailCubit.product != null
                            ? Text(_productDetailCubit.product!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                            : SizedBox(
                                width: 200.0,
                                height: 30.0,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade50,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 500.0,
                                      height: 500.0,
                                      color: Colors.white,
                                    )),
                              ),
                      ),
                      product.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    AppTag(
                                      _productDetailCubit.product == null
                                          ? "0.0"
                                          : _productDetailCubit.product!.rate
                                              .toString(),
                                      type: TagType.rate,
                                    ),
                                    const SizedBox(width: 4),
                                    RatingBar.builder(
                                      initialRating:
                                          _productDetailCubit.product?.rate ??
                                              0,
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
                                    Text(
                                      "(${_productDetailCubit.product?.numRate})",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _productDetailCubit.product != null
                                        ? Text(
                                            _productDetailCubit.product!.price,
                                            style: const TextStyle(
                                                fontFamily: 'Beheshti',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 22,
                                                color: Colors.black))
                                        : SizedBox(
                                            width: 100.0,
                                            height: 30.0,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade50,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  width: 500.0,
                                                  height: 500.0,
                                                  color: Colors.white,
                                                )),
                                          ),
                                    _productDetailCubit.product != null
                                        ? Text(
                                            _productDetailCubit
                                                .product!.currency!.code,
                                            style: const TextStyle(
                                                fontFamily: 'Beheshti',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                color: Colors.black))
                                        : SizedBox(
                                            width: 40.0,
                                            height: 30.0,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade50,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  width: 500.0,
                                                  height: 500.0,
                                                  color: Colors.white,
                                                )),
                                          ),
                                  ],
                                ),
                                // Row(
                                //   children: product.isNotEmpty
                                //       ? getStars(product["stars"])
                                //       : [],
                                // ),
                              ],
                            )
                          : SizedBox(
                              width: 75.0,
                              height: 25,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade50,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: 500.0,
                                    height: 500.0,
                                    color: Colors.white,
                                  )),
                            ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(),
                  _availableColor(),
                  const SizedBox(
                    height: 15,
                  ),
                  _availableSize(),
                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(),
                  product.isNotEmpty
                      ? Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  Translate.of(context).translate('details'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.black)),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(CupertinoIcons.list_bullet, size: 25),
                            )
                          ],
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 250.0,
                          child: Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 500.0,
                                height: 500.0,
                                color: Colors.white,
                              )),
                        ),
                  product.isNotEmpty
                      ? const SizedBox(
                          height: 15,
                        )
                      : Container(),
                  product.isNotEmpty ? _properties() : Container(),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      _onShare(_productDetailCubit.product!);
                    },
                    child: Material(
                      color: Theme.of(context).colorScheme.onTertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Translate.of(context).translate('share'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.share, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
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
                  InkWell(
                    onTap: () {},
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
                  const SizedBox(height: 16),
                  _descriptionWidget(),
                  const SizedBox(height: 24),
                  const Divider(),
                  _userInfoWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _descriptionWidget() {
    if (_productDetailCubit.product == null) {
      return AppPlaceholder(
          child: Container(
              width: double.infinity, height: 200, color: Colors.white));
    }
    return Text(
      _productDetailCubit.product!.content,
      style: Theme.of(context).textTheme.caption,
      textAlign: TextAlign.center,
    );
  }

  Widget _userInfoWidget() {
    if (_productDetailCubit.product == null) {
      return AppUserInfo(
        type: UserViewType.informationAdv,
        onPressed: () {},
      );
    }
    return AppUserInfo(
      user: _productDetailCubit.product!.createdBy,
      type: UserViewType.informationAdv,
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _productDetailCubit,
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
            builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 120,
              leading: Container(),
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100))),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.black, size: 25),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          _onFavorite();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100))),
                          child: Icon(
                              _productDetailCubit.product != null &&
                                      _productDetailCubit.product!.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: Colors.redAccent,
                              size: 25),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0),
            ),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _productImage(),
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  child: _detailWidget(),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_productDetailCubit.product != null &&
                                _productDetailCubit.product!.isAddedCart)
                              _cancelBuyButton(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            _buyButton(),
                            const SizedBox(width: 8),
                            if (_productDetailCubit.product == null ||
                                _productDetailCubit
                                        .product!.createdBy?.userId !=
                                    AppBloc.userCubit.state?.userId)
                              _chatButton(),
                          ],
                        ),
                      ],
                    ))
              ],
            ),
          );
        }));
  }
}
