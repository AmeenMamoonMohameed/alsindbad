import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';

import '../../models/model.dart';

class ProductDetailTab extends SliverPersistentHeaderDelegate {
  final double height;
  final TabController? tabController;
  final bool hasMap;
  // final Function(int) onTap;

  ProductDetailTab({
    required this.height,
    this.tabController,
    required this.hasMap,
    // required this.onTap,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      height: height,
      color: Theme.of(context).colorScheme.onTertiary,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              ColorfulTabBar(
                indicatorHeight: 3,
                tabs: [
                  TabItem(
                    title: Row(children: [
                      const Icon(Icons.info_outlined),
                      const SizedBox(width: 8),
                      Text(Translate.of(context).translate('ad_information'))
                    ]),
                    color: Theme.of(context).primaryColor,
                    unselectedColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  TabItem(
                    title: Row(children: [
                      const Icon(Icons.description_outlined),
                      const SizedBox(width: 8),
                      Text(Translate.of(context).translate('the_explanation'))
                    ]),
                    color: Theme.of(context).primaryColor,
                    unselectedColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  if (hasMap)
                    TabItem(
                      title: Row(children: [
                        const Icon(Icons.map_outlined),
                        const SizedBox(width: 8),
                        Text(Translate.of(context).translate('the_address'))
                      ]),
                      color: Theme.of(context).primaryColor,
                      unselectedColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                ],
                controller: tabController,
              ),
              // _buildAction(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
