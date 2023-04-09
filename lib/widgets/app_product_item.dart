import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../blocs/app_bloc.dart';
import '../configs/application.dart';
import '../configs/language.dart';

class AppProductItem extends StatelessWidget {
  const AppProductItem({
    Key? key,
    this.item,
    this.onPressed,
    required this.type,
    this.trailing,
  }) : super(key: key);

  final ProductModel? item;
  final ProductViewType type;
  final VoidCallback? onPressed;
  final Widget? trailing;

  double calculateAutoscaleFontSize(
      String text, TextStyle style, double startFontSize, double maxWidth) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    var currentFontSize = startFontSize;

    for (var i = 0; i < 100; i++) {
      // limit max iterations to 100
      final nextFontSize = currentFontSize + 1;
      final nextTextStyle = style.copyWith(fontSize: nextFontSize);
      textPainter.text = TextSpan(text: text, style: nextTextStyle);
      textPainter.layout();
      if (textPainter.width >= maxWidth) {
        break;
      } else {
        currentFontSize = nextFontSize;
        // continue iteration
      }
    }

    return currentFontSize;
  }

  String getPrice() {
    // CurrencyModel default_ = Application.submitSetting.currencies
    //     .singleWhere((cur) => cur.isDefault);
    if (Application.currentCurrency == null ||
        Application.currentCurrency?.id == 0) {
      return "${item!.price} ${Application.submitSetting.currencies.singleWhere((cur) => cur.id == item?.currency?.id).code}";
    } else {
      double price = Application.submitSetting.currencies
              .singleWhere((cur) => cur.id == item?.currency?.id)
              .exchange *
          double.parse(item!.price);
      price = price / (Application.currentCurrency?.exchange ?? 1);
      return "$price ${Application.currentCurrency?.code}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rateWidget = <Widget>[
      AppTag(
        item == null ? "0.0" : "${item!.rate}",
        type: TagType.rate,
      ),
      const SizedBox(width: 4),
      RatingBar.builder(
        initialRating: item == null ? 0.0 : item!.rate,
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
    ];

    switch (type) {

      ///Mode View pending
      case ProductViewType.pending:
        if (item == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 180,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      width: 80,
                      height: 100,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(width: 4),
                    Text(
                      item!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item?.category?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        AppTag(
                          item!.status.name,
                          color: UtilColor.getColorFromHex(
                              item?.statusColor ?? '0xFF2196F3'),
                          type: TagType.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: rateWidget,
                    // ),
                  ],
                ),
              ),
              trailing ?? Container()
            ],
          ),
        );

      ///Mode View Small
      case ProductViewType.smallWithViews:
        if (item == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 180,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      width: 80,
                      height: 100,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(width: 4),
                    Text(
                      item!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item?.category?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: rateWidget,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.visibility_outlined,
                              size: 17,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${item?.views}  ${Translate.of(context).translate("total_views")}",
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
              trailing ?? Container()
            ],
          ),
        );

      ///Mode View Small
      case ProductViewType.small:
        if (item == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 180,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      width: 80,
                      height: 100,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(width: 4),
                    Text(
                      item!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item?.category?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: rateWidget,
                    ),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (item!.extendedAttributes.any(
                              (e) => e.key == "area" && e.double_ != null)) ...[
                            Icon(
                              UtilIcon.getIconFromCss("fas fa-maximize"),
                              size: 17,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "area")
                                    .double_
                                    .toString(),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                          // Icon(
                          //   Icons.layers_outlined,
                          //   size: 15,
                          //   color: Theme.of(context).primaryColor,
                          // ),
                          // const SizedBox(width: 4),
                          // Expanded(
                          //   child: Text(
                          //     item!.excerpt.substring(
                          //         0,
                          //         item!.excerpt.length < 30
                          //             ? item!.excerpt.length
                          //             : 30),
                          //     maxLines: 1,
                          //     style: Theme.of(context).textTheme.caption,
                          //   ),
                          // ),
                          if (item!.extendedAttributes.any((e) =>
                              e.key == "rooms" && e.integer != null)) ...[
                            Icon(
                              Icons.bedroom_parent_outlined,
                              size: 17,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "rooms")
                                    .integer
                                    .toString(),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                          if (item!.extendedAttributes.any((e) =>
                              e.key == "baths" && e.integer != null)) ...[
                            Icon(
                              Icons.bathroom_outlined,
                              size: 17,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "baths")
                                    .integer
                                    .toString(),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            )
                          ],
                        ]),
                  ],
                ),
              ),
              trailing ?? Container()
            ],
          ),
        );

      ///Mode View Gird
      case ProductViewType.grid:
        if (item == null) {
          return AppPlaceholder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 24,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  color: Colors.white,
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            item!.statusText.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AppTag(
                                      item!.statusText,
                                      type: TagType.status,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                item!.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                item?.category?.name ?? '',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                item!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: rateWidget,
              ),
              const SizedBox(height: 8),
              Text(
                getPrice(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      ///Mode View List
      case ProductViewType.list:
        if (item == null) {
          return AppPlaceholder(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 140,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        width: 100,
                        height: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            item!.statusText.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AppTag(
                                      item!.statusText,
                                      type: TagType.status,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      );
                    },
                    placeholder: (context, url) {
                      return AppPlaceholder(
                        child: Container(
                          width: 100,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return AppPlaceholder(
                        child: Container(
                          width: 100,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 8),
                        Text(
                          item?.category?.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: rateWidget,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${item!.state?.name}, ${item!.city?.name}, ${item?.category?.hasMap == true ? item!.extendedAttributes.singleWhere((e) => e.key == "address").text : ""}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getPrice(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        // const SizedBox(height: 8),
                        // Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: <Widget>[
                        //       if (item!.area != null) ...[
                        //         Icon(
                        //           UtilIcon.getIconFromCss("fas fa-maximize"),
                        //           size: 20,
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //         const SizedBox(width: 4),
                        //         Expanded(
                        //           child: Text(
                        //             item!.area.toString(),
                        //             maxLines: 1,
                        //             overflow: TextOverflow.ellipsis,
                        //             style: Theme.of(context).textTheme.caption,
                        //           ),
                        //         ),
                        //       ],
                        //       // Icon(
                        //       //   Icons.layers_outlined,
                        //       //   size: 15,
                        //       //   color: Theme.of(context).primaryColor,
                        //       // ),
                        //       // const SizedBox(width: 4),
                        //       // Expanded(
                        //       //   child: Text(
                        //       //     item!.excerpt.substring(
                        //       //         0,
                        //       //         item!.excerpt.length < 30
                        //       //             ? item!.excerpt.length
                        //       //             : 30),
                        //       //     maxLines: 1,
                        //       //     style: Theme.of(context).textTheme.caption,
                        //       //   ),
                        //       // ),
                        //       if (item!.rooms != null) ...[
                        //         Icon(
                        //           Icons.bedroom_parent_outlined,
                        //           size: 20,
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //         const SizedBox(width: 4),
                        //         Expanded(
                        //           child: Text(
                        //             item!.rooms.toString(),
                        //             maxLines: 1,
                        //             style: Theme.of(context).textTheme.caption,
                        //           ),
                        //         ),
                        //       ],
                        //       if (item!.baths != null) ...[
                        //         Icon(
                        //           Icons.bathroom_outlined,
                        //           size: 20,
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //         const SizedBox(width: 4),
                        //         Expanded(
                        //           child: Text(
                        //             item!.baths.toString(),
                        //             maxLines: 1,
                        //             style: Theme.of(context).textTheme.caption,
                        //           ),
                        //         )
                        //       ],
                        //     ])
                      ],
                    ),
                  )
                ],
              ),
              if (AppLanguage.isRTL())
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Icon(
                    item!.favorite ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (!AppLanguage.isRTL())
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    item!.favorite ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).primaryColor,
                  ),
                )
            ],
          ),
        );

      ///Mode View Block
      case ProductViewType.block:
        if (item == null) {
          return AppPlaceholder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 200,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: item!.image.replaceAll("TYPE", "full"),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xff000000),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              item!.statusText.isNotEmpty
                                  ? AppTag(
                                      item!.statusText,
                                      type: TagType.status,
                                    )
                                  : Container(),
                              Icon(
                                item!.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                const SizedBox(width: 8),
                                                Text(
                                                  getPrice(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            )
                                          ]),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              AppTag(
                                                "${item!.rate}",
                                                type: TagType.rate,
                                              ),
                                              const SizedBox(width: 4),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Text(
                                                      Translate.of(context)
                                                          .translate(
                                                        'rate',
                                                      ),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption!
                                                          .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                  RatingBar.builder(
                                                    initialRating: item!.rate,
                                                    minRating: 1,
                                                    allowHalfRating: true,
                                                    unratedColor: Colors.amber
                                                        .withAlpha(100),
                                                    itemCount: 5,
                                                    itemSize: 14.0,
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rate) {},
                                                    ignoreGestures: true,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Text(
                                            "${item!.numRate} ${Translate.of(context).translate('feedback')}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ]))
                      ],
                    ),
                  );
                },
                placeholder: (context, url) {
                  return AppPlaceholder(
                    child: Container(
                      height: 200,
                      color: Colors.white,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return AppPlaceholder(
                    child: Container(
                      height: 200,
                      color: Colors.white,
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Text(
                      item?.category?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item!.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${item!.state?.name}, ${item!.city?.name}, ${item!.extendedAttributes.singleWhere((e) => e.key == "address").text}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.timelapse,
                          size: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${item!.timeElapsed}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (item!.extendedAttributes.any(
                              (e) => e.key == "area" && e.double_ != null)) ...[
                            Icon(
                              UtilIcon.getIconFromCss("fas fa-maximize"),
                              size: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "area")
                                    .double_
                                    .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                          // Icon(
                          //   Icons.layers_outlined,
                          //   size: 15,
                          //   color: Theme.of(context).primaryColor,
                          // ),
                          // const SizedBox(width: 4),
                          // Expanded(
                          //   child: Text(
                          //     item!.excerpt.substring(
                          //         0,
                          //         item!.excerpt.length < 30
                          //             ? item!.excerpt.length
                          //             : 30),
                          //     maxLines: 1,
                          //     style: Theme.of(context).textTheme.caption,
                          //   ),
                          // ),
                          if (item!.extendedAttributes.any((e) =>
                              e.key == "rooms" && e.integer != null)) ...[
                            Icon(
                              Icons.bedroom_parent_outlined,
                              size: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "rooms")
                                    .integer
                                    .toString(),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                          if (item!.extendedAttributes.any((e) =>
                              e.key == "baths" && e.integer != null)) ...[
                            Icon(
                              Icons.bathroom_outlined,
                              size: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item!.extendedAttributes
                                    .singleWhere((e) => e.key == "baths")
                                    .integer
                                    .toString(),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            )
                          ],
                        ])
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );

      ///Case View Card small
      case ProductViewType.card:
        if (item == null) {
          return SizedBox(
            width: 110,
            child: AppPlaceholder(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white,
                  )
                ],
              ),
            ),
          );
        }
        return SizedBox(
          width: 110,
          child: GestureDetector(
            onTap: onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(0),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: item!.image.replaceAll("TYPE", "thumb"),
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      placeholder: (context, url) {
                        return AppPlaceholder(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    item!.name,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        );

      default:
        return Container(width: 160.0);
    }
  }
}
