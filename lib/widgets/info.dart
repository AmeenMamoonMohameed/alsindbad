import 'package:akarak/app_properties.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:flutter/material.dart';
import '../models/model.dart';
import 'analytic_info_card.dart';

class Info extends StatelessWidget {
  Color? color;
  String message;
  Info({Key? key, this.color, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        // height: 120,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color ?? const Color(0xfff5e6b5),
          boxShadow: smallShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Center(
                child: Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Center(
                  child: Text(
                    message,
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
