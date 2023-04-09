import 'package:akarak/configs/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/configs/application.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SectionAItem extends StatelessWidget {
  const SectionAItem({
    Key? key,
    this.item,
    this.onPressed,
  }) : super(key: key);

  final dynamic item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 160,
              child: AppPlaceholder(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 150,
              height: 20,
              child: AppPlaceholder(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 120,
              height: 20,
              child: AppPlaceholder(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onPressed,
            child: Stack(
              alignment:
                  AppLanguage.isRTL() ? Alignment.topLeft : Alignment.topRight,
              children: [
                CachedNetworkImage(
                  imageUrl: item!['image'],
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      constraints:
                          const BoxConstraints(maxHeight: 160, maxWidth: 150),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        // borderRadius: const BorderRadius.all(
                        //   Radius.circular(8),
                        // ),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      // child: Image(
                      //   image: imageProvider,
                      //   fit: BoxFit.fill,
                      // ),
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
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(
                      item!['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              item!['name'],
              // style: Theme.of(context)
              //     .textTheme
              //     .subtitle2!
              //     .copyWith(fontWeight: FontWeight.bold),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: Row(
              children: [
                Text(
                  item!['price'],
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(width: 4),
                Text(
                  item!['currency'],
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          if (item!['discount'] > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: Wrap(
                children: [
                  Text(item!['priceBeforDiscount'],
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      Text(
                        Translate.of(context).translate('descount'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        '${item!['discount']}%',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: Row(
              children: [
                AppTag(
                  item!['rate'] == null ? "0.0" : "${item!['rate']}",
                  type: TagType.rate,
                ),
                const SizedBox(width: 4),
                RatingBar.builder(
                  initialRating: item!['rate'] ?? 0.0,
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
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 2),
          //   child: Text(
          //     item!['content'],
          //     style: Theme.of(context).textTheme.subtitle2,
          //   ),
          // )
        ],
      ),
    );
  }
}
