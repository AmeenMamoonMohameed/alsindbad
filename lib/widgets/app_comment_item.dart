import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../blocs/app_bloc.dart';
import '../configs/application.dart';
import '../configs/image.dart';
import '../configs/language.dart';
import '../configs/routes.dart';

// class WishList extends StatefulWidget {

// }

// class AppCItem extends State<WishList> {
// {
//   late StreamSubscription _submitSubscription;
//   late StreamSubscription _reviewSubscription;
//   final _scrollController = ScrollController();
//   final _endReachedThreshold = 500;

// }
class AppCommentItem extends StatelessWidget {
  // final int? productId;
  final CommentModel? item;
  final bool? showProductName;

  final VoidCallback? onPressUser;
  final Future<void> Function(CommentModel item, BuildContext context)?
      onAction;
  // final AsyncCallback Function() callback;
  const AppCommentItem(
      {Key? key,
      this.item,
      this.onPressUser,
      this.showProductName,
      this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return AppPlaceholder(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                height: 10,
                                width: 100,
                                color: Colors.white,
                              ),
                              Container(
                                height: 10,
                                width: 50,
                                color: Colors.white,
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 50,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              )
            ],
          ),
        ),
      );
    }

// Replay
    List<Widget> replaies = [];
    if (item != null && item!.replaies != null) {
      replaies = item!.replaies!.map((itemReplay) {
        return Column(children: [
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(-5, 0),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: onPressUser,
                      child: itemReplay.createdBy.profilePictureDataUrl.isEmpty
                          ? Image.asset(
                              Images.user,
                              height: 48,
                              width: 48,
                            )
                          : CachedNetworkImage(
                              imageUrl: Application.domain +
                                  itemReplay.createdBy.profilePictureDataUrl
                                      .replaceAll("\\", "/")
                                      .replaceAll("TYPE", "thumb"),
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
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
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return AppPlaceholder(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(Icons.error),
                                  ),
                                );
                              },
                            ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemReplay.createdBy.accountName,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xff3a5ba0)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          itemReplay.createdOn.dateView,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        )
                                      ]),
                                ),
                                if (AppBloc.userCubit.state!.userId ==
                                    itemReplay.createdBy.userId)
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        padding: const EdgeInsets.all(0),
                                        iconSize: 15,
                                        alignment: AppLanguage.isRTL()
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
                                          onAction!(itemReplay, context);
                                        }),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  itemReplay.content,
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          )
        ]);
      }).toList();
    }

// Comment
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: onPressUser,
                  child: item!.createdBy.profilePictureDataUrl.isEmpty
                      ? Image.asset(
                          Images.user,
                          height: 48,
                          width: 48,
                        )
                      : CachedNetworkImage(
                          imageUrl: Application.domain +
                              item!.createdBy.profilePictureDataUrl
                                  .replaceAll("\\", "/")
                                  .replaceAll("TYPE", "thumb"),
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
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
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return AppPlaceholder(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item!.createdBy.accountName,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff3a5ba0)),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: item!.rating,
                                          minRating: 1,
                                          allowHalfRating: true,
                                          unratedColor:
                                              Colors.amber.withAlpha(100),
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
                                        const SizedBox(height: 8),
                                        Text(
                                          item!.createdOn.dateView,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        )
                                      ],
                                    )
                                  ]),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                  padding: const EdgeInsets.all(0),
                                  iconSize: 15,
                                  alignment: AppLanguage.isRTL()
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    onAction!(item!, context);
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item!.content,
              maxLines: 5,
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
      ),
      Column(
        children: replaies,
      )
    ]);
    // return Row(children: [
    //   Container(
    //     padding: const EdgeInsets.all(8),
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).dividerColor,
    //       borderRadius: const BorderRadius.all(
    //         Radius.circular(8),
    //       ),
    //     ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: <Widget>[
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             InkWell(
    //               onTap: onPressUser,
    //               child: CachedNetworkImage(
    //                 imageUrl: Application.domain +
    //                     item!.createdBy.profilePictureDataUrl.replaceAll("\\", "/")
    //                         .replaceAll("\\", "/"),
    //                 imageBuilder: (context, imageProvider) {
    //                   return Container(
    //                     width: 48,
    //                     height: 48,
    //                     decoration: BoxDecoration(
    //                       shape: BoxShape.circle,
    //                       color: Colors.white,
    //                       image: DecorationImage(
    //                         image: imageProvider,
    //                         fit: BoxFit.cover,
    //                       ),
    //                     ),
    //                   );
    //                 },
    //                 placeholder: (context, url) {
    //                   return AppPlaceholder(
    //                     child: Container(
    //                       width: 48,
    //                       height: 48,
    //                       decoration: const BoxDecoration(
    //                         shape: BoxShape.circle,
    //                         color: Colors.white,
    //                       ),
    //                     ),
    //                   );
    //                 },
    //                 errorWidget: (context, url, error) {
    //                   return AppPlaceholder(
    //                     child: Container(
    //                       width: 48,
    //                       height: 48,
    //                       decoration: const BoxDecoration(
    //                         shape: BoxShape.circle,
    //                         color: Colors.white,
    //                       ),
    //                       child: const Icon(Icons.error),
    //                     ),
    //                   );
    //                 },
    //               ),
    //             ),
    //             // Expanded(
    //             //   child: Container(
    //             //     padding: const EdgeInsets.only(left: 8, right: 8),
    //             //     child: Column(
    //             //       mainAxisAlignment: MainAxisAlignment.center,
    //             //       crossAxisAlignment: CrossAxisAlignment.start,
    //             //       children: <Widget>[
    //             //         Row(
    //             //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             //           children: <Widget>[
    //             //             Expanded(
    //             //               child: Text(
    //             //                 item!.createdBy.accountName,
    //             //                 maxLines: 1,
    //             //                 style: Theme.of(context)
    //             //                     .textTheme
    //             //                     .subtitle2!
    //             //                     .copyWith(fontWeight: FontWeight.bold),
    //             //               ),
    //             //             ),
    //             //             // Expanded(
    //             //             //   child: IconButton(
    //             //             //       iconSize: 15,
    //             //             //       alignment: AppLanguage.isRTL()
    // ? Alignment.centerLeft
    // : Alignment.centerRight,
    //             //             //       icon: const Icon(Icons.more_vert),
    //             //             //       onPressed: () {
    //             //             //         // _onAction(item!, context);
    //             //             //       }),
    //             //             // ),
    //             //           ],
    //             //         ),
    //             //         const SizedBox(height: 2),
    //             //         RatingBar.builder(
    //             //           initialRating: item!.rating,
    //             //           minRating: 1,
    //             //           allowHalfRating: true,
    //             //           unratedColor: Colors.amber.withAlpha(100),
    //             //           itemCount: 5,
    //             //           itemSize: 14.0,
    //             //           itemBuilder: (context, _) => const Icon(
    //             //             Icons.star,
    //             //             color: Colors.amber,
    //             //           ),
    //             //           onRatingUpdate: (rate) {},
    //             //           ignoreGestures: true,
    //             //         ),
    //             //       ],
    //             //     ),
    //             //   ),
    //             // )
    //           ],
    //         ),
    //         const SizedBox(height: 8),
    //         Text(
    //           "kage: sdxv flutter/ascasb  kages/flutter/lib/src/wi",
    //           // item!.content,
    //           maxLines: 5,
    //           style: Theme.of(context).textTheme.bodyText1,
    //         ),
    //         const SizedBox(height: 8),
    //         // Text(
    //         //   item!.createdOn.dateView,
    //         //   style: Theme.of(context).textTheme.caption,
    //         // ),
    //       ],
    //     ),
    //   ),
    //   // Row(
    //   //     // children: replaies,
    //   //     )
    // ]);
  }
}
