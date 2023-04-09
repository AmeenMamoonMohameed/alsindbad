import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class DailyOrderModel extends OrderStyleModel {
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  DailyOrderModel({
    price,
    adult,
    children,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  }) : super(price: price, adult: adult, children: children);

  @override
  Map<String, dynamic> get params {
    Map<String, dynamic> params = {
      'orderStyle': 'daily',
      'adult': adult,
      'children': children,
      'startDate': startDate?.dateView,
      'startTime': startTime?.viewTime,
    };
    if (endDate != null) {
      params['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }
    if (endTime != null) {
      params['endTime'] = endTime?.viewTime;
    }
    return params;
  }

  factory DailyOrderModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    if (json['startTime'] != null) {
      startTime = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(json['startTime']),
      );
    }

    if (json['endTime'] != null) {
      endTime = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(json['endTime']),
      );
    }
    return DailyOrderModel(
      price: json['price'] as String,
      startDate: DateTime.tryParse(json['startDate']),
      startTime: startTime,
      endDate: DateTime.tryParse(json['startDate']),
      endTime: endTime,
    );
  }
}
