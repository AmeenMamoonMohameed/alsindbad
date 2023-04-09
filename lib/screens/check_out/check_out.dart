import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/other.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as strip;
import 'package:showcaseview/showcaseview.dart';

import '../../repository/location_repository.dart';

class CheckOut extends StatefulWidget {
  int id;
  CheckOut({Key? key, required this.id}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => CheckOutChild(
            id: widget.id,
          ),
        ),
      ),
    );
  }
}

class CheckOutChild extends StatefulWidget {
  int id;
  CheckOutChild({Key? key, required this.id}) : super(key: key);

  @override
  _CheckOutChildState createState() => _CheckOutChildState();
}

class _CheckOutChildState extends State<CheckOutChild> {
  SwiperController swiperController = SwiperController();
  final orderListCubit = OrderListCubit();
  PaymentType paymentMethod = PaymentType.creditCard;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  ///On Refresh Check Out
  Future<void> _onRefresh() async {
    final defaultAddress = await AddressRepository.loadDefault();
    if (defaultAddress == null) {
      Navigator.pushNamed(context, Routes.addressList, arguments: true)
          .then((value) async {
        if (value is int) {
          orderListCubit
              .onSetShippingAddress(orderId: widget.id, addressId: value)
              .then((value) async {
            if (value) {
              await orderListCubit.onCheckOut(id: widget.id);
            }
          });
        } else {
          Navigator.pop(context);
        }
      });
    } else {
      orderListCubit
          .onSetShippingAddress(
              orderId: widget.id, addressId: defaultAddress.id)
          .then((value) async {
        if (value) {
          await orderListCubit.onCheckOut(id: widget.id);
        }
      });
    }
  }

  // ///On Refresh Check Out
  // Future<void> _onRefresh() async {
  //   orderListCubit.onCheckOut(id: widget.id).then((value) async {
  //     if ((orderListCubit.state is CkeckOutSuccess) &&
  //         (orderListCubit.state as CkeckOutSuccess).checkOut?.address == null) {
  //       final defaultAddress = await AddressRepository.loadDefault();
  //       if (defaultAddress == null) {
  //         Navigator.pushNamed(context, Routes.addressList, arguments: true)
  //             .then((value) async {
  //           if (value is int) {
  //             orderListCubit
  //                 .onSetShippingAddress(orderId: widget.id, addressId: value)
  //                 .then((value) async {
  //               if (value) {
  //                 await orderListCubit.onCheckOut(id: widget.id);
  //               }
  //             });
  //           }
  //         });
  //       } else {
  //         orderListCubit
  //             .onSetShippingAddress(
  //                 orderId: widget.id, addressId: defaultAddress.id)
  //             .then((value) async {
  //           if (value) {
  //             await orderListCubit.onCheckOut(id: widget.id);
  //           }
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  void dispose() {
    orderListCubit.close();
    swiperController.dispose();
    super.dispose();
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      return (await PaymentRepository.createPaymentIntent(
          paymentType: 'order',
          id: widget.id,
          amount: calculateAmount(amount),
          currency: currency,
          paymentMethodType: 'card'));
    } catch (err) {
      //// ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  Future<void> makePayment() async {
    try {
      final clientSecret = await createPaymentIntent('2500', 'USD');
      // paymentIntent = await createPaymentIntent('10', 'USD');
      //Payment Sheet
      await strip.Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: strip.SetupPaymentSheetParameters(
                  paymentIntentClientSecret: clientSecret,
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await strip.Stripe.instance.presentPaymentSheet().then((value) async {
        Navigator.of(context)
            .popUntil(ModalRoute.withName(Navigator.defaultRouteName));
        Navigator.pushNamed(context, Routes.orderList);
      }).onError((error, stackTrace) {});
    } on strip.StripeException catch (e) {
    } catch (e) {
      print('$e');
    }
  }

  ///Select Address
  Future<void> _onSelectAddress() async {
    // orderListCubit.onSetShippingAddress()
    loading = true;
    setState(() {});
    final list = await AddressRepository.loadAllAddresses() ?? [];
    loading = false;
    setState(() {});
    final result = await showModalBottomSheet<AddressModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [
            (orderListCubit.state as CkeckOutSuccess).checkOut?.address
          ],
          data: list,
        ),
        // hasScroll: true,
      ),
    );
    setState(() {
      if (result != null) {
        OrderRepository.setShippingAddress(
                orderId: widget.id, addressId: result.id)
            .then((value) {
          orderListCubit.onCheckOut(id: widget.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: orderListCubit,
        child: BlocBuilder<OrderListCubit, OrderListState>(
            builder: (context, state) {
          List<Widget> actions = [];
          List<Widget> list = [];
          list.add(AppPlaceholder(
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
                      height: 80,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 70),
                  Card(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ));
          if (state is CkeckOutSuccess) {
            if (state.checkOut != null) {
              list = [];
              actions.add(IconButton(
                icon: Image.asset(Images.moreDetails),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.orderItemList,
                    arguments:
                        RouteArguments(hasOperations: false, item: widget.id),
                  ).then((value) {
                    orderListCubit.onCheckOut(id: widget.id);
                  });
                },
              ));
              Widget trailingWidget = const Icon(Icons.arrow_drop_down);
              if (loading) {
                trailingWidget = const Padding(
                  padding: EdgeInsets.all(4),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                    ),
                  ),
                );
              }

              int c = 0;
              list.add(Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    // boxShadow: smallShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.checkOut?.address?.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .foregroundColor,
                                      fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    Translate.of(context).translate(
                                      "${Application.currentCountry!.name}, ${state.checkOut?.address?.state}, ${state.checkOut?.address?.city}, ${state.checkOut?.address?.description}",
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor),
                                  ),
                                ),
                                trailingWidget,
                              ],
                            ),
                            if (!(state.checkOut?.address
                                    ?.isShippingAddressSupported ??
                                true)) ...[
                              Text(
                                Translate.of(context).translate(
                                    'the_delivery_address_is_not_supported'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ]),
                      onPressed: () {
                        _onSelectAddress();
                      },
                    ),
                  ),
                ),
              ));
              for (var item in state.checkOut!.orderItems) {
                list.add(CheckOutItem(
                  item,
                  isShowCase: c == 0,
                  onChangeQuantity: (int quantity) {
                    item.quantity = quantity;
                  },
                  onRemove: () {
                    UtilOther.showMessage(
                      context: context,
                      title: Translate.of(context).translate('_confirm'),
                      message: Translate.of(context).translate(
                          'confirm_the_removal_of_the_product_from_the_shopping_cart'),
                      func: () {
                        Navigator.pop(context);
                        orderListCubit
                            .onCancelItem(item.orderId, item.id)
                            .then((value) {
                          orderListCubit.onCheckOut(id: widget.id);
                        });
                      },
                      funcName: Translate.of(context).translate('confirm'),
                    );
                  },
                  onComplaint: () {},
                  onReturn: () {},
                ));
                c++;
              }
              list.add(
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'تفاصيل الفاتورة',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              state.checkOut!.amount.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الفاتورة',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.checkOut!.totalTax.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الضريبة',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.checkOut!.totalShippingDestance.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اجمالي مسافة الشحن',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.checkOut!.totalShipping.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'رسوم الشحن',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.checkOut!.totalDiscount.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اجمالي الخصم',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              state.checkOut!.totalDisplay.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الاجمالي',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              list.add(const SizedBox(height: 16));
              list.add(Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    // boxShadow: smallShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Text(
                          Translate.of(context).translate('payment_method'),
                          style: const TextStyle(
                              fontSize: 20,
                              color: darkGrey,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
              list.add(SizedBox(
                height: 150,
                child: Swiper(
                    itemCount: 2,
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return Stack(
                          children: [
                            const PaymentCard(PaymentType.creditCard),
                            if (paymentMethod == PaymentType.creditCard) ...[
                              Positioned(
                                left: AppLanguage.isRTL() ? null : 5,
                                right: AppLanguage.isRTL() ? 5 : null,
                                top: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.5),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ] else
                              Container()
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            const PaymentCard(PaymentType.paypal),
                            if (paymentMethod == PaymentType.paypal) ...[
                              Positioned(
                                left: AppLanguage.isRTL() ? null : 5,
                                right: AppLanguage.isRTL() ? 5 : null,
                                top: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.5),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ] else
                              Container()
                          ],
                        );
                      }
                    },
                    scale: 0.8,
                    controller: swiperController,
                    viewportFraction: 0.6,
                    loop: false,
                    fade: 0.7,
                    onIndexChanged: (index) {
                      paymentMethod = PaymentType.values[index];
                      setState(() {});
                    }),
              ));
              list.add(const SizedBox(height: 24));
            } else {
              list.add(Center(
                child: Card(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                          ModalRoute.withName(Navigator.defaultRouteName));
                      Navigator.pushNamed(context, Routes.orderList);
                    },
                    child: Text(
                        Translate.of(context).translate(
                            'the_order_does_not_exist_it_may_have_been_deleted'),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ));
            }
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              iconTheme: const IconThemeData(color: darkGrey),
              actions: actions,
              title: Text(
                Translate.of(context).translate('_check_out'),
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(children: list),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              // foregroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                await makePayment();
              },
              icon: Image.asset(Images.pay),
              label: Text(
                Translate.of(context).translate('payment'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          );
        }));
  }
}
