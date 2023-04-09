import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

import '../../app_properties.dart';
import '../../packages/chat/widgets/app_placeholder.dart';
import '../../widgets/app_notification_item.dart';

class Notifications extends StatefulWidget {
  const Notifications({
    Key? key,
  }) : super(key: key);

  @override
  _NotificationsState createState() {
    return _NotificationsState();
  }
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin<Notifications> {
  final _scrollController = ScrollController();
  final _endReachedThreshold = 100;
  final _notificationsCubit = NotificationsCubit();
  List<NotificationModel> _notifications = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _notificationsCubit.onLoad();
  }

  @override
  void dispose() {
    SVProgressHUD.dismiss();
    _scrollController.dispose();
    super.dispose();
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _notificationsCubit.state;
    if (state is NotificationsSuccess &&
        state.canLoadMore &&
        !state.loadingMore) {
      _notificationsCubit.onLoadMore();
    }
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    await _notificationsCubit.onLoad();
  }

  @override
  Widget build(BuildContext context) {
    Widget list = ListView(children: const <Widget>[
      AppNotificationItem(),
      AppNotificationItem(),
      AppNotificationItem(),
      AppNotificationItem(),
      AppNotificationItem(),
      AppNotificationItem(),
    ]);

    return Material(
      color: Colors.grey[100],
      child: SafeArea(
        child: Container(
            margin: const EdgeInsets.only(top: kToolbarHeight),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text(
                    'Notification',
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CloseButton()
                ],
              ),
              Flexible(
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                    bloc: _notificationsCubit,
                    builder: (context, state) {
                      if (state is NotificationsSuccess) {
                        _notifications.addAll(state.list);
                        list = RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              return AppNotificationItem(
                                  item: state.list[index]);
                            },
                            itemCount: state.list.length,
                          ),
                        );

                        // list = ListView(
                        //   children: <Widget>[
                        //     // Request amount
                        //     Container(
                        //       padding: const EdgeInsets.all(16.0),
                        //       margin: const EdgeInsets.symmetric(vertical: 4.0),
                        //       decoration: const BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(5.0))),
                        //       child: Column(
                        //         children: <Widget>[
                        //           Row(
                        //             children: <Widget>[
                        //               const CircleAvatar(
                        //                 backgroundImage: AssetImage(
                        //                   'assets/background.jpg',
                        //                 ),
                        //                 maxRadius: 24,
                        //               ),
                        //               Flexible(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 16.0),
                        //                   child: RichText(
                        //                     text: const TextSpan(
                        //                         style: TextStyle(
                        //                           fontFamily: 'Montserrat',
                        //                           color: Colors.black,
                        //                         ),
                        //                         children: [
                        //                           TextSpan(
                        //                               text: 'Sai Sankar Ram',
                        //                               style: TextStyle(
                        //                                 fontWeight:
                        //                                     FontWeight.bold,
                        //                               )),
                        //                           TextSpan(
                        //                             text: ' Requested for ',
                        //                           ),
                        //                           TextSpan(
                        //                             text: '\$45.25',
                        //                             style: TextStyle(
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           )
                        //                         ]),
                        //                   ),
                        //                 ),
                        //               )
                        //             ],
                        //           ),
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: <Widget>[
                        //               Row(
                        //                 children: <Widget>[
                        //                   Icon(
                        //                     Icons.check_circle,
                        //                     size: 14,
                        //                     color: Colors.blue[700],
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.symmetric(
                        //                         horizontal: 8.0),
                        //                     child: Text('Pay',
                        //                         style: TextStyle(
                        //                             color: Colors.blue[700])),
                        //                   )
                        //                 ],
                        //               ),
                        //               Row(
                        //                 children: const <Widget>[
                        //                   Icon(
                        //                     Icons.cancel,
                        //                     size: 14,
                        //                     color: Color(0xffF94D4D),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.symmetric(
                        //                         horizontal: 8.0),
                        //                     child: Text('Decline',
                        //                         style: TextStyle(
                        //                             color: Color(0xffF94D4D))),
                        //                   )
                        //                 ],
                        //               ),
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //     // Send amount
                        //     Container(
                        //       margin: const EdgeInsets.symmetric(vertical: 4.0),
                        //       padding: const EdgeInsets.all(16.0),
                        //       decoration: const BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(5.0))),
                        //       child: Column(
                        //         children: <Widget>[
                        //           Row(
                        //             children: <Widget>[
                        //               const CircleAvatar(
                        //                 backgroundImage: AssetImage(
                        //                   'assets/background.jpg',
                        //                 ),
                        //                 maxRadius: 24,
                        //               ),
                        //               Flexible(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 16.0),
                        //                   child: RichText(
                        //                     text: const TextSpan(
                        //                         style: TextStyle(
                        //                           fontFamily: 'Montserrat',
                        //                           color: Colors.black,
                        //                         ),
                        //                         children: [
                        //                           TextSpan(
                        //                               text: 'Sai Sankar Ram',
                        //                               style: TextStyle(
                        //                                 fontWeight:
                        //                                     FontWeight.bold,
                        //                               )),
                        //                           TextSpan(
                        //                             text: ' Send You ',
                        //                           ),
                        //                           TextSpan(
                        //                             text: '\$45.25',
                        //                             style: TextStyle(
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           )
                        //                         ]),
                        //                   ),
                        //                 ),
                        //               )
                        //             ],
                        //           ),
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: <Widget>[
                        //               Row(
                        //                 children: <Widget>[
                        //                   Icon(
                        //                     Icons.check_circle,
                        //                     size: 14,
                        //                     color: Colors.blue[700],
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.symmetric(
                        //                         horizontal: 8.0),
                        //                     child: Text('Accept',
                        //                         style: TextStyle(
                        //                             color: Colors.blue[700])),
                        //                   )
                        //                 ],
                        //               ),
                        //               Row(
                        //                 children: const <Widget>[
                        //                   Icon(
                        //                     Icons.cancel,
                        //                     size: 14,
                        //                     color: Color(0xffF94D4D),
                        //                   ),
                        //                   Padding(
                        //                     padding: EdgeInsets.symmetric(
                        //                         horizontal: 8.0),
                        //                     child: Text('Decline',
                        //                         style: TextStyle(
                        //                             color: Color(0xffF94D4D))),
                        //                   )
                        //                 ],
                        //               ),
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //     // Share your feedback.
                        //     Container(
                        //       margin: const EdgeInsets.symmetric(vertical: 4.0),
                        //       decoration: const BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(5.0))),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.stretch,
                        //         children: <Widget>[
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Row(children: [
                        //               SizedBox(
                        //                 height: 110,
                        //                 width: 110,
                        //                 child: Stack(children: <Widget>[
                        //                   Positioned(
                        //                     left: 5.0,
                        //                     bottom: -10.0,
                        //                     child: SizedBox(
                        //                       height: 100,
                        //                       width: 100,
                        //                       child: Transform.scale(
                        //                         scale: 1.2,
                        //                         child: CachedNetworkImage(
                        //                           imageUrl:
                        //                               'assets/bottom_yellow.png',
                        //                           imageBuilder:
                        //                               (context, imageProvider) {
                        //                             return Container(
                        //                               constraints:
                        //                                   const BoxConstraints(
                        //                                       minHeight: 60,
                        //                                       minWidth: 60),
                        //                               // width: 60,
                        //                               // height: 60,
                        //                               decoration: BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 shape:
                        //                                     BoxShape.rectangle,
                        //                                 image: DecorationImage(
                        //                                   image: imageProvider,
                        //                                   fit: BoxFit.fitWidth,
                        //                                 ),
                        //                                 borderRadius:
                        //                                     BorderRadius.only(
                        //                                   topLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   topRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                   bottomLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   bottomRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           placeholder: (context, url) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           errorWidget:
                        //                               (context, url, error) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                                 child: const Icon(
                        //                                     Icons.error),
                        //                               ),
                        //                             );
                        //                           },
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                   Positioned(
                        //                     top: 8.0,
                        //                     left: 10.0,
                        //                     child: SizedBox(
                        //                       height: 80,
                        //                       width: 80,
                        //                       child: CachedNetworkImage(
                        //                         imageUrl:
                        //                             'assets/headphones.png',
                        //                         imageBuilder:
                        //                             (context, imageProvider) {
                        //                           return Container(
                        //                             constraints:
                        //                                 const BoxConstraints(
                        //                                     minHeight: 60,
                        //                                     minWidth: 60),
                        //                             // width: 60,
                        //                             // height: 60,
                        //                             decoration: BoxDecoration(
                        //                               color: Colors.white,
                        //                               shape: BoxShape.rectangle,
                        //                               image: DecorationImage(
                        //                                 image: imageProvider,
                        //                                 fit: BoxFit.fitWidth,
                        //                               ),
                        //                               borderRadius:
                        //                                   BorderRadius.only(
                        //                                 topLeft:
                        //                                     Radius.circular(
                        //                                         AppLanguage
                        //                                                 .isRTL()
                        //                                             ? 0
                        //                                             : 5),
                        //                                 topRight:
                        //                                     Radius.circular(
                        //                                         AppLanguage
                        //                                                 .isRTL()
                        //                                             ? 5
                        //                                             : 0),
                        //                                 bottomLeft:
                        //                                     Radius.circular(
                        //                                         AppLanguage
                        //                                                 .isRTL()
                        //                                             ? 0
                        //                                             : 5),
                        //                                 bottomRight:
                        //                                     Radius.circular(
                        //                                         AppLanguage
                        //                                                 .isRTL()
                        //                                             ? 5
                        //                                             : 0),
                        //                               ),
                        //                             ),
                        //                           );
                        //                         },
                        //                         placeholder: (context, url) {
                        //                           return AppPlaceholder(
                        //                             child: Container(
                        //                               constraints:
                        //                                   const BoxConstraints(
                        //                                       minHeight: 60,
                        //                                       minWidth: 60),
                        //                               // width: 60,
                        //                               // height: 60,
                        //                               decoration:
                        //                                   const BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 shape:
                        //                                     BoxShape.rectangle,
                        //                               ),
                        //                             ),
                        //                           );
                        //                         },
                        //                         errorWidget:
                        //                             (context, url, error) {
                        //                           return AppPlaceholder(
                        //                             child: Container(
                        //                               constraints:
                        //                                   const BoxConstraints(
                        //                                       minHeight: 60,
                        //                                       minWidth: 60),
                        //                               // width: 60,
                        //                               // height: 60,
                        //                               decoration:
                        //                                   const BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 shape:
                        //                                     BoxShape.rectangle,
                        //                               ),
                        //                               child: const Icon(
                        //                                   Icons.error),
                        //                             ),
                        //                           );
                        //                         },
                        //                       ),
                        //                     ),
                        //                   )
                        //                 ]),
                        //               ),
                        //               Flexible(
                        //                 child: Column(children: const [
                        //                   Text(
                        //                       'Boat Rockerz 350 On-Ear Bluetooth Headphones',
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize: 10)),
                        //                   SizedBox(height: 4.0),
                        //                   Padding(
                        //                     padding: EdgeInsets.symmetric(
                        //                         horizontal: 5),
                        //                     child: Text(
                        //                         'Your package has been delivered. Thanks for shopping!',
                        //                         style: TextStyle(
                        //                             color: Colors.grey,
                        //                             fontSize: 10)),
                        //                   ),
                        //                 ]),
                        //               )
                        //             ]),
                        //           ),
                        //           InkWell(
                        //             onTap: () => Navigator.of(context)
                        //                 .push(MaterialPageRoute(builder: (_) {
                        //               return Container();
                        //             })),
                        //             child: Container(
                        //                 padding: const EdgeInsets.all(14.0),
                        //                 decoration: const BoxDecoration(
                        //                     color: yellow,
                        //                     borderRadius: BorderRadius.only(
                        //                         bottomRight:
                        //                             Radius.circular(5.0),
                        //                         bottomLeft:
                        //                             Radius.circular(5.0))),
                        //                 child: const Align(
                        //                     alignment: Alignment.centerRight,
                        //                     child: Text(
                        //                       'Share your feedback',
                        //                       style: TextStyle(
                        //                           color: Colors.white,
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize: 10),
                        //                     ))),
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //     // Track the product.
                        //     Container(
                        //       margin: const EdgeInsets.symmetric(vertical: 4.0),
                        //       decoration: const BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(5.0))),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.stretch,
                        //         children: <Widget>[
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Row(children: [
                        //               SizedBox(
                        //                 height: 110,
                        //                 width: 110,
                        //                 child: Stack(children: <Widget>[
                        //                   Positioned(
                        //                     left: 5.0,
                        //                     bottom: -10.0,
                        //                     child: SizedBox(
                        //                       height: 100,
                        //                       width: 100,
                        //                       child: Transform.scale(
                        //                         scale: 1.2,
                        //                         child: CachedNetworkImage(
                        //                           imageUrl:
                        //                               'assets/bottom_yellow.png',
                        //                           imageBuilder:
                        //                               (context, imageProvider) {
                        //                             return Container(
                        //                               constraints:
                        //                                   const BoxConstraints(
                        //                                       minHeight: 60,
                        //                                       minWidth: 60),
                        //                               // width: 60,
                        //                               // height: 60,
                        //                               decoration: BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 shape:
                        //                                     BoxShape.rectangle,
                        //                                 image: DecorationImage(
                        //                                   image: imageProvider,
                        //                                   fit: BoxFit.fitWidth,
                        //                                 ),
                        //                                 borderRadius:
                        //                                     BorderRadius.only(
                        //                                   topLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   topRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                   bottomLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   bottomRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           placeholder: (context, url) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           errorWidget:
                        //                               (context, url, error) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                                 child: const Icon(
                        //                                     Icons.error),
                        //                               ),
                        //                             );
                        //                           },
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                   Positioned(
                        //                       top: 8.0,
                        //                       left: 10.0,
                        //                       child: SizedBox(
                        //                         height: 80,
                        //                         width: 80,
                        //                         child: CachedNetworkImage(
                        //                           imageUrl:
                        //                               'assets/headphones.png',
                        //                           imageBuilder:
                        //                               (context, imageProvider) {
                        //                             return Container(
                        //                               constraints:
                        //                                   const BoxConstraints(
                        //                                       minHeight: 60,
                        //                                       minWidth: 60),
                        //                               // width: 60,
                        //                               // height: 60,
                        //                               decoration: BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 shape:
                        //                                     BoxShape.rectangle,
                        //                                 image: DecorationImage(
                        //                                   image: imageProvider,
                        //                                   fit: BoxFit.fitWidth,
                        //                                 ),
                        //                                 borderRadius:
                        //                                     BorderRadius.only(
                        //                                   topLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   topRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                   bottomLeft:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 0
                        //                                               : 5),
                        //                                   bottomRight:
                        //                                       Radius.circular(
                        //                                           AppLanguage
                        //                                                   .isRTL()
                        //                                               ? 5
                        //                                               : 0),
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           placeholder: (context, url) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                               ),
                        //                             );
                        //                           },
                        //                           errorWidget:
                        //                               (context, url, error) {
                        //                             return AppPlaceholder(
                        //                               child: Container(
                        //                                 constraints:
                        //                                     const BoxConstraints(
                        //                                         minHeight: 60,
                        //                                         minWidth: 60),
                        //                                 // width: 60,
                        //                                 // height: 60,
                        //                                 decoration:
                        //                                     const BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   shape: BoxShape
                        //                                       .rectangle,
                        //                                 ),
                        //                                 child: const Icon(
                        //                                     Icons.error),
                        //                               ),
                        //                             );
                        //                           },
                        //                         ),
                        //                       )),
                        //                 ]),
                        //               ),
                        //               Flexible(
                        //                 child: Column(children: const [
                        //                   Text(
                        //                       'Boat Rockerz 440 On-Ear Bluetooth Headphones',
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize: 10)),
                        //                   SizedBox(height: 4.0),
                        //                   Padding(
                        //                     padding: EdgeInsets.symmetric(
                        //                         horizontal: 5),
                        //                     child: Text(
                        //                       'Your package has been dispatched. You can keep track of your product.',
                        //                       style: TextStyle(
                        //                           color: Colors.grey,
                        //                           fontSize: 10),
                        //                     ),
                        //                   ),
                        //                 ]),
                        //               )
                        //             ]),
                        //           ),
                        //           InkWell(
                        //             onTap: () => Navigator.of(context)
                        //                 .push(MaterialPageRoute(builder: (_) {
                        //               return Container();
                        //             })),
                        //             child: Container(
                        //                 padding: const EdgeInsets.all(14.0),
                        //                 decoration: const BoxDecoration(
                        //                     color: yellow,
                        //                     borderRadius: BorderRadius.only(
                        //                         bottomRight:
                        //                             Radius.circular(5.0),
                        //                         bottomLeft:
                        //                             Radius.circular(5.0))),
                        //                 child: const Align(
                        //                     alignment: Alignment.centerRight,
                        //                     child: Text(
                        //                       'Track the product',
                        //                       style: TextStyle(
                        //                           color: Colors.white,
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize: 10),
                        //                     ))),
                        //           )
                        //         ],
                        //       ),
                        //     )
                        //   ],
                        // );

                      }
                      return list;
                    }),
              )
            ])),
      ),
    );
  }
}
