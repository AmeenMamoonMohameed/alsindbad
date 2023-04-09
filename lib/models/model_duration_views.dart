import 'package:webview_flutter/webview_flutter.dart';

class DurationViewsModel {
  final DateTime start;
  final DateTime end;

  DurationViewsModel({
    required this.start,
    required this.end,
  });

  factory DurationViewsModel.fromJson(Map<String, dynamic> json) {
    return DurationViewsModel(
      start: json['start'],
      end: json['end'],
    );
  }
}
