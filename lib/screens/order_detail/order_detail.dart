import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderDetail extends StatefulWidget {
  final RouteArguments arguments;
  const OrderDetail({Key? key, required this.arguments}) : super(key: key);

  @override
  _OrderDetailState createState() {
    return _OrderDetailState();
  }
}

class _OrderDetailState extends State<OrderDetail> {
  final orderListCubit = OrderListCubit();

  @override
  void initState() {
    super.initState();
    orderListCubit.onLoadDetail(id: widget.arguments.item);
  }

  @override
  void dispose() {
    orderListCubit.close();
    super.dispose();
  }

  ///Order cancel
  void _cancelOrder() async {
    await orderListCubit.onCancel(widget.arguments.item);
    widget.arguments.callback!();
  }

  ///Order payment
  void _paymentOrder() {}

  ///Build resource
  List<Widget> _buildResource(OrderItemModel order) {
    return (order.resource ?? []).map((item) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translate.of(context).translate('res_length'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                'x ${item.quantity}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translate.of(context).translate('price'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                '${item.total}${order.currencyId}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ],
      );
    }).toList();
  }

  ///Build item info
  Widget _buildItemInfo({
    required String title,
    String? value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value ?? '',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  ///Build action
  Widget _buildAction(OrderItemModel item) {
    if (item.allowCancel == true && item.allowPayment == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                Translate.of(context).translate('cancel'),
                onPressed: _cancelOrder,
                mainAxisSize: MainAxisSize.max,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                Translate.of(context).translate('payment'),
                onPressed: _paymentOrder,
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        ),
      );
    } else if (item.allowCancel == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AppButton(
          Translate.of(context).translate('cancel'),
          onPressed: _cancelOrder,
          mainAxisSize: MainAxisSize.max,
        ),
      );
    } else if (item.allowPayment == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AppButton(
          Translate.of(context).translate('payment'),
          onPressed: _paymentOrder,
          mainAxisSize: MainAxisSize.max,
        ),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: orderListCubit,
        child: BlocBuilder<OrderListCubit, OrderListState>(
          // bloc: orderListCubit,
          builder: (context, state) {
            Widget body = const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
            List<Widget> itemWidget = [
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            ];
            if (state is OrderDetailsSuccess) {
              if (state.orderDetails != null &&
                  state.orderDetails!.orderItems.isNotEmpty) {
                for (var item in state.orderDetails!.orderItems) {
                  itemWidget.add(Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                Translate.of(context).translate('order_id'),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.id}',
                                style: Theme.of(context).textTheme.subtitle1,
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'payment',
                                  ),
                                  value: Translate.of(context).translate(
                                    item.payment.name,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'payment_method',
                                  ),
                                  value: Translate.of(context).translate(
                                    item.paymentName,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'transaction_id',
                                  ),
                                  value: Translate.of(context).translate(
                                    item.transactionID,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'created_on',
                                  ),
                                  value: item.createdOn,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'payment_total',
                                  ),
                                  value: '${item.totalDisplay}',
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'paid_on',
                                  ),
                                  value: item.paidOn,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'status',
                                  ),
                                  value: item.status.name,
                                  color: item.statusColor,
                                ),
                              ),
                              Expanded(
                                child: _buildItemInfo(
                                  title: Translate.of(context).translate(
                                    'created_via',
                                  ),
                                  value: item.createdVia,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Container(
                            alignment: Alignment.center,
                            child: QrImage(
                              data: '${item.id}',
                              size: 150,
                              backgroundColor: Colors.white,
                              errorStateBuilder: (cxt, err) {
                                return const Text(
                                  "Uh oh! Something went wrong...",
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: _buildResource(item),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            Translate.of(context)
                                .translate('billing')
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translate.of(context).translate(
                                        'first_name',
                                      ),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.billFirstName ?? '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translate.of(context).translate(
                                        'last_name',
                                      ),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.billLastName ?? '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translate.of(context).translate('phone'),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.billPhone ?? '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translate.of(context).translate('email'),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.billEmail ?? '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translate.of(context).translate('address'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.billAddress ?? '',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ));
                  itemWidget.add(_buildAction(item));
                }
              }

              body = Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  children: itemWidget,
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  Translate.of(context).translate('order_detail'),
                ),
              ),
              body: SafeArea(
                child: body,
              ),
            );
          },
        ));
  }
}
