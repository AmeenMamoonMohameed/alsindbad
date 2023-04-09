import 'package:akarak/constants/constants.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import '../configs/language.dart';
import '../models/model.dart';

class AnalyticInfoCard extends StatelessWidget {
  const AnalyticInfoCard({Key? key, required this.info}) : super(key: key);

  final AnalyticInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: appPadding,
        vertical: appPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).dividerColor.withOpacity(
                  .05,
                ),
            spreadRadius: 4,
            blurRadius: 4,
            offset: const Offset(
              0,
              2,
            ), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (info.routeName != null && info.routeName!.isNotEmpty) {
            Navigator.pushNamed(context, info.routeName!);
          }
        },
        child: info.body != null
            ? info.body!
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        info.count == info.count?.toInt()
                            ? "${info.count?.toInt()}"
                            : "${info.count}",
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(appPadding / 2),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: info.color!.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Image.asset(
                          info.src!,
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        info.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        color: Colors.blueAccent[400],
                        AppLanguage.isRTL()
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
