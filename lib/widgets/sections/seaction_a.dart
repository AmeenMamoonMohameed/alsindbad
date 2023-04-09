import 'dart:convert';

import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:akarak/packages/chat/widgets/app_placeholder.dart';
import 'package:akarak/widgets/sections/section_a_item.dart';
import 'package:flutter/material.dart';
import '../../models/model_home_section.dart';

class SectionA extends StatelessWidget {
  HomeSectionModel? data;
  SectionA({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color =
        data!.extendedAttributes!.any((element) => element.key == 'color')
            ? Color(int.parse(data!.extendedAttributes!
                .singleWhere((element) => element.key == 'color')
                .text!))
            : Colors.white;
    final listString = data!.extendedAttributes!
        .singleWhere((element) => element.key == 'list')
        .json;
    final list = listString != null ? jsonDecode(listString) : [];

    ///Loading
    Widget content = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: SectionAItem(),
        );
      },
      itemCount: List.generate(8, (index) => index).length,
    );

    if (data != null) {
      content = ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SectionAItem(
              item: item,
              onPressed: () {
                // _onTapService(item);
              },
            ),
          );
        },
        itemCount: list.length,
      );
    }

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0, bottom: 16, top: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data!.title,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  if (data!.description != null)
                    Text(
                      data!.description!,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                ],
              ),
            ),
            Container(
              height: 280,
              padding: const EdgeInsets.only(top: 4),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
