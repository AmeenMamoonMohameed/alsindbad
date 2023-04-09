import 'dart:convert';

import 'package:akarak/configs/config.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:akarak/packages/chat/widgets/app_placeholder.dart';
import 'package:flutter/material.dart';
import '../../models/model_home_section.dart';

class SectionG extends StatelessWidget {
  HomeSectionModel? data;
  SectionG({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color =
        data!.extendedAttributes!.any((element) => element.key == 'color')
            ? Color(int.parse(data!.extendedAttributes!
                .singleWhere((element) => element.key == 'color')
                .text!))
            : Colors.white;
    final seeMore =
        data!.extendedAttributes!.any((element) => element.key == 'see-more')
            ? jsonDecode(data!.extendedAttributes!
                .singleWhere((element) => element.key == 'see-more')
                .json!)
            : null;
    final listString = data!.extendedAttributes!
        .singleWhere((element) => element.key == 'list')
        .json;
    final list = listString != null ? jsonDecode(listString) : [];

    return Container(
      color: color,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  alignment: AppLanguage.isRTL()
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    data!.title,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var item in list) ...[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(item['url']!,
                                arguments: item['arguments']);
                          },
                          child: Column(
                            children: [
                              Image.network(
                                item['image'],
                                height: 280,
                                fit: BoxFit.fitHeight,
                                width: MediaQuery.of(context).size.width / 3.2,
                              ),
                              Text(
                                item['name'],
                                style: const TextStyle(fontSize: 16),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ],
                  ),
                ),
                if (seeMore != null) ...[
                  const Divider(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(seeMore['url']!,
                          arguments: seeMore['arguments']);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                      alignment: AppLanguage.isRTL()
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Text(
                        seeMore['title'] ?? '',
                        style: TextStyle(
                            color: seeMore['color'] != null
                                ? Color(int.parse(seeMore['color']))
                                : const Color(0xFF00838F)),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const Divider(
            height: 20,
            thickness: 5,
            color: Color.fromARGB(255, 214, 219, 220),
          ),
        ],
      ),
    );
  }
}
