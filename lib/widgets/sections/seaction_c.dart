import 'package:akarak/configs/config.dart';
import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:akarak/packages/chat/widgets/app_placeholder.dart';
import 'package:flutter/material.dart';

class SectionC extends StatelessWidget {
  Map<String, dynamic>? data;
  SectionC({Key? key, this.data}) : super(key: key);

  void navigateToCategory(BuildContext context, String category) {
    // Navigator.pushNamed(context, CategoryDealsScreen.routeName,
    //     arguments: category);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemCount: data!['list'].length,
        scrollDirection: Axis.horizontal,
        itemExtent: 75,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () =>
                navigateToCategory(context, data!['list'][index]['name']!),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.network(
                    data!['list'][index]['image']!,
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                  ),
                  /*ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      GlobalVariables.categoryImages[index]['image']!,
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                    ),
                  ),*/
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  data!['list'][index]['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
