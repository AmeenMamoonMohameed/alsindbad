import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class TableOrderModel extends OrderStyleModel {
  DateTime? startDate;
  TimeOfDay? startTime;
  List tableList;
  List selected = [];

  TableOrderModel({
    price,
    adult,
    children,
    this.startDate,
    this.startTime,
    required this.tableList,
  }) : super(price: price, adult: adult, children: children);

  @override
  Map<String, dynamic> get params {
    return {
      'orderStyle': 'table',
      'adult': adult,
      'children': children,
      'startDate': startDate?.dateView,
      'startTime': startTime?.viewTime,
      'tableNum': selected.map((e) {
        return e['id'];
      }).toList(),
    };
  }

  factory TableOrderModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? startTime;
    if (json['startTime'] != null) {
      startTime = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(json['startTime']),
      );
    }

    return TableOrderModel(
      price: json['price'] as String,
      startDate: DateTime.tryParse(json['startDate']),
      startTime: startTime,
      tableList: json['selectOptions'] ?? [],
    );
  }
}
