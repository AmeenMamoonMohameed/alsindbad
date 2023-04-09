import 'package:akarak/configs/routes.dart';
import 'package:akarak/constants/constants.dart';
import 'package:akarak/constants/responsive.dart';
import 'package:flutter/material.dart';
import '../models/model.dart';
import 'analytic_info_card.dart';

class AnalyticCards extends StatelessWidget {
  List analyticData;
  double? childAspectRatioMobile;
  double? childAspectRatioTablet;
  AnalyticCards(
      {Key? key,
      required this.analyticData,
      this.childAspectRatioMobile,
      this.childAspectRatioTablet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    childAspectRatioMobile ??= size.width < 650 ? 2 : 1.5;
    childAspectRatioTablet ??= size.width < 1400 ? 1.5 : 2.1;

    return Responsive(
      mobile: AnalyticInfoCardGridView(
        analyticData: analyticData,
        crossAxisCount: size.width < 650 ? 2 : 4,
        childAspectRatio: childAspectRatioMobile!,
      ),
      tablet: AnalyticInfoCardGridView(
        analyticData: analyticData,
        childAspectRatio: childAspectRatioTablet!,
      ),
      desktop: AnalyticInfoCardGridView(
        analyticData: analyticData,
        childAspectRatio: size.width < 1400 ? 1.5 : 2.1,
      ),
    );
  }
}

class AnalyticInfoCardGridView extends StatelessWidget {
  AnalyticInfoCardGridView({
    Key? key,
    required this.analyticData,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.4,
  }) : super(key: key);

  List analyticData;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: analyticData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: appPadding,
        mainAxisSpacing: appPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => AnalyticInfoCard(
        info: analyticData[index],
      ),
    );
  }
}
