import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/repository/address_repository.dart';
import 'package:akarak/utils/other.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/shop_item_list.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../configs/routes.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({Key? key}) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => const ShoppingCartChild(),
        ),
      ),
    );
  }
}

class ShoppingCartChild extends StatefulWidget {
  const ShoppingCartChild({Key? key}) : super(key: key);

  @override
  _ShoppingCartChildState createState() => _ShoppingCartChildState();
}

class _ShoppingCartChildState extends State<ShoppingCartChild> {
  SwiperController swiperController = SwiperController();
  final orderListCubit = OrderListCubit();

  @override
  void initState() {
    super.initState();
    orderListCubit.onLoadDetail();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
    //           _slidableItemKey,
    //           // _cartIndicatorKey,
    //           // _nameKey,
    //           // _searchKey,
    //           // _categoriesKey
    //         ]));
  }

  @override
  void dispose() {
    orderListCubit.close();
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget shoppingCartButton = InkWell(
      onTap: () async {},
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: BoxDecoration(
            gradient: mainButton,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                offset: Offset(0, 5),
                blurRadius: 10.0,
              )
            ],
            borderRadius: BorderRadius.circular(9.0)),
        child: Center(
          child: Text(Translate.of(context).translate('continue'),
              style: const TextStyle(
                  color: Color(0xfffefefe),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0)),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: BlocProvider(
          create: (context) => orderListCubit,
          child: BlocBuilder<OrderListCubit, OrderListState>(
              builder: (context, state) {
            Widget content = AppPlaceholder(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Card(
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5,
                          right: AppLanguage.isRTL() ? 10 : 0,
                          left: AppLanguage.isRTL() ? 0 : 10),
                      child: Wrap(
                        children: [
                          Container(
                            height: 15,
                            width: 30,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 15,
                            width: 30,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 15,
                            width: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );

            if (state is OrderDetailsSuccess) {
              // content Unpaid
              content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.incompleteOrderList);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        height: 48.0,
                        color: red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              Translate.of(context).translate(
                                  'click_here_to_complete_unpaid_orders'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]);

              // content
              if (state.orderDetails != null) {
                shoppingCartButton = InkWell(
                  onTap: () async {

                    final result = await orderListCubit.onInitOrder(
                        list: state.orderDetails!.orderItems);
                    if (result) {
                      Navigator.pushReplacementNamed(context, Routes.checkOut,
                          arguments: state.orderDetails!.orderId);
                    }

                    // Navigator.pushNamed(context, Routes.shippingCart,
                    //     arguments: state.orderDetails);
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                        gradient: mainButton,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.16),
                            offset: Offset(0, 5),
                            blurRadius: 10.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(9.0)),
                    child: Center(
                      child: Text(Translate.of(context).translate('continue'),
                          style: const TextStyle(
                              color: Color(0xfffefefe),
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0)),
                    ),
                  ),
                );

                // content
                content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      height: 48.0,
                      color: yellow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            Translate.of(context).translate('subtotal'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            AppLanguage.isRTL()
                                ? '${Translate.of(context).translate('items')}: ${state.orderDetails?.orderItems.length ?? 0}'
                                : '${state.orderDetails?.orderItems.length ?? 0} :${Translate.of(context).translate('items')}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                    if (state.hasUnpaidOrders)
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.incompleteOrderList);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          height: 48.0,
                          color: red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                Translate.of(context).translate(
                                    'click_here_to_complete_unpaid_orders'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Scrollbar(
                        child: state.orderDetails != null &&
                                state.orderDetails!.orderItems.isNotEmpty
                            ? ListView.builder(
                                itemBuilder: (_, index) => ShopItemList(
                                  state.orderDetails!.orderItems[index],
                                  isShowCase: index == 0,
                                  onChangeQuantity: (int quantity) {
                                    state.orderDetails!.orderItems[index]
                                        .quantity = quantity;
                                  },
                                  onRemove: () {
                                    UtilOther.showMessage(
                                      context: context,
                                      title: Translate.of(context)
                                          .translate('_confirm'),
                                      message: Translate.of(context).translate(
                                          'confirm_the_removal_of_the_product_from_the_shopping_cart'),
                                      func: () {
                                        Navigator.pop(context);
                                        orderListCubit.onCancelItem(
                                            state.orderDetails!
                                                .orderItems[index].orderId,
                                            state.orderDetails!
                                                .orderItems[index].id);
                                      },
                                      funcName: Translate.of(context)
                                          .translate('confirm'),
                                    );
                                  },
                                ),
                                itemCount:
                                    state.orderDetails!.orderItems.length,
                              )
                            : Container(),
                      ),
                    ),
                  ],
                );
              }
              return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    iconTheme: const IconThemeData(color: darkGrey),
                    actions: const <Widget>[],
                    title: Text(
                      Translate.of(context).translate('shopping_cart'),
                      style: const TextStyle(
                          color: darkGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0),
                    ),
                  ),
                  body: LayoutBuilder(
                    builder: (_, constraints) => SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: content),
                    ),
                  ),
                  bottomNavigationBar: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.1),
                    // color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: orderListCubit.state is OrderDetailsSuccess &&
                                  (orderListCubit.state as OrderDetailsSuccess)
                                          .orderDetails !=
                                      null
                              ? shoppingCartButton
                              : Container(),
                        ),
                      ),
                    ),
                  ));
            }

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme: const IconThemeData(color: darkGrey),
                actions: const <Widget>[],
                title: Text(
                  Translate.of(context).translate('shopping_cart'),
                  style: const TextStyle(
                      color: darkGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0),
                ),
              ),
              body: LayoutBuilder(
                builder: (_, constraints) => SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: content
                      // Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       InkWell(
                      //         onTap: () {
                      //           Navigator.pushNamed(
                      //               context, Routes.incompleteOrderList);
                      //         },
                      //         child: Container(
                      //           padding:
                      //               const EdgeInsets.symmetric(horizontal: 32.0),
                      //           height: 48.0,
                      //           color: red,
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: <Widget>[
                      //               Text(
                      //                 Translate.of(context).translate(
                      //                     'click_here_to_complete_unpaid_orders'),
                      //                 style: const TextStyle(
                      //                     color: Colors.white,
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: 16),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       )
                      //     ]),
                      ),
                ),
              ),
              bottomNavigationBar: orderListCubit.state
                          is OrderDetailsSuccess &&
                      (orderListCubit.state as OrderDetailsSuccess)
                              .orderDetails !=
                          null
                  ? Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.1),
                      // color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: shoppingCartButton,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            );
          })),
    );
  }
}
