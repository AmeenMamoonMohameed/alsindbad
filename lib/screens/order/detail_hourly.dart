import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class DetailHourly extends StatefulWidget {
  final HourlyOrderModel orderStyle;
  final VoidCallback onCalcPrice;

  const DetailHourly({
    Key? key,
    required this.orderStyle,
    required this.onCalcPrice,
  }) : super(key: key);

  @override
  _DetailHourlyState createState() {
    return _DetailHourlyState();
  }
}

class _DetailHourlyState extends State<DetailHourly> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Show change start date
  void _onDatePicker() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      initialDate: widget.orderStyle.startDate ?? DateTime.now(),
      firstDate: DateTime(now.year, now.month),
      context: context,
      lastDate: DateTime(now.year + 1),
    );
    if (result != null) {
      setState(() {
        widget.orderStyle.startDate = result;
      });
      widget.onCalcPrice();
    }
  }

  ///Show schedule picker
  void _onHourPicker() async {
    final result = await showModalBottomSheet<ScheduleModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [widget.orderStyle.schedule],
            data: widget.orderStyle.hourList,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        widget.orderStyle.schedule = result;
      });
      widget.onCalcPrice();
    }
  }

  ///Show number picker
  void _onPicker(int? init, Function(int) callback) async {
    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppNumberPicker(
          value: init,
        );
      },
    );
    if (result != null) {
      callback(result);
      widget.onCalcPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? viewHour;
    final startTime = widget.orderStyle.schedule?.start;
    final endTime = widget.orderStyle.schedule?.end;
    if (startTime?.viewTime != null) {
      viewHour = '${startTime?.viewTime} - ${endTime?.viewTime}';
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppPickerItem(
                      leading: Icon(
                        Icons.person_outline,
                        color: Theme.of(context).hintColor,
                      ),
                      value: widget.orderStyle.adult?.toString(),
                      title: Translate.of(context).translate('adult'),
                      onPressed: () {
                        _onPicker(widget.orderStyle.adult, (value) {
                          setState(() {
                            widget.orderStyle.adult = value;
                          });
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppPickerItem(
                      leading: Icon(
                        Icons.child_friendly_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                      value: widget.orderStyle.children?.toString(),
                      title: Translate.of(context).translate('children'),
                      onPressed: () {
                        _onPicker(widget.orderStyle.children, (value) {
                          setState(() {
                            widget.orderStyle.children = value;
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppPickerItem(
                leading: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).hintColor,
                ),
                value: widget.orderStyle.startDate?.dateView,
                title: Translate.of(context).translate('date'),
                onPressed: _onDatePicker,
              ),
              const SizedBox(height: 16),
              AppPickerItem(
                leading: Icon(
                  Icons.more_time,
                  color: Theme.of(context).hintColor,
                ),
                value: viewHour,
                title: Translate.of(context).translate('hour'),
                onPressed: _onHourPicker,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translate.of(context).translate('total'),
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    widget.orderStyle.price,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
