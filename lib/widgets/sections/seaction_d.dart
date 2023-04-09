import 'dart:convert';

import 'package:akarak/configs/config.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:akarak/packages/chat/widgets/app_placeholder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/model_home_section.dart';

class SectionD extends StatelessWidget {
  HomeSectionModel? data;
  SectionD({Key? key, this.data}) : super(key: key);

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
    return Container(
      // width: MediaQuery.of(context).size.width,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 240,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 8, left: 8),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                // shrinkWrap: true,
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(list[index]['url']!,
                          arguments: list[index]['arguments']);
                    },
                    child: Column(
                      children: [
                        Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(list[index]['color']!)),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: list[index]['image']!,
                              colorBlendMode: BlendMode.color,
                              filterQuality: FilterQuality.high,
                              width: 50,
                              height: 50,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          list[index]['name']!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
