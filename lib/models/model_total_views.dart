import 'package:webview_flutter/webview_flutter.dart';

class TotalViewsModel {
  final int totalProductsViews;
  final int totalProfileViews;

  TotalViewsModel({
    required this.totalProductsViews,
    required this.totalProfileViews,
  });

  factory TotalViewsModel.fromJson(Map<String, dynamic> json) {
    return TotalViewsModel(
      totalProductsViews: json['totalProductsViews'],
      totalProfileViews: json['totalProfileViews'],
    );
  }
}
