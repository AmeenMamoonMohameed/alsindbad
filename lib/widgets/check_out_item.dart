import 'package:akarak/app_properties.dart';
import 'package:akarak/configs/language.dart';
import 'package:akarak/utils/translate.dart';
import 'package:akarak/widgets/color_list.dart';
import 'package:akarak/widgets/shop_product.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:showcaseview/showcaseview.dart';
import '../blocs/app_bloc.dart';
import '../configs/application.dart';
import '../configs/config.dart';

class CheckOutItem extends StatefulWidget {
  final OrderItemModel orderItem;
  final bool hasOperations;
  final bool isShowCase;
  final Function(int) onChangeQuantity;
  final VoidCallback onRemove;
  final VoidCallback onReturn;
  final VoidCallback onComplaint;

  const CheckOutItem(this.orderItem,
      {Key? key,
      required this.isShowCase,
      required this.onChangeQuantity,
      required this.onRemove,
      required this.onReturn,
      required this.onComplaint,
      this.hasOperations = true})
      : super(key: key);

  @override
  _CheckOutItemState createState() => _CheckOutItemState();
}

class _CheckOutItemState extends State<CheckOutItem> {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => CheckOutItemChild(
          widget.orderItem,
          isShowCase: widget.isShowCase,
          hasOperations: widget.hasOperations,
          onChangeQuantity: (int id) => widget.onChangeQuantity,
          onRemove: widget.onRemove,
          onReturn: widget.onReturn,
          onComplaint: widget.onComplaint,
        ),
      ),
    );
  }
}

class CheckOutItemChild extends StatefulWidget {
  final OrderItemModel orderItem;
  final bool hasOperations;
  final bool isShowCase;
  final Function(int) onChangeQuantity;
  final VoidCallback onRemove;
  final VoidCallback onReturn;
  final VoidCallback onComplaint;

  const CheckOutItemChild(this.orderItem,
      {Key? key,
      required this.isShowCase,
      required this.onChangeQuantity,
      required this.onRemove,
      required this.onReturn,
      required this.onComplaint,
      this.hasOperations = true})
      : super(key: key);

  @override
  _CheckOutItemChildState createState() => _CheckOutItemChildState();
}

class _CheckOutItemChildState extends State<CheckOutItemChild> {
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
      key: ValueKey(widget.orderItem.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (BuildContext? buildContext) {
              widget.onRemove();
              setState(() {});
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.cancel_outlined,
            label: Translate.of(context).translate('cancel'),
          ),
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
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl: Application.domain +
                      widget.orderItem.image
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
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.orderItem.name,
                      textAlign: AppLanguage.isRTL()
                          ? TextAlign.right
                          : TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //  Row(children: [
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
                              color: widget.orderItem.statusColor,
                            ),
                          ),
                          child: Text(
                            Translate.of(context)
                                .translate(widget.orderItem.status.name),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: widget.orderItem.statusColor),
                          ),
                        ),
                        if (widget.orderItem.hasRefundRequest) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: InkWell(
                              hoverColor: Colors.amber,
                              onTap: () {
                                AppBloc.messageCubit
                                    .onShow(widget.orderItem.refundRequest!);
                              },
                              child: Text(
                                Translate.of(context)
                                    .translate('request_return'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                        color: widget.orderItem.hasRefundRequest
                                            ? Colors.orange
                                            : widget.orderItem.statusColor),
                              ),
                            ),
                          ),
                        ] else if (widget.orderItem.hasRefusalToRefund) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: InkWell(
                              hoverColor: Colors.amber,
                              onTap: () {
                                AppBloc.messageCubit.onShow(
                                    'dear_customer_if_you_find_violation_of_the_policy_from_the_seller_please_file_complaint');
                              },
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
                    // ],) ,
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
              widget.orderItem.quantity.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('price'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.totalDisplay!,
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('color'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const ColorOption(Colors.red),
            const SizedBox(height: 8),
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
                        child: Text(Translate.of(context).translate('shipping'),
                            textAlign: TextAlign.center))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('from'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.itemShipping?.originAddress ?? "",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 4),
            Text(
              Translate.of(context).translate('to'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.itemShipping?.destinationAddress ?? "",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 4),
            Text(
              Translate.of(context).translate('distance'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.itemShipping?.distanceText ?? "",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 4),
            Text(
              Translate.of(context).translate('duration'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.itemShipping?.durationText ?? "",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 4),
            Text(
              Translate.of(context).translate('total_fee'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.orderItem.itemShipping?.totalFee?.toString() ?? "",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(height: 4),
            // if (widget.orderItem.status == OrderStatus.awaitingApproval) ...[
            const SizedBox(height: 8),
            const Divider(),

            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(
                      MediaQuery.of(context).size.width * 0.5, double.infinity),
                ),
              ),
              onPressed: () {
                widget.onRemove();
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel_outlined),
                  const SizedBox(width: 4),
                  Text(Translate.of(context).translate('cancel')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(8),
              child: AppUserInfo(
                user: widget.orderItem.sellerInfo,
                type: UserViewType.information,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.profile,
                    arguments: widget.orderItem.sellerInfo!.userId,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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
