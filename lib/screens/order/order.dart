import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../../repository/repository.dart';
import 'detail_daily.dart';
import 'detail_hourly.dart';
import 'detail_slot.dart';
import 'detail_standard.dart';
import 'detail_table.dart';
import 'package:http/http.dart' as http;

class Order extends StatefulWidget {
  final int id;

  const Order({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _OrderState createState() {
    return _OrderState();
  }
}

class _OrderState extends State<Order> {
  final _orderCubit = OrderCubit();
  final _textFistNameController = TextEditingController();
  final _textLastNameController = TextEditingController();
  final _textPhoneController = TextEditingController();
  final _textEmailController = TextEditingController();
  final _textAddressController = TextEditingController();
  final _textMessageController = TextEditingController();

  final _focusFistName = FocusNode();
  final _focusLastName = FocusNode();
  final _focusPhone = FocusNode();
  final _focusEmail = FocusNode();
  final _focusAddress = FocusNode();
  final _focusMessage = FocusNode();

  int _active = 0;
  bool _agree = false;
  String? _errorFirstName;
  String? _errorLastName;
  String? _errorPhone;
  String? _errorEmail;
  String? _errorAddress;
  bool loadingCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    SVProgressHUD.dismiss();
    _textFistNameController.dispose();
    _textLastNameController.dispose();
    _textPhoneController.dispose();
    _textEmailController.dispose();
    _textAddressController.dispose();
    _textMessageController.dispose();
    _focusFistName.dispose();
    _focusLastName.dispose();
    _focusPhone.dispose();
    _focusEmail.dispose();
    _focusAddress.dispose();
    _focusMessage.dispose();
    super.dispose();
  }

  ///Init data
  void _loadData() async {
    await _orderCubit.initOrder(widget.id);
  }

  Map<String, dynamic>? paymentIntent;

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      return (await PaymentRepository.createPaymentIntent(
          paymentType: 'order',
          id: widget.id,
          amount: calculateAmount(amount),
          currency: currency,
          paymentMethodType: 'card'));

      // Map<String, dynamic> body = {
      //   'amount': calculateAmount(amount),
      //   'currency': currency,
      //   'payment_method_types[]': 'card'
      // };

      // var response = await http.product(
      //   Uri.parse('https://api.stripe.com/v1/payment_intents'),
      //   headers: {
      //     'Authorization':
      //         'Bearer sk_test_51MPW5wGRTXPs10RHKnGUKKQDMmMxFB0GYWBtG7PSSsAanO1VxXDAXwuFT75uZVG4iKBJ8i2yHkbF2nG0SK2joVbA00XnNjo3RP',
      //     // 'Authorization': 'Bearer $SECRET_KEY',
      //     'Content-Type': 'application/x-www-form-urlencoded'
      //   },
      //   body: body,
      // );
      //// ignore: avoid_print
      // print('Payment Intent Body->>> ${response.body.toString()}');
      // return jsonDecode(response.body);
    } catch (err) {
      //// ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  Future<void> makePayment() async {
    // var personRlesult = await Stripe.createToken( const CreateTokenParams.card( // deffirent between PaymentMethod and createToken and PaymentIntent
    //     params: CardTokenParams(
    //         type: TokenType.Card,
    //         name: "",
    //         address: Address(
    //             city: "city",
    //             country: "country",
    //             line1: "line1",
    //             line2: "line2",
    //             productalCode: "productalCode",
    //             state: "state"),
    //         currency: "")));
    try {
      final clientSecret = await createPaymentIntent('2500', 'USD');
      // paymentIntent = await createPaymentIntent('10', 'USD');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: clientSecret,
                  // paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
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
      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  actions: [
                    TextButton(
                      child: Text(
                        Translate.of(context).translate('my_purchases'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      onPressed: () async {
                        if (!mounted) return;
                        await Navigator.pushReplacementNamed(
                            context, Routes.orderList);
                      },
                    )
                  ],
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              Text(Translate.of(context)
                                  .translate('payment_successfull')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ));

        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  ///On order
  void _onOrder(FormSuccess form) async {
    // await makePayment();
    Navigator.pushNamed(
      context,
      Routes.paypalPayment,
      arguments: (number) async {
        // payment done
        print('order id: ' + number);
      },
    );

    // final result = await _orderCubit.order(
    //   id: widget.id,
    //   firstName: _textFistNameController.text,
    //   lastName: _textLastNameController.text,
    //   phone: _textPhoneController.text,
    //   email: _textEmailController.text,
    //   address: _textAddressController.text,
    //   message: _textMessageController.text,
    //   form: form,
    // );
    // if (result.succeeded) {
    //   if (result.data != null) {
    //     if (!mounted) return;
    //     final url = await Navigator.pushNamed(
    //       context,
    //       Routes.webView,
    //       arguments: WebViewModel(
    //         title: Translate.of(context).translate('payment'),
    //         url: result.data,
    //         callbackUrl: ['v1/order/return', 'v1/order/cancel'],
    //       ),
    //     );
    //     final cancel = url is String && url.contains('v1/order/cancel');
    //     if (url == null || cancel) {
    //       AppBloc.messageCubit.onShow('payment_not_completed');
    //     }
    //   }

    //   setState(() {
    //     _active += 1;
    //   });
    // }
  }

  ///On Calc Price
  void _onCalcPrice(FormSuccess form) async {
    final price = await _orderCubit.calcPrice(
      id: widget.id,
      form: form,
    );
    if (price != null) {
      setState(() {
        form.orderStyle.price = price;
      });
    }
  }

  ///On next
  void _onNext({
    required FormSuccess form,
    required int step,
  }) async {
    UtilOther.hiddenKeyboard(context);
    if (step == 0) {
      if (form.orderStyle.adult == null) {
        AppBloc.messageCubit.onShow('choose_adults_message');
        return;
      }
      if (form.orderStyle is StandardOrderModel) {
        final style = form.orderStyle as StandardOrderModel;
        if (style.startDate == null) {
          AppBloc.messageCubit.onShow('choose_date_message');
          return;
        }
        if (style.startTime == null) {
          AppBloc.messageCubit.onShow('choose_time_message');
          return;
        }
      } else if (form.orderStyle is DailyOrderModel) {
        final style = form.orderStyle as DailyOrderModel;
        if (style.startDate == null) {
          AppBloc.messageCubit.onShow('choose_date_message');
          return;
        }
      } else if (form.orderStyle is HourlyOrderModel) {
        final style = form.orderStyle as HourlyOrderModel;
        if (style.startDate == null) {
          AppBloc.messageCubit.onShow('choose_date_message');
          return;
        }
        if (style.schedule == null) {
          AppBloc.messageCubit.onShow('choose_time_message');
          return;
        }
      } else if (form.orderStyle is TableOrderModel) {
        final style = form.orderStyle as TableOrderModel;
        if (style.startDate == null) {
          AppBloc.messageCubit.onShow('choose_date_message');
          return;
        }
        if (style.startTime == null) {
          AppBloc.messageCubit.onShow('choose_time_message');
          return;
        }
        if (style.selected.isEmpty) {
          AppBloc.messageCubit.onShow('choose_table_message');
          return;
        }
      }
      setState(() {
        _active += 1;
      });
    } else if (step == 1) {
      if (_textFistNameController.text.isEmpty) {
        _errorFirstName = Translate.of(context).translate('first_name_message');
      }
      if (_textLastNameController.text.isEmpty) {
        _errorLastName = Translate.of(context).translate('last_name_message');
      }
      if (_textPhoneController.text.isEmpty) {
        _errorPhone = Translate.of(context).translate('phone_message');
      }
      if (_textEmailController.text.isEmpty) {
        _errorEmail = Translate.of(context).translate('email_message');
      }
      if (_textAddressController.text.isEmpty) {
        _errorAddress = Translate.of(context).translate('address_message');
      }
      setState(() {
        if (_errorFirstName == null &&
            _errorLastName == null &&
            _errorPhone == null &&
            _errorEmail == null &&
            _errorAddress == null) {
          if (form.orderPayment.use) {
            _active += 1;
          } else {
            _onOrder(form);
          }
        }
      });
    } else if (step == 2) {
      _onOrder(form);
    }
  }

  ///Go my order
  void _onMyOrder() {
    Navigator.pushReplacementNamed(context, Routes.orderList);
  }

  ///On previous
  void _onPrevious() {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _active -= 1;
    });
  }

  ///On Open Term
  void _onTerm(FormSuccess form) {
    Navigator.pushNamed(
      context,
      Routes.webView,
      arguments: WebViewModel(
        name: Translate.of(context).translate('term_condition'),
        url: form.orderPayment.term,
      ),
    );
  }

  ///Widget build detail
  Widget _buildDetail(FormSuccess form) {
    if (form.orderStyle is StandardOrderModel) {
      return DetailStandard(
        orderStyle: form.orderStyle as StandardOrderModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.orderStyle is DailyOrderModel) {
      return DetailDaily(
        orderStyle: form.orderStyle as DailyOrderModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.orderStyle is HourlyOrderModel) {
      return DetailHourly(
        orderStyle: form.orderStyle as HourlyOrderModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.orderStyle is TableOrderModel) {
      return DetailTable(
        orderStyle: form.orderStyle as TableOrderModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.orderStyle is SlotOrderModel) {
      return DetailSlot(
        orderStyle: form.orderStyle as SlotOrderModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else {
      return Container();
    }
  }

  ///build contact
  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('input_first_name'),
            errorText: _errorFirstName,
            controller: _textFistNameController,
            focusNode: _focusFistName,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorFirstName = UtilValidator.validate(
                  _textFistNameController.text,
                );
              });
            },
            onSubmitted: (text) {
              UtilOther.fieldFocusChange(
                context,
                _focusFistName,
                _focusLastName,
              );
            },
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textFistNameController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('input_last_name'),
            errorText: _errorLastName,
            controller: _textLastNameController,
            focusNode: _focusLastName,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorLastName = UtilValidator.validate(
                  _textLastNameController.text,
                );
              });
            },
            onSubmitted: (text) {
              UtilOther.fieldFocusChange(
                context,
                _focusLastName,
                _focusPhone,
              );
            },
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textLastNameController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('input_phone'),
            errorText: _errorPhone,
            controller: _textPhoneController,
            focusNode: _focusPhone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            onChanged: (text) {
              setState(() {
                _errorPhone = UtilValidator.validate(
                  _textPhoneController.text,
                  type: ValidateType.phone,
                );
              });
            },
            onSubmitted: (text) {
              UtilOther.fieldFocusChange(
                context,
                _focusPhone,
                _focusEmail,
              );
            },
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textPhoneController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('input_email'),
            errorText: _errorEmail,
            controller: _textEmailController,
            focusNode: _focusEmail,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorEmail = UtilValidator.validate(
                  _textEmailController.text,
                  type: ValidateType.email,
                );
              });
            },
            onSubmitted: (text) {
              UtilOther.fieldFocusChange(
                context,
                _focusEmail,
                _focusAddress,
              );
            },
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textEmailController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          AppTextInput(
            hintText: Translate.of(context).translate('input_address'),
            errorText: _errorAddress,
            controller: _textAddressController,
            focusNode: _focusAddress,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorAddress = UtilValidator.validate(
                  _textAddressController.text,
                );
              });
            },
            onSubmitted: (text) {
              UtilOther.fieldFocusChange(
                context,
                _focusAddress,
                _focusMessage,
              );
            },
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textAddressController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 16),
          AppTextInput(
            maxLines: 6,
            hintText: Translate.of(context).translate('input_content'),
            controller: _textMessageController,
            focusNode: _focusMessage,
            textInputAction: TextInputAction.done,
            trailing: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                _textMessageController.clear();
              },
              child: const Icon(Icons.clear),
            ),
          ),
        ],
      ),
    );
  }

  ///Build payment
  Widget _buildPayment(FormSuccess form) {
    Widget bankAccountList = Container();
    Widget paymentInfo = Container();

    if (form.orderPayment.method?.id == 'bank') {
      bankAccountList = Column(
        children: form.orderPayment.listAccount.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.bankName,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('account_name'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.button,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate('iban'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bankIban,
                          style: Theme.of(context).textTheme.button,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('account_number'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.number,
                          style: Theme.of(context).textTheme.button,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate('swift_code'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bankSwift,
                          style: Theme.of(context).textTheme.button,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          );
        }).toList(),
      );
    }
    if (form.orderPayment.method != null) {
      paymentInfo = Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).focusColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.orderPayment.method?.name ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    form.orderPayment.method?.description ?? '',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    form.orderPayment.method?.instruction ?? '',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        children: [
          Column(
            children: form.orderPayment.listMethod.map((item) {
              if (item != form.orderPayment.listMethod.last) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          activeColor: Theme.of(context).primaryColor,
                          value: item.id,
                          groupValue: form.orderPayment.method?.id,
                          onChanged: (value) {
                            setState(() {
                              form.orderPayment.method = item;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name!,
                                style: Theme.of(context).textTheme.button,
                              ),
                              Text(
                                item.instruction!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }
              return Row(
                children: [
                  Radio<String>(
                    activeColor: Theme.of(context).primaryColor,
                    value: item.id,
                    groupValue: form.orderPayment.method?.id,
                    onChanged: (value) {
                      setState(() {
                        form.orderPayment.method = item;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name!,
                          style: Theme.of(context).textTheme.button,
                        ),
                        Text(
                          item.instruction!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  )
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          paymentInfo,
          const SizedBox(height: 16),
          bankAccountList,
        ],
      ),
    );
  }

  ///Build completed
  Widget _buildCompleted() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.of(context).translate('order_success_title'),
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.of(context).translate(
              'order_success_message',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2,
          )
        ],
      ),
    );
  }

  ///Widget build content
  Widget _buildContent(FormSuccess form) {
    switch (_active) {
      case 0:
        return _buildDetail(form);
      case 1:
        return _buildContact();
      case 2:
        if (!form.orderPayment.use) {
          continue success;
        }
        return _buildPayment(form);
      success:
      case 3:
        return _buildCompleted();
      default:
        return Container();
    }
  }

  ///Build action
  Widget _buildAction(FormSuccess form) {
    switch (_active) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: AppButton(
            Translate.of(context).translate('next'),
            onPressed: () {
              _onNext(form: form, step: 0);
            },
            mainAxisSize: MainAxisSize.max,
          ),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  Translate.of(context).translate('previous'),
                  onPressed: _onPrevious,
                  mainAxisSize: MainAxisSize.max,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  Translate.of(context).translate('next'),
                  onPressed: () {
                    _onNext(form: form, step: 1);
                  },
                  mainAxisSize: MainAxisSize.max,
                ),
              )
            ],
          ),
        );
      case 2:
        if (!form.orderPayment.use) {
          continue success;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: Theme.of(context).primaryColor,
                    value: _agree,
                    onChanged: (value) {
                      setState(() {
                        _agree = value!;
                      });
                    },
                  ),
                  Text(
                    Translate.of(context).translate('i_agree'),
                    style: Theme.of(context).textTheme.button,
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: () {
                      _onTerm(form);
                    },
                    child: Text(
                      Translate.of(context).translate('term_condition'),
                      style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      Translate.of(context).translate('previous'),
                      onPressed: _onPrevious,
                      mainAxisSize: MainAxisSize.max,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      Translate.of(context).translate('next'),
                      onPressed: () {
                        _onNext(form: form, step: 2);
                      },
                      disabled: !_agree,
                      mainAxisSize: MainAxisSize.max,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      success:
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  Translate.of(context).translate('back'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  mainAxisSize: MainAxisSize.max,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  Translate.of(context).translate('my_purchases'),
                  onPressed: _onMyOrder,
                  mainAxisSize: MainAxisSize.max,
                ),
              )
            ],
          ),
        );
      default:
        return Container();
    }
  }

  CardEditController? controller;
  @override
  Widget build(BuildContext context) {
    // controller = CardEditController();
    // return Scaffold(
    //   appBar: AppBar(),
    //   body: Container(
    //     alignment: Alignment.center,
    //     // padding: const EdgeInsets.all(16),
    //     child: CardField(
    //       autofocus: true,
    //       dangerouslyGetFullCardDetails: true,
    //       onCardChanged: (card) {
    //         print(card);
    //       },
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('order'),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        bloc: _orderCubit,
        builder: (context, form) {
          Widget content = Container();
          if (form is FormSuccess) {
            List<StepModel> step = [
              StepModel(
                name: Translate.of(context).translate('details'),
                icon: Icons.calendar_today_outlined,
              ),
              StepModel(
                name: Translate.of(context).translate('communication'),
                icon: Icons.contact_mail_outlined,
              ),
              StepModel(
                name: Translate.of(context).translate('completed'),
                icon: Icons.check,
              )
            ];
            if (form.orderPayment.use) {
              step = [
                StepModel(
                  name: Translate.of(context).translate('details'),
                  icon: Icons.calendar_today_outlined,
                ),
                StepModel(
                  name: Translate.of(context).translate('contact'),
                  icon: Icons.contact_mail_outlined,
                ),
                StepModel(
                  name: Translate.of(context).translate('payment'),
                  icon: Icons.payment_outlined,
                ),
                StepModel(
                  name: Translate.of(context).translate('completed'),
                  icon: Icons.check,
                )
              ];
            }
            content = Column(
              children: [
                const SizedBox(height: 16),
                AppStepper(
                  active: _active,
                  list: step,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContent(form),
                  ),
                ),
                _buildAction(form),
              ],
            );
          }
          return SafeArea(
            child: content,
          );
        },
      ),
    );
  }
}
