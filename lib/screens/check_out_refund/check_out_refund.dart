import 'package:akarak/app_properties.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/payment_repository.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/credit_card.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as strip;
import 'package:showcaseview/showcaseview.dart';

import '../../configs/routes.dart';

class CheckOutRefund extends StatefulWidget {
  int id;
  CheckOutRefund({Key? key, required this.id}) : super(key: key);

  @override
  _CheckOutRefundState createState() => _CheckOutRefundState();
}

class _CheckOutRefundState extends State<CheckOutRefund> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(
          builder: (context) => CheckOutRefundChild(
            id: widget.id,
          ),
        ),
      ),
    );
  }
}

class CheckOutRefundChild extends StatefulWidget {
  int id;
  CheckOutRefundChild({Key? key, required this.id}) : super(key: key);

  @override
  _CheckOutRefundChildState createState() => _CheckOutRefundChildState();
}

class _CheckOutRefundChildState extends State<CheckOutRefundChild> {
  SwiperController swiperController = SwiperController();
  final customerOrderListCubit = CustomerOrderListCubit();
  PaymentType paymentMethod = PaymentType.creditCard;

  @override
  void initState() {
    super.initState();
    customerOrderListCubit.onGetCustomerOrderAmount(id: widget.id);
    // customerOrderListCubit.onLoadDetail(id: widget.id);
  }

  @override
  void dispose() {
    customerOrderListCubit.close();
    swiperController.dispose();
    super.dispose();
  }

  calculateAmount(double amount) {
    final calculatedAmout = amount.toInt() * 100;
    return calculatedAmout.toString();
  }

  createPaymentIntent(double amount, String currency) async {
    try {
      return (await PaymentRepository.createPaymentIntent(
          paymentType: 'refund',
          id: widget.id,
          amount: calculateAmount(amount),
          currency: currency,
          paymentMethodType: 'card'));
    } catch (err) {
      //// ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  Future<void> makePayment(double amount, String currencyCode) async {
    try {
      final clientSecret = await createPaymentIntent(amount, currencyCode);
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
        Navigator.pop(context, true);
      }).onError((error, stackTrace) {});
    } on strip.StripeException catch (e) {
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: customerOrderListCubit,
        child: BlocBuilder<CustomerOrderListCubit, CustomerOrderListState>(
            builder: (context, state) {
          Widget content = Container();
          List<Widget> actions = [];
          if (state is CustomerOrderAmountSuccess) {
            if (state.customerOrderAmount != null) {
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
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
                                state.customerOrderAmount!.amount.toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الفاتورة',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.customerOrderAmount!.totalTax.toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الضريبة',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.customerOrderAmount!.totalShippingDestance
                                    .toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'اجمالي مسافة الشحن',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.customerOrderAmount!.totalShipping
                                    .toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'رسوم الشحن',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.customerOrderAmount!.totalDiscount
                                    .toString(),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'اجمالي الخصم',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.customerOrderAmount!.totalDisplay
                                    .toString(),
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
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Translate.of(context).translate('payment_method'),
                      style: const TextStyle(
                          fontSize: 20,
                          color: darkGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: Swiper(
                        itemCount: 2,
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return const PaymentCard(PaymentType.creditCard);
                          } else {
                            return const PaymentCard(PaymentType.paypal);
                          }
                        },
                        scale: 0.8,
                        controller: swiperController,
                        viewportFraction: 0.6,
                        loop: false,
                        fade: 0.7,
                        onIndexChanged: (index) {
                          paymentMethod = PaymentType.values[index];
                        }),
                  ),
                  const SizedBox(height: 24),
                  // Center(
                  //     child: Padding(
                  //   padding: EdgeInsets.only(
                  //       bottom: MediaQuery.of(context).padding.bottom == 0
                  //           ? 20
                  //           : MediaQuery.of(context).padding.bottom),
                  //   child: checkOutButton,
                  // ))
                ],
              );
            } else {
              content = Center(
                child: Card(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                          ModalRoute.withName(Navigator.defaultRouteName));
                      Navigator.pushNamed(context, Routes.orderList);
                    },
                    child: Text(
                        'the_request_does_not_exist_it_may_have_been_deleted',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              );
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
                  child: content,
                ),
              ),
            ),
            bottomNavigationBar: Container(
              constraints: const BoxConstraints(maxHeight: 50),
              // color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  height: 50.0,
                  color: yellow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          if (state is CustomerOrderAmountSuccess) {
                            await makePayment(
                                state.customerOrderAmount!.totalShipping,
                                state.customerOrderAmount!.currencyCode);
                          }

                          // customerOrderListCubit
                          //     .onCompleteCheckOutRefund(customerOrderListCubit.checkOut);
                        },
                        child: Container(
                          // height: 30,
                          width: MediaQuery.of(context).size.width - 10,
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
                            child: Text(
                                Translate.of(context).translate('check_out'),
                                style: const TextStyle(
                                    color: Color(0xfffefefe),
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }
}
