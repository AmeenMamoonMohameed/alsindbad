import 'package:flutter/material.dart';

class CardHeaderWidget extends StatelessWidget {
  static const double padding = 16;
  final String title;

  const CardHeaderWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        // margin: const EdgeInsets.only(top: padding),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 3,
            )
          ],
          color: Theme.of(context).colorScheme.tertiary,
          // border:
          //     Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
}
