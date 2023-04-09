import 'package:flutter/material.dart';

import '../app_properties.dart';
import '../configs/image.dart';
import '../models/model_order.dart';


class PaymentCard extends StatelessWidget {
  final PaymentType paymentType;
  const PaymentCard(this.paymentType);
  @override
  Widget build(BuildContext context) {
    if (paymentType == PaymentType.creditCard) {
      return Container(
        height: 200,
        width: 250,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.deepPurple[700],
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text(
              'CREDIT CARD',
              style: TextStyle(color: Colors.white),
            ),
            Container(
              height: 20,
              width: 60,
              color: Colors.white,
              child: Text(
                'CVV/CVC',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            const Text(
              'xxxx - xxxx - xxxx - xxxx',
              style: TextStyle(color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Name',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'XXXX  X XXXX',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return Container(
        height: 200,
        width: 250,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
        child: Container(
          height: 200,
          width: 250,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: shadow,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
            child: Image.asset(Images.paypal),
          ),
        ),
      );
    }
  }
}
