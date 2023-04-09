// import 'package:akarak/app_properties.dart';
// import 'package:akarak/configs/language.dart';
// import 'package:akarak/utils/translate.dart';
// import 'package:akarak/widgets/color_list.dart';
// import 'package:akarak/widgets/shop_product.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:akarak/models/model.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:numberpicker/numberpicker.dart';
// import 'package:showcaseview/showcaseview.dart';
// import '../configs/application.dart';

// class ShopItemList extends StatefulWidget {
//   final OrderItemModel product;
//   final VoidCallback onRemove;
//   final Function(int) onChangeQuantity;

//   ShopItemList(this.product,
//       {Key? key, required this.onRemove, required this.onChangeQuantity})
//       : super(key: key);

//   @override
//   _ShopItemListState createState() => _ShopItemListState();
// }

// class _ShopItemListState extends State<ShopItemList> {
//   @override
//   Widget build(BuildContext context) {
//     return ShowCaseWidget(
//       builder: Builder(
//         builder: (context) => ShopItemListChild(
//           widget.product,
//           onRemove: () => widget.onRemove,
//           onChangeQuantity: (int id) => widget.onChangeQuantity,
//         ),
//       ),
//     );
//   }
// }

// class ShopItemListChild extends StatefulWidget {
//   final OrderItemModel orderItem;
//   final VoidCallback onRemove;
//   final Function(int) onChangeQuantity;

//   ShopItemListChild(this.orderItem,
//       {Key? key, required this.onRemove, required this.onChangeQuantity})
//       : super(key: key);

//   @override
//   _ShopItemListChildState createState() => _ShopItemListChildState();
// }

// class _ShopItemListChildState extends State<ShopItemListChild> {
//   final GlobalKey _slidableItemKey = GlobalKey();
//   final GlobalKey _quantityPickerKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
//               _slidableItemKey,
//               _quantityPickerKey,
//               // _cartIndicatorKey,
//               // _nameKey,
//               // _searchKey,
//               // _categoriesKey
//             ]));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 20),
//       child:
//           //  Row(
//           //   children: <Widget>[
//           Showcase(
//         key: _slidableItemKey,
//         onToolTipClick: () {},
//         description: Translate.of(context).translate(
//             'to_display_the_options_drag_the_item_from_left_to_right_and_opposite'),
//         // showcaseBackgroundColor: Colors.yellow[100],
//         descTextStyle: TextStyle(
//             fontWeight: FontWeight.bold, color: Colors.yellowAccent[900]),
//         child: Slidable(
//           key: ValueKey(widget.orderItem.id),
//           endActionPane: ActionPane(
//             motion: const ScrollMotion(),
//             children: [
//               SlidableAction(
//                 flex: 2,
//                 onPressed: (BuildContext? buildContext) {
//                   widget.onRemove();
//                   // setState(() {});
//                 },
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 icon: Icons.cancel,
//                 label: Translate.of(context).translate('remove'),
//               ),
//             ],
//           ),
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16.0),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: shadow,
//               borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(10),
//                   bottomRight: Radius.circular(10)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.only(
//                       top: 5,
//                       bottom: 5,
//                       left: AppLanguage.isRTL() ? 10 : 5,
//                       right: AppLanguage.isRTL() ? 5 : 10),
//                   child: CachedNetworkImage(
//                     imageUrl: widget.orderItem != null
//                         ? Application.domain +
//                             widget.orderItem.image
//                                 .replaceAll("\\", "/")
//                                 .replaceAll("TYPE", "full")
//                         : '',
//                     imageBuilder: (context, imageProvider) {
//                       return Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           image: DecorationImage(
//                             image: imageProvider,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       );
//                     },
//                     color: Colors.transparent,
//                     colorBlendMode: BlendMode.color,
//                     filterQuality: FilterQuality.high,
//                     width: 80,
//                     height: 80,
//                   ),
//                 ),
//                 SizedBox(
//                   width: widget.orderItem.status == OrderStatus.cart
//                       ? MediaQuery.of(context).size.width * 0.5
//                       : MediaQuery.of(context).size.width * 0.6,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         widget.orderItem.title,
//                         textAlign: AppLanguage.isRTL()
//                             ? TextAlign.right
//                             : TextAlign.left,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             color: darkGrey,
//                             overflow: TextOverflow.ellipsis),
//                       ),
//                       Align(
//                         alignment: AppLanguage.isRTL()
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           width: widget.orderItem.status == OrderStatus.cart
//                               ? MediaQuery.of(context).size.width * 0.5
//                               : MediaQuery.of(context).size.width * 0.6,
//                           padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               const ColorOption(Colors.red),
//                               const SizedBox(width: 10),
//                               Text(
//                                 '\$${widget.orderItem.totalDisplay}',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                     color: darkGrey,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18.0,
//                                     overflow: TextOverflow.ellipsis),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Align(
//                     //   alignment: Alignment.center,
//                     //   child: Container(
//                     //     alignment: Alignment.center,
//                     //     constraints: const BoxConstraints(maxWidth: 30),
//                     //     width: 30,
//                     //     child:
//                     // Showcase(
//                     //   titleAlignment: TextAlign.center,
//                     //   key: _quantityPickerKey,
//                     //   description: Translate.of(context).translate(
//                     //       'to_increase_the_quantity_drag_the_numbers_up'),
//                     //   // showcaseBackgroundColor: Colors.yellow[100],
//                     //   descTextStyle: TextStyle(
//                     //       fontWeight: FontWeight.bold,
//                     //       color: Colors.yellowAccent[900]),
//                     //   child:
//                     NumberPicker(
//                       itemHeight: 50,
//                       itemWidth: 50,
//                       value: widget.orderItem.quantity ?? 1,
//                       minValue: 1,
//                       maxValue: 100,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.onChangeQuantity(value);
//                           widget.orderItem.quantity = value;
//                         });
//                       },
//                     ),
//                     // ),
//                     // ),
//                     // ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // Positioned(
//       //   top: 0,
//       //   child:

//       // ),
//       // Positioned(
//       //     top: 5,
//       //     child: ShopProductDisplay(
//       //       widget.product,
//       //       onPressed: widget.onRemove,
//       //     )),
//       //   ],
//       // ),
//     );
//   }
// }
