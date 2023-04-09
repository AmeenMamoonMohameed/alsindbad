import 'dart:convert';

import 'package:akarak/configs/config.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../models/model_home_section.dart';

class SectionCarousel extends StatelessWidget {
  HomeSectionModel? data;
  SectionCarousel({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listString = data!.extendedAttributes!
        .singleWhere((element) => element.key == 'list')
        .json;
    final list = listString != null ? jsonDecode(listString) : [];

    return CarouselSlider(
      items: (list as List).map((i) {
        return Builder(
          builder: (BuildContext context) => InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(i['url']!, arguments: i['arguments']);
            },
            child: Image.network(
              i['image'],
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        viewportFraction: 1,
        height: 200,
        autoPlay: true,
      ),
    );
  }
}
