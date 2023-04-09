import 'package:webview_flutter/webview_flutter.dart';

class ViewsModel {
  final String dayOfYear;
  final int totlalViews;

  ViewsModel({
    required this.dayOfYear,
    required this.totlalViews,
  });

  factory ViewsModel.fromJson(Map<String, dynamic> json) {
    return ViewsModel(
      dayOfYear: json['dayOfYear'],
      totlalViews: int.parse(json['totlalViews'].toString()),
    );
  }
}
