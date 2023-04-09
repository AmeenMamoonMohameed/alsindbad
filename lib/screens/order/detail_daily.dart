import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class DetailDaily extends StatefulWidget {
  final DailyOrderModel orderStyle;
  final VoidCallback onCalcPrice;

  const DetailDaily({
    Key? key,
    required this.orderStyle,
    required this.onCalcPrice,
  }) : super(key: key);

  @override
  _DetailDailyState createState() {
    return _DetailDailyState();
  }
}

class _DetailDailyState extends State<DetailDaily> {
  bool _allowEndTime = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Show picker date
  void _onDatePicker(DateTime? init, Function(DateTime) callback) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      initialDate: init ?? now,
      firstDate: DateTime(now.year, now.month),
      context: context,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      callback(picked);
      widget.onCalcPrice();
    }
  }

  ///Show picker time
  void _onTimePicker(TimeOfDay? init, Function(TimeOfDay) callback) async {
    final picked = await showTimePicker(
      initialTime: init ?? TimeOfDay.now(),
      context: context,
    );

    if (picked != null) {
      callback(picked);
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
                title: Translate.of(context).translate('start_date'),
                onPressed: () {
                  _onDatePicker(widget.orderStyle.startDate, (value) {
                    setState(() {
                      widget.orderStyle.startDate = value;
                    });
                  });
                },
              ),
              const SizedBox(height: 16),
              AppPickerItem(
                leading: Icon(
                  Icons.more_time,
                  color: Theme.of(context).hintColor,
                ),
                value: widget.orderStyle.startTime?.viewTime,
                title: Translate.of(context).translate('start_hour'),
                onPressed: () {
                  _onTimePicker(widget.orderStyle.startTime, (value) {
                    setState(() {
                      widget.orderStyle.startTime = value;
                    });
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              activeColor: Theme.of(context).primaryColor,
              value: _allowEndTime,
              onChanged: (bool? value) {
                setState(() {
                  _allowEndTime = value!;
                });
              },
            ),
            Text(
              Translate.of(context).translate('end_time'),
              style: Theme.of(context)
                  .textTheme
                  .button
                  ?.copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Visibility(
          visible: _allowEndTime,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                AppPickerItem(
                  leading: Icon(
                    Icons.calendar_today_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                  value: widget.orderStyle.endDate?.dateView,
                  title: Translate.of(context).translate('end_date'),
                  onPressed: () {
                    _onDatePicker(widget.orderStyle.endDate, (value) {
                      setState(() {
                        widget.orderStyle.endDate = value;
                      });
                    });
                  },
                ),
                const SizedBox(height: 16),
                AppPickerItem(
                  leading: Icon(
                    Icons.more_time,
                    color: Theme.of(context).hintColor,
                  ),
                  value: widget.orderStyle.endTime?.viewTime,
                  title: Translate.of(context).translate('end_hour'),
                  onPressed: () {
                    _onTimePicker(widget.orderStyle.endTime, (value) {
                      setState(() {
                        widget.orderStyle.endTime = value;
                      });
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            children: [
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
