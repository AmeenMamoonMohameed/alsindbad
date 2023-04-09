import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/widgets/app_placeholder.dart';

import '../../configs/application.dart';

class HomeCategoryItem extends StatelessWidget {
  final CategoryModel? item;
  final Function(CategoryModel)? onPressed;

  const HomeCategoryItem({
    Key? key,
    this.item,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return AppPlaceholder(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.21,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: 48,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.21,
      child: GestureDetector(
        onTap: () => onPressed!(item!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item!.color,
              ),
              child: item!.id != -1
                  ? CachedNetworkImage(
                      imageUrl: item!.icon != null
                          ? Application.domain +
                              item!.iconUrl!
                                  .replaceAll("\\", "/")
                                  .replaceAll("TYPE", "full")
                          : '',
                      color: item!.color,
                      colorBlendMode: BlendMode.color,
                      filterQuality: FilterQuality.high,
                      width: 20,
                      height: 20,
                    )
                  : const FaIcon(
                      Icons.more_horiz_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
              // child: Image.network(item!.icon != null
              //     ? Application.domain +
              //         item!.iconUrl!
              //             .replaceAll("\\", "/")
              //             .replaceAll("TYPE", "thumb")
              //     : ''),
              // child: FaIcon(
              //   item!.icon,
              //   size: 18,
              //   color: Colors.white,
              // ),
            ),
            const SizedBox(height: 4),
            Text(
              item!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.button!.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
