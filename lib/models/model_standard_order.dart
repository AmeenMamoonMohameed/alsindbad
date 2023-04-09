import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class StandardOrderModel extends OrderStyleModel {
  DateTime? startDate;
  TimeOfDay? startTime;

  StandardOrderModel({
    price,
    adult,
    children,
    this.startDate,
    this.startTime,
  }) : super(price: price, adult: adult, children: children);

  @override
  Map<String, dynamic> get params {
    return {
      'orderStyle': 'standard',
      'adult': adult,
      'children': children,
      'startDate': startDate?.dateView,
      'startTime': startTime?.viewTime,
    };
  }

  factory StandardOrderModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? startTime;
    if (json['startTime'] != null) {
      startTime = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(json['startTime']),
      );
    }
    return StandardOrderModel(
      price: json['price'] as String,
      startDate: DateTime.tryParse(json['startDate']),
      startTime: startTime,
    );
  }
}
