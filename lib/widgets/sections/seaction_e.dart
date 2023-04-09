import 'dart:convert';

import 'package:akarak/models/model.dart';
import 'package:akarak/widgets/sections/section_e_item.dart';
import 'package:flutter/material.dart';
import '../../models/model_home_section.dart';
import '../../repository/list_repository.dart';

class SectionE extends StatelessWidget {
  HomeSectionModel? data;
  SectionE({Key? key, this.data}) : super(key: key);

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
          child: SectionEItem(),
        );
      },
      itemCount: List.generate(8, (index) => index).length,
    );

    return FutureBuilder<List<dynamic>?>(
      future: ListRepository.loadList(
          pageNumber: 1,
          pageSize: (list as List).length,
          filter:
              FilterModel(containsList: list.map((e) => e as int).toList())),

      /// Adding data by updateDataSource method
      builder:
          (BuildContext futureContext, AsyncSnapshot<List<dynamic>?> snapShot) {
        // return snapShot.connectionState != ConnectionState.done
        //     ? const CircularProgressIndicator()
        //     : SizedBox.fromSize(size: Size.zero);

        if (snapShot.data != null && snapShot.data![0].isNotEmpty) {
          content = ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemBuilder: (context, index) {
              final item = snapShot.data![0][index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SectionEItem(
                  item: item,
                  onPressed: () {
                    // _onTapService(item);
                  },
                ),
              );
            },
            itemCount: snapShot.data![0].length,
          );
        }
        return Container(
          color: color,
          child: Padding(
            padding:
                const EdgeInsets.only(right: 0, left: 0, bottom: 16, top: 24),
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
      },
    );
  }
}
