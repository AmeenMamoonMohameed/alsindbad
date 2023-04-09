import 'package:akarak/app_properties.dart';
import 'package:flutter/material.dart';

import '../algo/algo.dart';

///[DateChip] use to show the date breakers on the chat view
///[date] parameter is required
///[color] parameter is optional default color code `8AD3D5`
///
///
class DateChip extends StatelessWidget {
  final String? text;
  final DateTime? date;
  final Color color;

  ///
  ///
  ///
  const DateChip({
    Key? key,
    this.text,
    this.date,
    this.color = const Color(0x558AD3D5),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 7,
        bottom: 7,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: color,
          boxShadow: smallShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: text != null
              ? Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )
              : Text(
                  Algo.dateChipText(date!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
