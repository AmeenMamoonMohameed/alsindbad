import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model_order.dart';
import 'package:akarak/repository/order_repository.dart';
import 'package:akarak/utils/other.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/utils/validate.dart';
import 'package:akarak/widgets/shop_item_list.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../widgets/widget.dart';

class OrderItemList extends StatefulWidget {
  final RouteArguments arguments;
  const OrderItemList({Key? key, required this.arguments}) : super(key: key);

  @override
  _OrderItemListState createState() => _OrderItemListState();
}

class _OrderItemListState extends State<OrderItemList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => OrderItemListChild(
            arguments: widget.arguments,
          ),
        ),
      ),
    );
  }
}

class OrderItemListChild extends StatefulWidget {
  final RouteArguments arguments;
  const OrderItemListChild({Key? key, required this.arguments})
      : super(key: key);

  @override
  _OrderItemListChildState createState() => _OrderItemListChildState();
}

class _OrderItemListChildState extends State<OrderItemListChild> {
  SwiperController swiperController = SwiperController();
  final orderListCubit = OrderListCubit();
  // final GlobalKey _slidableItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    orderListCubit.onLoadDetail(id: widget.arguments.item);
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

  ///On Return
  void _onReturn(
    BuildContext context_,
    int orderItemId,
  ) async {
    String? errorDescription;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? because;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('confirm_return_request'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context).translate('reason_for_return'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 10,
                  errorText: errorDescription,
                  hintText: errorDescription ??
                      Translate.of(context)
                          .translate('why_do_you_want_to_return'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      because = text;
                      errorDescription =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () async {
                errorDescription =
                    UtilValidator.validate(because ?? "", allowEmpty: false);
                setState(() {});
                if (errorDescription == null) {
                  Navigator.pop(context, because);
                  final result = await OrderRepository.refundRequest(
                      orderItemId: orderItemId, because: because!);
                  if (result) {
                    orderListCubit.onLoadDetail(id: widget.arguments.item);
                    AppBloc.messageCubit.onShow(Translate.of(context_).translate(
                        'dear_customer_the_return_request_has_been_sent_to_the_merchant_In_the_event_that_you_do_not_respond_within_day_please_file_complaint'));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  ///On complaint
  void _onComplaint(
    BuildContext context_,
    int orderId,
  ) async {
    String? errorDescription;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? txt;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('complaint'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('please_write_the_complaint_in_detail'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 10,
                  errorText: errorDescription,
                  hintText: errorDescription ??
                      Translate.of(context)
                          .translate('the_text_of_the_complaint'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      txt = text;
                      errorDescription =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () async {
                errorDescription =
                    UtilValidator.validate(txt ?? "", allowEmpty: false);
                setState(() {});
                if (errorDescription == null) {
                  Navigator.pop(context, txt);
                  final result = await OrderRepository.complaint(
                      orderItemId: 1, txt: txt!);
                  if (result) {
                    orderListCubit.onLoadDetail(id: widget.arguments.item);
                    AppBloc.messageCubit.onShow(Translate.of(context_).translate(
                        'dear_customer_a_new_complaint_has_been_opened_our_team_will_contact_you_Thank_you'));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
                if (state.orderDetails != null &&
                    state.orderDetails!.orderItems.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    color: Theme.of(context).colorScheme.tertiary,
                    child: Scrollbar(
                        child: ListView.builder(
                      itemBuilder: (_, index) => OrderItem(
                        state.orderDetails!.orderItems[index],
                        isShowCase: index == 0,
                        onChangeQuantity: (int quantity) {
                          state.orderDetails!.orderItems[index].quantity =
                              quantity;
                        },
                        onRemove: () {
                          UtilOther.showMessage(
                            context: context,
                            title: Translate.of(context).translate('_confirm'),
                            message: Translate.of(context).translate(
                                'confirm_product_removal_from_order'),
                            func: () {
                              Navigator.pop(context);
                              orderListCubit.onCancelItem(
                                  state.orderDetails!.orderItems[index].orderId,
                                  state.orderDetails!.orderItems[index].id);
                            },
                            funcName:
                                Translate.of(context).translate('confirm'),
                          );
                        },
                        onReturn: () {
                          UtilOther.hiddenKeyboard(context);
                          if (state.orderDetails!.orderItems[index]
                              .hasRefundRequest) {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context).translate(
                                'dear_customer_are_you_sure_to_cancel_the_return_request',
                              ),
                              func: () {
                                Navigator.pop(context);
                                OrderRepository.cancelRefundRequest(
                                        orderItemId: state
                                            .orderDetails!.orderItems[index].id)
                                    .then((value) {
                                  if (value) {
                                    orderListCubit.onLoadDetail(
                                        id: widget.arguments.item);
                                  }
                                });
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          } else {
                            _onReturn(context,
                                state.orderDetails!.orderItems[index].id);
                          }
                        },
                        onComplaint: () {
                          UtilOther.hiddenKeyboard(context);
                          if (state.orderDetails!.orderItems[index]
                              .hasOpenComplaint) {
                            UtilOther.showMessage(
                              context: context,
                              title:
                                  Translate.of(context).translate('_confirm'),
                              message: Translate.of(context).translate(
                                'dear_customer_are_you_sure_you_want_to_close_the_complaint',
                              ),
                              func: () {
                                Navigator.pop(context);
                                OrderRepository.closeComplaint(
                                        orderItemId: state
                                            .orderDetails!.orderItems[index].id)
                                    .then((value) {
                                  if (value) {
                                    orderListCubit.onLoadDetail(
                                        id: widget.arguments.item);
                                  }
                                });
                              },
                              funcName:
                                  Translate.of(context).translate('confirm'),
                            );
                          } else {
                            _onComplaint(context,
                                state.orderDetails!.orderItems[index].id);
                          }
                        },
                        hasOperations: widget.arguments.hasOperations,
                      ),
                      itemCount: state.orderDetails!.orderItems.length,
                    )),
                  ),
                // const SizedBox(height: 24),
              ],
            );
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme: const IconThemeData(color: darkGrey),
                actions: const <Widget>[
                  // IconButton(
                  //   icon: Image.asset(Images.commercialInvoices),
                  //   onPressed: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       Routes.orderDetail,
                  //       arguments: widget.arguments,
                  //     );
                  //   },
                  //   // onPressed: () => Navigator.of(context)
                  //   //     .push(MaterialPageRoute(builder: (_) => UnpaidPage())),
                  // )
                ],
                title: Text(
                  '${Translate.of(context).translate('order_items')} - (${widget.arguments.item})',
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
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              iconTheme: const IconThemeData(color: darkGrey),
              actions: const <Widget>[
                // IconButton(
                //   icon: Image.asset(Images.commercialInvoices),
                //   onPressed: () {
                //     Navigator.pushNamed(
                //       context,
                //       Routes.orderDetail,
                //       arguments: widget.arguments,
                //     );
                //   },
                //   // onPressed: () => Navigator.of(context)
                //   //     .push(MaterialPageRoute(builder: (_) => UnpaidPage())),
                // )
              ],
              title: Text(
                Translate.of(context).translate('order_items'),
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
          );
        }));
  }
}
