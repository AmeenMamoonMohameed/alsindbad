import 'package:akarak/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/widgets/app_placeholder.dart';

class AppOrderItem extends StatelessWidget {
  final OrderModel? order;
  final VoidCallback? onPressed;

  const AppOrderItem({
    Key? key,
    this.order,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (order != null) {
      return InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order!.orderId.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order!.total}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order!.date ?? '',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 4),
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
                            color: order!.statusColor,
                          ),
                        ),
                        child: Text(
                          Translate.of(context).translate(order!.status.name),
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(color: order!.statusColor),
                        ),
                      ),
                      if (order!.isContainsReturned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Colors.red,
                            ),
                          ),
                          child: Text(
                            Translate.of(context)
                                .translate('contains_returned_items'),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  // if (item!.status == OrderStatus.order)
                  //   Text(
                  //     Translate.of(context).translate('incomplete_payment'),
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .button!
                  //         .copyWith(color: Colors.red),
                  //   ),
                  // if (item!.status != OrderStatus.order)
                  //   Text(
                  //     item!.status.name,
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .button!
                  //         .copyWith(color: item!.statusColor),
                  //   ),
                ],
              ),
              const SizedBox(height: 8),
              // const Divider(),
            ],
          ),
        ),
      );
    }

    return AppPlaceholder(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // decoration: BoxDecoration(
        //   border: Border(
        //     bottom: BorderSide(
        //       width: 1,
        //       color: Theme.of(context).dividerColor,
        //     ),
        //   ),
        // ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
