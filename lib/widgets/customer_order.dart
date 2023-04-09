import 'package:akarak/app_properties.dart';
import 'package:akarak/configs/language.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/app_user_info.dart';
import 'package:akarak/widgets/color_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:showcaseview/showcaseview.dart';
import '../blocs/app_bloc.dart';
import '../configs/application.dart';

class CustomerOrder extends StatefulWidget {
  final CustomerOrderModel customerOrder;
  final bool isShowCase;
  final VoidCallback onOutStockOrder;
  final VoidCallback onAcceptanceRefund;
  final VoidCallback onRefuseRefund;
  final VoidCallback onConfirmCustomerOrder;
  // final void Function(int) onOutStockOrder;

  const CustomerOrder(this.customerOrder,
      {Key? key,
      required this.isShowCase,
      required this.onOutStockOrder,
      required this.onAcceptanceRefund,
      required this.onRefuseRefund,
      required this.onConfirmCustomerOrder})
      : super(key: key);

  @override
  _CustomerOrderState createState() => _CustomerOrderState();
}

class _CustomerOrderState extends State<CustomerOrder> {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => CustomerOrderChild(
          widget.customerOrder,
          isShowCase: widget.isShowCase,
          onOutStockOrder: widget.onOutStockOrder,
          onAcceptanceRefund: widget.onAcceptanceRefund,
          onRefuseRefund: widget.onRefuseRefund,
          onConfirmCustomerOrder: widget.onConfirmCustomerOrder,
        ),
      ),
    );
  }
}

class CustomerOrderChild extends StatefulWidget {
  final CustomerOrderModel customerOrder;
  final bool isShowCase;
  final VoidCallback onOutStockOrder;
  final VoidCallback onAcceptanceRefund;
  final VoidCallback onRefuseRefund;
  final VoidCallback onConfirmCustomerOrder;

  const CustomerOrderChild(this.customerOrder,
      {Key? key,
      required this.isShowCase,
      required this.onOutStockOrder,
      required this.onAcceptanceRefund,
      required this.onRefuseRefund,
      required this.onConfirmCustomerOrder})
      : super(key: key);

  @override
  _CustomerOrderChildState createState() => _CustomerOrderChildState();
}

class _CustomerOrderChildState extends State<CustomerOrderChild> {
  final GlobalKey _slidableItemKey = GlobalKey();
  final GlobalKey _quantityPickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
              _slidableItemKey,
              _quantityPickerKey,
              // _cartIndicatorKey,
              // _nameKey,
              // _searchKey,
              // _categoriesKey
            ]));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Slidable(
      key: ValueKey(widget.customerOrder.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (widget.customerOrder.status == OrderStatus.finished &&
              widget.customerOrder.hasRefundRequest) ...[
            SlidableAction(
              flex: 2,
              onPressed: (BuildContext? buildContext) {
                widget.onAcceptanceRefund();
                setState(() {});
              },
              backgroundColor: mediumYellow,
              foregroundColor: Colors.white,
              icon: Icons.check_box_outlined,
              label: Translate.of(context).translate('acceptancing_refund'),
            ),
            SlidableAction(
              flex: 2,
              onPressed: (BuildContext? buildContext) {
                widget.onRefuseRefund();
                setState(() {});
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.cancel_presentation_outlined,
              label: Translate.of(context).translate('refuse_refund'),
            ),
          ],
          if (widget.customerOrder.status == OrderStatus.awaitingApproval) ...[
            SlidableAction(
              flex: 2,
              onPressed: (BuildContext? buildContext) {
                widget.onConfirmCustomerOrder();
                setState(() {});
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline_outlined,
              label: Translate.of(context).translate('confirm'),
            ),
            SlidableAction(
              flex: 2,
              onPressed: (BuildContext? buildContext) {
                widget.onOutStockOrder();
                setState(() {});
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.cancel_outlined,
              label: Translate.of(context).translate('out_stock'),
            ),
          ]
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: shadow,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
              left: AppLanguage.isRTL() ? 10 : 0,
              right: AppLanguage.isRTL() ? 0 : 10),
          title: Row(
            mainAxisAlignment: widget.customerOrder.status == OrderStatus.cart
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl: Application.domain +
                      widget.customerOrder.image
                          .replaceAll("\\", "/")
                          .replaceAll("TYPE", "full"),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  color: Colors.transparent,
                  colorBlendMode: BlendMode.color,
                  filterQuality: FilterQuality.high,
                  width: 80,
                  height: 80,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: 12.0,
                    right: AppLanguage.isRTL() ? 0 : 12.0,
                    left: AppLanguage.isRTL() ? 12.0 : 0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${widget.customerOrder.id} - ${widget.customerOrder.name}',
                      textAlign: AppLanguage.isRTL()
                          ? TextAlign.right
                          : TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: darkGrey,
                      ),
                    ),
                    Align(
                      alignment: AppLanguage.isRTL()
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              widget.customerOrder.date ??
                                  Translate.of(context)
                                      .translate('not_confirmed'),
                              textDirection: AppLanguage.isRTL()
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Wrap(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: widget.customerOrder.statusColor,
                            ),
                          ),
                          child: Text(
                            Translate.of(context)
                                .translate(widget.customerOrder.status.name),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(
                                    color: widget.customerOrder.statusColor),
                          ),
                        ),
                        if (widget.customerOrder.hasOpenComplaint)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: InkWell(
                              hoverColor: Colors.amber,
                              onTap: () {
                                AppBloc.messageCubit.onShow(
                                    widget.customerOrder.openComplaint!);
                              },
                              child: Text(
                                Translate.of(context)
                                    .translate('open_complaint'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: widget
                                                .customerOrder.hasOpenComplaint
                                            ? Colors.red
                                            : widget.customerOrder.statusColor),
                              ),
                            ),
                          ),
                        if (widget.customerOrder.hasRefundRequest) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: InkWell(
                              hoverColor: Colors.amber,
                              onTap: () {
                                AppBloc.messageCubit.onShow(
                                    widget.customerOrder.refundRequest!);
                              },
                              child: Text(
                                Translate.of(context)
                                    .translate('request_return'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: widget
                                                .customerOrder.hasRefundRequest
                                            ? Colors.orange
                                            : widget.customerOrder.statusColor),
                              ),
                            ),
                          ),
                        ] else if (widget.customerOrder.hasRefusalToRefund) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: InkWell(
                              hoverColor: Colors.amber,
                              onTap: () {},
                              child: Text(
                                Translate.of(context)
                                    .translate('refusal_to_refund'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(Translate.of(context).translate('details'),
                            textAlign: TextAlign.center))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('size'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'XL',
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('quantity'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.customerOrder.quantity.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('price'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.customerOrder.totalDisplay!,
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('color'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const ColorOption(Colors.red),
            if (widget.customerOrder.status == OrderStatus.finished &&
                widget.customerOrder.hasRefundRequest) ...[
              const SizedBox(height: 8),
              const Divider(),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(mediumYellow),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.5,
                        double.infinity),
                  ),
                ),
                onPressed: () {
                  widget.onAcceptanceRefund();
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_box_outlined),
                    const SizedBox(width: 4),
                    Text(
                      Translate.of(context).translate(
                        Translate.of(context).translate('acceptancing_refund'),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.5,
                        double.infinity),
                  ),
                ),
                onPressed: () {
                  widget.onRefuseRefund();
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel_presentation_outlined),
                    const SizedBox(width: 4),
                    Text(
                      Translate.of(context).translate(
                        Translate.of(context).translate('refuse_refund'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.customerOrder.status ==
                OrderStatus.awaitingApproval) ...[
              const SizedBox(height: 8),
              const Divider(),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.5,
                        double.infinity),
                  ),
                ),
                onPressed: () {
                  widget.onConfirmCustomerOrder();
                  setState(() {});
                },
                child: Text(Translate.of(context).translate('confirm')),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.5,
                        double.infinity),
                  ),
                ),
                onPressed: () {
                  widget.onOutStockOrder();
                  setState(() {});
                },
                child: Text(Translate.of(context).translate('out_stock')),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(8),
              child: AppUserInfo(
                user: widget.customerOrder.createdBy,
                type: UserViewType.information,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.profile,
                    arguments: widget.customerOrder.createdBy!.userId,
                  );
                },
              ),
            ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (widget.isShowCase) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: Align(
          alignment: Alignment(
              AppLanguage.isRTL() ? 0.4 : 0, AppLanguage.isRTL() ? 0 : 0.4),
          child: Showcase(
            key: _slidableItemKey,
            onToolTipClick: () {},
            description: Translate.of(context).translate(
                'to_display_the_options_drag_the_item_from_left_to_right_and_opposite'),
            descTextStyle: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.yellowAccent[900]),
            child: content,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment(
            AppLanguage.isRTL() ? 0.4 : 0, AppLanguage.isRTL() ? 0 : 0.4),
        child: content,
      ),
    );
  }
}
