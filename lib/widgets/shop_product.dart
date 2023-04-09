// ignore_for_file: unnecessary_string_interpolations

import 'package:akarak/app_properties.dart';
import 'package:akarak/configs/application.dart';
import 'package:akarak/configs/language.dart';
import 'package:akarak/models/model_product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/model.dart';

class ShopProduct extends StatelessWidget {
  final OrderItemModel product;
  final VoidCallback onRemove;

  const ShopProduct(
    this.product, {
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
          children: <Widget>[
            // ShopProductDisplay(
            //   product,
            //   onPressed: onRemove,
            // ),
            CachedNetworkImage(
              imageUrl: Application.domain +
                  product.image
                      .replaceAll("\\", "/")
                      .replaceAll("TYPE", "full"),
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
              color: Colors.transparent,
              colorBlendMode: BlendMode.color,
              filterQuality: FilterQuality.high,
              width: 20,
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkGrey,
                ),
              ),
            ),
            Text(
              '\$${product.totalPrice}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: darkGrey, fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ],
        ));
  }
}

class ShopProductDisplay extends StatelessWidget {
  final OrderItemModel product;
  final VoidCallback onPressed;

  const ShopProductDisplay(this.product, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(children: <Widget>[
        Positioned(
          left: AppLanguage.isRTL() ? null : 25,
          right: AppLanguage.isRTL() ? 25 : null,
          bottom: -5,
          child: SizedBox(
            height: 150,
            width: 120,
            child: Transform.scale(
              scale: 1.2,
              child: Image.asset('assets/images/bottom_yellow.png'),
            ),
          ),
        ),
        Positioned(
          left: AppLanguage.isRTL() ? null : 20,
          right: AppLanguage.isRTL() ? 20 : null,
          top: 10,
          child: SizedBox(
            height: 80,
            width: 80,
            child: CachedNetworkImage(
              imageUrl: product.image != null
                  ? Application.domain +
                      product.image
                          .replaceAll("\\", "/")
                          .replaceAll("TYPE", "full")
                  : '',
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
              color: Colors.transparent,
              colorBlendMode: BlendMode.color,
              filterQuality: FilterQuality.high,
              width: 20,
              height: 20,
            ),
          ),
        ),
        // Positioned(
        //   right: AppLanguage.isRTL() ? null : 30,
        //   left: AppLanguage.isRTL() ? 30 : null,
        //   bottom: 25,
        //   child: Align(
        //     child: IconButton(
        //       icon: Image.asset('assets/icons/red_clear.png'),
        //       onPressed: onPressed,
        //     ),
        //   ),
        // )
      ]),
    );
  }
}
