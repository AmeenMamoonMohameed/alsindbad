import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/core_internal.dart';
import 'package:syncfusion_flutter_core/interactive_scroll_viewer_internal.dart';
import 'package:syncfusion_flutter_core/legend_internal.dart';
import 'package:syncfusion_flutter_core/localizations.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_core/tooltip_internal.dart';
import 'package:syncfusion_flutter_core/zoomable_internal.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AccountDetails extends StatefulWidget {
  final int? categoryId;
  const AccountDetails({Key? key, this.categoryId}) : super(key: key);

  @override
  _AccountDetailsState createState() {
    return _AccountDetailsState();
  }
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ignore: curly_braces_in_flow_control_structures
  List<CategoryModel> getCategories() {
    if (widget.categoryId != null) {
      return Application.submitSetting.categories
          .where((element) => element.parentId == widget.categoryId)
          .toList();
    }
    return Application.submitSetting.categories
        .where((element) => element.parentId == null)
        .toList();
  }

  int getTotalIncoming() {
    var totalIncoming = 0;
    if (widget.categoryId != null) {
      Application.submitSetting.categories
          .where((cat) => cat.parentId == widget.categoryId)
          .forEach((cat) {
        totalIncoming += getTotalIncomingCategoryItem(cat);
      });
      return totalIncoming;
    }
    AppBloc.userCubit.state?.extendedAttributes
        ?.where((element) =>
            element.key == "incoming" &&
            Application.submitSetting.categories.any((cat) =>
                cat.id.toString() == element.externalId &&
                cat.type == CategoryType.sub))
        .forEach((element) {
      totalIncoming += element.integer ?? 0;
    });
    return totalIncoming;
  }

  int getTotalOutcoming() {
    var totalOutcoming = 0;
    if (widget.categoryId != null) {
      Application.submitSetting.categories
          .where((cat) => cat.parentId == widget.categoryId)
          .forEach((cat) {
        totalOutcoming += getTotalOutcomingCategoryItem(cat);
      });
      return totalOutcoming;
    }
    AppBloc.userCubit.state?.extendedAttributes
        ?.where((element) =>
            element.key == "outcoming" &&
            Application.submitSetting.categories.any((cat) =>
                cat.id.toString() == element.externalId &&
                cat.type == CategoryType.sub))
        .forEach((element) {
      totalOutcoming += element.integer ?? 0;
    });
    return totalOutcoming;
  }

  int getTotalRemainder() {
    var totalIncoming = 0;
    var totalOutcoming = 0;
    if (widget.categoryId != null) {
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((element) =>
              element.key == "incoming" &&
              Application.submitSetting.categories.any((cat) =>
                  cat.parentId == widget.categoryId &&
                  cat.type == CategoryType.sub &&
                  cat.id.toString() == element.externalId))
          .forEach((element) {
        totalIncoming += element.integer ?? 0;
      });
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((element) =>
              element.key == "outcoming" &&
              Application.submitSetting.categories.any((cat) =>
                  cat.parentId == widget.categoryId &&
                  cat.type == CategoryType.sub &&
                  cat.id.toString() == element.externalId))
          .forEach((element) {
        totalOutcoming += element.integer ?? 0;
      });
      return totalIncoming - totalOutcoming;
    }

    AppBloc.userCubit.state?.extendedAttributes
        ?.where((element) =>
            element.key == "incoming" &&
            Application.submitSetting.categories.any((cat) =>
                cat.id.toString() == element.externalId &&
                cat.type == CategoryType.sub))
        .forEach((element) {
      totalIncoming += element.integer ?? 0;
    });
    AppBloc.userCubit.state?.extendedAttributes
        ?.where((element) =>
            element.key == "outcoming" &&
            Application.submitSetting.categories.any((cat) =>
                cat.id.toString() == element.externalId &&
                cat.type == CategoryType.sub))
        .forEach((element) {
      totalOutcoming += element.integer ?? 0;
    });
    return totalIncoming - totalOutcoming;
  }

  int getTotalIncomingCategoryItem(CategoryModel category) {
    var totalIncoming = 0;
    if (category.type == CategoryType.main) {
      List<int> subMainCurrentCategoryIds = [];
      bool isbreakLoop = true;
      int currentCategory = category.id;
      while (isbreakLoop) {
        if (Application.submitSetting.categories
                .where((item) => item.parentId == category.id)
                .isEmpty ||
            (Application.submitSetting.categories.length ==
                Application.submitSetting.categories
                    .where((item) =>
                        item.parentId == category.id &&
                        item.type == CategoryType.sub)
                    .length)) {
          isbreakLoop = false;
        }
        if (subMainCurrentCategoryIds.isNotEmpty) {
          currentCategory = subMainCurrentCategoryIds.first;
          subMainCurrentCategoryIds.remove(currentCategory);
        }
        for (var cat3 in Application.submitSetting.categories
            .where((cat4) => cat4.parentId == currentCategory)) {
          if (cat3.type == CategoryType.sub) {
            AppBloc.userCubit.state?.extendedAttributes
                ?.where((userEx) =>
                    userEx.key == "incoming" &&
                    userEx.externalId == cat3.id.toString())
                .forEach((userEx) {
              totalIncoming += userEx.integer ?? 0;
            });
          } else {
            subMainCurrentCategoryIds.add(cat3.id);
          }
        }
        if (subMainCurrentCategoryIds.isEmpty) {
          isbreakLoop = false;
        }
      }
    } else {
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((userEx) =>
              userEx.key == "incoming" &&
              userEx.externalId == category.id.toString())
          .forEach((userEx) {
        totalIncoming += userEx.integer ?? 0;
      });
    }

    return totalIncoming;
  }

  int getTotalOutcomingCategoryItem(CategoryModel category) {
    var totalOutcoming = 0;
    if (category.type == CategoryType.main) {
      List<int> subMainCurrentCategoryIds = [];
      bool isbreakLoop = true;
      int currentCategory = category.id;
      while (isbreakLoop) {
        if (Application.submitSetting.categories
                .where((item) => item.parentId == category.id)
                .isEmpty ||
            (Application.submitSetting.categories.length ==
                Application.submitSetting.categories
                    .where((item) =>
                        item.parentId == category.id &&
                        item.type == CategoryType.sub)
                    .length)) {
          isbreakLoop = false;
        }
        if (subMainCurrentCategoryIds.isNotEmpty) {
          currentCategory = subMainCurrentCategoryIds.first;
          subMainCurrentCategoryIds.remove(currentCategory);
        }
        for (var cat3 in Application.submitSetting.categories
            .where((cat4) => cat4.parentId == currentCategory)) {
          if (cat3.type == CategoryType.sub) {
            AppBloc.userCubit.state?.extendedAttributes
                ?.where((userEx) =>
                    userEx.key == "outcoming" &&
                    userEx.externalId == cat3.id.toString())
                .forEach((userEx) {
              totalOutcoming += userEx.integer ?? 0;
            });
          } else {
            subMainCurrentCategoryIds.add(cat3.id);
          }
        }
        if (subMainCurrentCategoryIds.isEmpty) {
          isbreakLoop = false;
        }
      }
    } else {
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((userEx) =>
              userEx.key == "outcoming" &&
              userEx.externalId == category.id.toString())
          .forEach((userEx) {
        totalOutcoming += userEx.integer ?? 0;
      });
    }

    return totalOutcoming;
  }

  int getTotalCategoryItem(CategoryModel category) {
    var totalIncoming = 0;
    var totalOutcoming = 0;
    if (category.type == CategoryType.main) {
      List<int> subMainCurrentCategoryIds = [];
      bool isbreakLoop = true;
      int currentCategory = category.id;
      while (isbreakLoop) {
        if (Application.submitSetting.categories
                .where((item) => item.parentId == category.id)
                .isEmpty ||
            (Application.submitSetting.categories.length ==
                Application.submitSetting.categories
                    .where((item) =>
                        item.parentId == category.id &&
                        item.type == CategoryType.sub)
                    .length)) {
          isbreakLoop = false;
        }
        if (subMainCurrentCategoryIds.isNotEmpty) {
          currentCategory = subMainCurrentCategoryIds.first;
          subMainCurrentCategoryIds.remove(currentCategory);
        }
        for (var cat3 in Application.submitSetting.categories
            .where((cat4) => cat4.parentId == currentCategory)) {
          if (cat3.type == CategoryType.sub) {
            AppBloc.userCubit.state?.extendedAttributes
                ?.where((userEx) =>
                    userEx.key == "incoming" &&
                    userEx.externalId == cat3.id.toString())
                .forEach((userEx) {
              totalIncoming += userEx.integer ?? 0;
            });
            AppBloc.userCubit.state?.extendedAttributes
                ?.where((userEx) =>
                    userEx.key == "outcoming" &&
                    userEx.externalId == cat3.id.toString())
                .forEach((userEx) {
              totalOutcoming += userEx.integer ?? 0;
            });
          } else {
            subMainCurrentCategoryIds.add(cat3.id);
          }
        }
        if (subMainCurrentCategoryIds.isEmpty) {
          isbreakLoop = false;
        }
      }
    } else {
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((userEx) =>
              userEx.key == "incoming" &&
              userEx.externalId == category.id.toString())
          .forEach((userEx) {
        totalIncoming += userEx.integer ?? 0;
      });
      AppBloc.userCubit.state?.extendedAttributes
          ?.where((userEx) =>
              userEx.key == "outcoming" &&
              userEx.externalId == category.id.toString())
          .forEach((userEx) {
        totalOutcoming += userEx.integer ?? 0;
      });
    }

    return totalIncoming - totalOutcoming;
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
          Translate.of(context).translate('تفاصيل الحساب'),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        // child: ConstrainedBox(
        //   constraints: BoxConstraints(
        //       minHeight: MediaQuery.of(context).size.height,
        //       ),
        // child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.only(
              top: 1,
              right: (MediaQuery.of(context).size.width * 0.03),
              left: (MediaQuery.of(context).size.width * 0.03),
              bottom: 10),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(
                      (MediaQuery.of(context).size.width * 0.03)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, right: 5, left: 5, bottom: 8),
                              child: Text(
                                "الحد الاعلى للاعلانات الفعالة",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, right: 5, left: 5, bottom: 8),
                              child: Text(
                                getTotalIncoming().toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                      if (getTotalIncoming().toDouble() > 0)
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(maxHeight: 7),
                          child: SfLinearGauge(
                            minimum: 0,
                            maximum: getTotalIncoming().toDouble(),
                            showLabels: false,
                            showAxisTrack: true,
                            showTicks: false,
                            isAxisInversed: true,
                            ranges: [
                              LinearGaugeRange(
                                startValue: 0,
                                endValue: getTotalOutcoming().toDouble(),
                                position: LinearElementPosition.cross,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                            axisTrackStyle: LinearAxisTrackStyle(
                                thickness: 5,
                                gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.5),
                                      Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.7)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: const [0.4, 0.9],
                                    tileMode: TileMode.clamp)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Text(
                              "الاعلانات الفعالة",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getTotalOutcoming().toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, right: 8, left: 8, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              "المتبقية",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getTotalRemainder().toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 20,
                      right: (MediaQuery.of(context).size.width * 0.03),
                      left: (MediaQuery.of(context).size.width * 0.03),
                      bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, right: 8, left: 8, bottom: 8),
                        child: Text(
                          "الحد الاعلى للاعلانات في القسم",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, right: 8, left: 8, bottom: 16),
                        child: Text(
                          "هذا هو الحد الاعلى المسموح للإعلان تحت كل قسم",
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Column(
                        children: getCategories().map((item) {
                          return InkWell(
                            onTap: () {
                              if (item.type == CategoryType.main) {
                                Navigator.pushNamed(
                                    context, Routes.accountDetails,
                                    arguments: item.id);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              constraints: const BoxConstraints(
                                                  maxHeight: 32, maxWidth: 32),
                                              width: 32,
                                              height: 32,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                                color: item.color,
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: item.icon != null
                                                    ? Application.domain +
                                                        item.iconUrl!
                                                            .replaceAll(
                                                                "\\", "/")
                                                            .replaceAll(
                                                                "TYPE", "full")
                                                    : '',
                                                color: item.color,
                                                colorBlendMode: BlendMode.color,
                                                filterQuality:
                                                    FilterQuality.high,
                                                width: 24,
                                                height: 24,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: Text(
                                                item.name,
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${item.hasOrder ? '∞' : getTotalIncomingCategoryItem(item)} إعلان",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                            RotatedBox(
                                              quarterTurns:
                                                  AppLanguage.isRTL() ? 2 : 0,
                                              child: Icon(
                                                AppLanguage.isRTL()
                                                    ? Icons.keyboard_arrow_right
                                                    : Icons.keyboard_arrow_left,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      // ),
      // ),
    );
  }
}
