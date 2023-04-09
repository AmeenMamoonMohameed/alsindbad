import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class HourlyOrderModel extends OrderStyleModel {
  DateTime? startDate;
  ScheduleModel? schedule;
  List<ScheduleModel> hourList;

  HourlyOrderModel({
    price,
    adult,
    children,
    this.startDate,
    this.schedule,
    required this.hourList,
  }) : super(price: price, adult: adult, children: children);

  @override
  Map<String, dynamic> get params {
    return {
      'orderStyle': 'hourly',
      'adult': adult,
      'children': children,
      'startDate': startDate?.dateView,
      'startTime': schedule?.start.viewTime,
      'endTime': schedule?.end.viewTime,
    };
  }

  factory HourlyOrderModel.fromJson(Map<String, dynamic> json) {
    return HourlyOrderModel(
      price: json['price'] as String,
      startDate: DateTime.tryParse(json['startDate']),
      hourList: List.from(json['selectOptions'] ?? []).map((e) {
        return ScheduleModel.fromJson(e);
      }).toList(),
    );
  }
}
