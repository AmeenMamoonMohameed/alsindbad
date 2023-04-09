import 'dart:convert';

import 'package:akarak/configs/config.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:akarak/packages/chat/widgets/app_placeholder.dart';
import 'package:flutter/material.dart';
import '../../models/model_home_section.dart';

class SectionB extends StatelessWidget {
  HomeSectionModel? data;
  SectionB({Key? key, this.data}) : super(key: key);

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
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  alignment: AppLanguage.isRTL()
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: AppLanguage.isRTL() ? 0 : 10,
                      right: AppLanguage.isRTL() ? 10 : 0,
                      bottom: 10),
                  child: Text(
                    data!.title,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: list.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.9,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(list[index]['url']!,
                            arguments: list[index]['arguments']);
                      },
                      child: Column(
                        children: [
                          Image.network(
                            list[index]['image']!,
                            width: MediaQuery.of(context).size.width / 2,
                            fit: BoxFit.fitWidth,
                            height: 150,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(list[index]['name']!)
                        ],
                      ),
                    );
                  },
                ),
                if (seeMore != null) ...[
                  const Divider(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(seeMore['url']!,
                          arguments: seeMore['arguments']);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: AppLanguage.isRTL() ? 0 : 15,
                          right: AppLanguage.isRTL() ? 15 : 0,
                          top: 15,
                          bottom: 10),
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
                ],
              ],
            ),
          ),
          // const Divider(
          //   height: 20,
          //   thickness: 5,
          //   color: Color.fromARGB(255, 214, 219, 220),
          // ),
        ],
      ),
    );
  }
}
