import 'dart:async';

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
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'dart:ui' as ui;

import '../../models/model_location.dart';
import '../../notificationservice_.dart';
import '../../repository/location_repository.dart';
import '../../widgets/app_location_item.dart';
import '../../widgets/widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  late StreamSubscription _submitSubscription;
  late StreamSubscription _reviewSubscription;

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
    Navigator.pushNamed(context, Routes.searchHistory);
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

    return Container(
      padding: const EdgeInsets.all(8),
      child: content,
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
          child: AppCategory(
            type: CategoryView.cardLarge,
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

    return Column(
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

    return Padding(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate('recent_location'),
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
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "settingScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          List<CategoryModel>? categories;
          List<LocationModel>? popularLocations;
          List<ProductModel>? recentProducts;

          if (state is HomeSuccess) {
            // popularLocations = state.popularLocations;
            // recentProducts = state.recentProducts;
          }

          return
              // BlocListener<InitCubit, InitState>(
              //   listener: (context, initState) async {
              //     if (initState is InitSuccess) {
              //       if (initState.list.any((element) =>
              //           element.lastMessage?.fromUserId !=
              //               AppBloc.userCubit.state?.userId &&
              //           element.lastMessage?.status != Status.seen)) {
              //         if (initState.isAlerm) {
              //         }
              //         if (initState.isVibrate) {
              //           Vibration.cancel();
              //           Vibration.vibrate(duration: 128);
              //         }

              //         if (initState.isOpenDrawer) {
              //           if (!(scaffoldKey.currentState?.isDrawerOpen ?? false)) {
              //             if (ModalRoute.of(context)!.isCurrent) {
              //               scaffoldKey.currentState?.openDrawer();
              //             }
              //           }
              //         }
              //       }
              //     }
              //   },
              //   child:
              Scaffold(
            // key: Application.scaffoldKey,
            // drawer: Application.mainDrawer,
            appBar: AppBar(
              // leading: IconButton(
              //   icon: const Icon(Icons.menu),
              //   onPressed: () =>
              //       scaffoldKey.currentState?.openDrawer(),
              // ),
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
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.52,
                        child: TextButton(
                          onPressed: _onSearch,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(.3),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        Translate.of(context).translate(
                                          'search_location',
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
                                      padding:
                                          EdgeInsets.only(left: 4, right: 4),
                                      child: VerticalDivider(),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextButton(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Application.currentCountry?.name ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .appBarTheme
                                              .foregroundColor,
                                          fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        Translate.of(context).translate(
                                          'select_country',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .appBarTheme
                                                    .foregroundColor),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ]),
                          onPressed: () {
                            _onSelectCountry();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                              color: Theme.of(context)
                                                  .primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCategories(),
                          _buildLocation(popularLocations),
                          _buildCompanies(recentProducts),
                          _buildRecent(recentProducts),
                          const SizedBox(height: 28),
                        ],
                      ),
                    )
                  ]),
                )
              ],
            ),
            // ),
          );
        },
      ),
    );
  }
}
