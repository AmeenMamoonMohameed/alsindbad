import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/screens/home/home_category_item.dart';
import 'package:akarak/screens/home/home_category_list.dart';
import 'package:akarak/screens/home/home_sliver_app_bar.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../models/model_location.dart';
import '../../repository/list_repository.dart';
import '../../repository/location_repository.dart';
import '../../widgets/app_location_item.dart';
import '../../widgets/sections/seaction_a.dart';
import '../../widgets/sections/seaction_b.dart';
import '../../widgets/sections/seaction_c.dart';
import '../../widgets/sections/seaction_carousel.dart';
import '../../widgets/sections/seaction_d.dart';
import '../../widgets/sections/seaction_e.dart';
import '../../widgets/sections/seaction_g.dart';
import '../../widgets/widget.dart';
import '../notifications/notifications.dart';
import 'package:path/path.dart' as path;

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  _Home2State createState() {
    return _Home2State();
  }
}

class _Home2State extends State<Home2> {
  late StreamSubscription _submitSubscription;
  late StreamSubscription _reviewSubscription;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  @override
  void initState() {
    super.initState();
    AppBloc.homeCubit.onLoad();
    Application.currentCountry = LocationRepository.loadCountry();
    _submitSubscription = AppBloc.submitCubit.stream.listen((state) {
      if (state is Submitted) {
        AppBloc.homeCubit.onLoad();
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewByIdSuccess && state.productId != null) {
        AppBloc.homeCubit.onLoad();
      }
    });
  }

  @override
  void dispose() {
    _submitSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }

  ///Refresh
  Future<void> _onRefresh() async {
    await AppBloc.homeCubit.onLoad();
  }

  ///On search
  void _onSearch() {
    Navigator.pushNamed(context, Routes.searchHistory, arguments: _image);
  }

  ///On select category
  void _onTapService(Object item) {
    if (item is CategoryModel && (item).type == CategoryType.main) {
      Navigator.pushNamed(context, Routes.category, arguments: (item).id);
    } else if (item is CategoryModel && (item).type == CategoryType.sub) {
      Navigator.pushNamed(context, Routes.listProduct,
          arguments: {'categoryId': item.id});
    } else {
      Navigator.pushNamed(context, Routes.listProduct,
          arguments: {'locationId': (item as LocationModel).id});
    }
  }

  ///On Open More
  void _onOpenMore(
    BuildContext context, {
    List<CategoryModel>? categories,
  }) async {
    final result = await showModalBottomSheet<CategoryModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return HomeCategoryList(
          list: categories?.where((element) => element.id != -1).toList(),
          onOpenList: () {
            Navigator.pushNamed(context, Routes.category);
          },
          onPress: (item) {
            Navigator.pop(context, item);
          },
        );
      },
    );
    if (result != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      if (result.type == CategoryType.main) {
        Navigator.pushNamed(context, Routes.category, arguments: result.id);
      } else {
        Navigator.pushNamed(context, Routes.listProduct,
            arguments: {'categoryId': result.id});
      }
    }
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

  ///Select Country
  Future<void> _onSelectCountry() async {
    final result = await showModalBottomSheet<CountryModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [Application.currentCountry],
          data: Application.submitSetting.countries,
        ),
        // hasScroll: true,
      ),
    );
    setState(() {
      if (result != null) {
        Application.currentCountry = result;
        LocationRepository.onChangeCountry(country: result);
      }
    });
  }

  ///Build category UI
  Widget _buildCategories() {
    ///Loading
    Widget content = Wrap(
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(8, (index) => index).map(
        (item) {
          return const HomeCategoryItem();
        },
      ).toList(),
    );

    List<CategoryModel> listBuild = Application.submitSetting.categories;
    final more = CategoryModel.fromJson({
      "id": -1,
      "name": Translate.of(context).translate("more"),
      "icon": "fas fa-ellipsis",
      "color": "#ff8a65",
    });

    if (Application.submitSetting.categories.length >= 7) {
      listBuild = Application.submitSetting.categories.take(7).toList();
      listBuild.add(more);
    }

    content = Wrap(
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: listBuild.map(
        (item) {
          return HomeCategoryItem(
            item: item,
            onPressed: (item) {
              if (item.id == -1) {
                _onOpenMore(context,
                    categories: Application.submitSetting.categories
                        .take(Application.submitSetting.categories.length >= 8
                            ? 8
                            : 7)
                        .toList());
              } else {
                _onTapService(item);
              }
            },
          );
        },
      ).toList(),
    );
    List<Widget> listCategories = [];
    int c = 0;
    for (var item in Application.submitSetting.categories
        .where((element) => element.parentId == null)) {
      c++;
      listCategories.add(
        CustomListTile(
          isCollapsed: true,
          iconUrl: item.iconUrl,
          color: item.color,
          title: item.name,
          description: item.description,
          infoCount: 0,
          doHaveMoreOptions: Icons.arrow_forward_ios,
          isAppBar: false,
          onTap: () async {
            if (item.type == CategoryType.main) {
              await Navigator.pushNamed(context, Routes.category,
                  arguments: item.id);
            } else {
              await Navigator.pushNamed(
                context,
                Routes.listProduct,
                arguments: {'categoryId': item.id},
              );
            }
          },
        ),
      );
      if (c > 0) {
        listCategories.add(const SizedBox(height: 8));
        if (c !=
            Application.submitSetting.categories
                .where((element) => element.parentId == null)
                .length) {
          listCategories.add(const Divider(thickness: 1));
        }
      }
    }
    content = Column(
      children: listCategories,
    );
    return Card(
      // color: Theme.of(context).backgroundColor,
      child: Container(
        padding: const EdgeInsets.only(right: 8, left: 8, bottom: 16, top: 24),
        child: content,
      ),
    );
  }

  ///Build popular UI
  Widget _buildLocation(List<LocationModel>? location) {
    ///Loading
    Widget content = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: AppLocation(
            type: LocationView.cardLarge,
          ),
        );
      },
      itemCount: List.generate(8, (index) => index).length,
    );

    if (location != null) {
      content = ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = location[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AppLocation(
              item: item,
              type: LocationView.cardLarge,
              onPressed: () {
                _onTapService(item);
              },
            ),
          );
        },
        itemCount: location.length,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0, bottom: 16, top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.of(context).translate(
                      'popular_location',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Translate.of(context).translate(
                      'let_find_interesting',
                    ),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
            Container(
              height: 180,
              padding: const EdgeInsets.only(top: 4),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  ///most important companies
  Widget _buildCompanies(List<ProductModel>? companies) {
    Widget companies = TextButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.listProfile,
              arguments: UserType.company);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "${Translate.of(context).translate('most_important_companies')} ",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                RotatedBox(
                  quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    textDirection: ui.TextDirection.rtl,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));
    Widget offices = TextButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.listProfile,
              arguments: UserType.office);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "${Translate.of(context).translate('most_important_offices')} ",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                RotatedBox(
                  quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    textDirection: ui.TextDirection.rtl,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          Column(children: [
            const SizedBox(height: 16),
            const Divider(indent: 0),
            companies,
            const Divider(indent: 0),
            offices,
            const Divider(indent: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  Translate.of(context).translate('by_rating'),
                  style: Theme.of(context)
                      .textTheme
                      .overline!
                      .copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ])
        ]),
      ),
    );
  }

  ///Build list recent
  Widget _buildRecent(List<ProductModel>? recent) {
    ///Loading
    Widget content = ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: AppProductItem(type: ProductViewType.small),
        );
      },
      itemCount: 8,
    );

    if (recent != null) {
      content = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = recent[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppProductItem(
              onPressed: () {
                _onProductDetail(item);
              },
              item: item,
              type: ProductViewType.small,
            ),
          );
        },
        itemCount: recent.length,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0, bottom: 16, top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translate.of(context).translate('recent_location'),
                    // Translate.of(context).translate('recent_location'),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      Translate.of(context).translate(
                        'what_happen',
                      ),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBloc.initCubit.onLoad();

    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          List<HomeSectionModel>? homeSections;
          // List<CategoryModel>? categories;
          // List<LocationModel>? popularLocations;
          // List<ProductModel>? recentProducts;

          if (state is HomeSuccess) {
            homeSections = state.list;
            // popularLocations = state.popularLocations;
            // recentProducts = state.recentProducts;
          }
          return Scaffold(
            // drawerEnableOpenDragGesture: false,

            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () =>
                    Application.scaffoldKey.currentState?.openDrawer(),
              ),
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              toolbarTextStyle: Theme.of(context).textTheme.button!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
              titleTextStyle: Theme.of(context).textTheme.button!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: "akarak",
                                ),
                                TextSpan(
                                  text: ".ONLINE",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.25,
                            child: IconButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(Routes.notifications),
                                icon: const Icon(Icons.notifications)),
                          ),
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.25,
                            child: IconButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(Routes.shoppingCart),
                                icon: const Icon(Icons.shopping_cart_sharp)),

                            // TextButton(
                            //   child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           Application.currentCountry?.name ?? '',
                            //           style: Theme.of(context)
                            //               .textTheme
                            //               .bodyMedium!
                            //               .copyWith(
                            //                   color: Theme.of(context)
                            //                       .appBarTheme
                            //                       .foregroundColor,
                            //                   fontWeight: FontWeight.bold),
                            //         ),
                            //         Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: <Widget>[
                            //             Expanded(
                            //               child: Text(
                            //                 Translate.of(context).translate(
                            //                   'select_country',
                            //                 ),
                            //                 style: Theme.of(context)
                            //                     .textTheme
                            //                     .caption!
                            //                     .copyWith(
                            //                         color: Theme.of(context)
                            //                             .appBarTheme
                            //                             .foregroundColor),
                            //               ),
                            //             ),
                            //             Icon(
                            //               Icons.arrow_drop_down_outlined,
                            //               color: Theme.of(context).primaryColor,
                            //             ),
                            //           ],
                            //         ),
                            //       ]),
                            //   onPressed: () {
                            //     _onSelectCountry();
                            //   },
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white, //const Color(0x3CA6B6F7),
            // extendBodyBehindAppBar: true,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                CupertinoSliverRefreshControl(
                  onRefresh: _onRefresh,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 24),

                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 70,
                                child: TextButton(
                                  onPressed: _onSearch,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).dividerColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                Translate.of(context).translate(
                                                  'search',
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .button!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .appBarTheme
                                                            .foregroundColor),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: VerticalDivider(),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  _image = await _imagePicker
                                                      .pickImage(
                                                          source: ImageSource
                                                              .gallery);
                                                  if (_image != null) {
                                                    Uint8List bytes =
                                                        await _image!
                                                            .readAsBytes();
                                                    // String bs4str =
                                                    //     base64Encode(bytes);
                                                    // Map<String, dynamic>
                                                    //     params = {
                                                    //   "externalId":
                                                    //       "externalId",
                                                    //   "fileName": _image!.path
                                                    //       .split('/')
                                                    //       .last,
                                                    //   "extension":
                                                    //       path.extension(
                                                    //           _image!.path),
                                                    //   "uploadType":
                                                    //       UploadType.product,
                                                    //   "size": bytes
                                                    //       .elementSizeInBytes,
                                                    //   "data": bs4str,
                                                    // };
                                                    _onSearch();
                                                    // UtilOther.buildFilterParams(
                                                    //     FilterModel(
                                                    //         byImage: params));
                                                  }
                                                } catch (e) {}
                                              },
                                              icon: const Icon(
                                                Icons.camera_enhance,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // SectionCarousel(data: const {
                          //   'title': 'Featured Categories',
                          //   'description': 'description',
                          //   'color': 0x52A6F7E7,
                          //   'list': [
                          //     {
                          //       'name': 'Mobiles & \nElectorincs',
                          //       'image':
                          //           'https://images-eu.ssl-images-amazon.com/images/G/31/img21/Wireless/WLA/TS/D37847648_Accessories_savingdays_Jan22_Cat_PC_1500.jpg',
                          //       'color': 0x5EA6B6F7,
                          //     },
                          //     {
                          //       'name': 'Amazon \nFashion',
                          //       'image':
                          //           'https://images-eu.ssl-images-amazon.com/images/G/31/img2021/Vday/bwl/English.jpg',
                          //       'color': 0x5EA6B6F7,
                          //     },
                          //     {
                          //       'name': 'Home & \nKitchen',
                          //       'image':
                          //           'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Wireless/AdvantagePrime/BAU/14thJan/D37196025_IN_WL_AdvantageJustforPrime_Jan_Mob_ingress-banner_1242x450.jpg',
                          //       'color': 0x5EA6B6F7,
                          //     },
                          //     {
                          //       'name': 'Home & \nKitchen',
                          //       'image':
                          //           'https://images-na.ssl-images-amazon.com/images/G/31/Symbol/2020/00NEW/1242_450Banners/PL31_copy._CB432483346_.jpg',
                          //       'color': 0x5EA6B6F7,
                          //     },
                          //     {
                          //       'name': 'Home & \nKitchen',
                          //       'image':
                          //           'https://images-na.ssl-images-amazon.com/images/G/31/img21/shoes/September/SSW/pc-header._CB641971330_.jpg',
                          //       'color': 0x5EA6B6F7,
                          //     },
                          //   ]
                          // }),

                          // _buildCategories(),
                          // const SizedBox(height: 16),
                          // const Divider(),
                          if (homeSections != null)
                            for (var item in homeSections) ...[
                              if (item.sectionType == HomeSectionType.sectionD)
                                SectionD(data: item)
                              else if (item.sectionType ==
                                  HomeSectionType.sectionA)
                                SectionA(data: item)
                              else if (item.sectionType ==
                                  HomeSectionType.sectionB)
                                SectionB(data: item)
                              else if (item.sectionType ==
                                  HomeSectionType.sectionG)
                                SectionG(data: item)
                              else if (item.sectionType ==
                                  HomeSectionType.sectionCarousel)
                                SectionCarousel(data: item)
                              else if (item.sectionType ==
                                  HomeSectionType.sectionE)
                                SectionE(data: item),
                            ],

                          // _buildLocation(popularLocations),
                          // _buildCompanies(recentProducts),
                          // _buildRecent(recentProducts),
                          const SizedBox(height: 28),
                        ],
                      ),
                    )
                  ]),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
