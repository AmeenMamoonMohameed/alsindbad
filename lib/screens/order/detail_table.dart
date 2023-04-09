import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class DetailTable extends StatefulWidget {
  final TableOrderModel orderStyle;
  final VoidCallback onCalcPrice;

  const DetailTable({
    Key? key,
    required this.orderStyle,
    required this.onCalcPrice,
  }) : super(key: key);

  @override
  _DetailTableState createState() {
    return _DetailTableState();
  }
}

class _DetailTableState extends State<DetailTable> {
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

  ///Show show change start time
  void _onTimePicker() async {
    final result = await showTimePicker(
      initialTime: widget.orderStyle.startTime ?? TimeOfDay.now(),
      context: context,
    );

    if (result != null) {
      setState(() {
        widget.orderStyle.startTime = result;
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

  ///On select table
  void _onSelectTable(Map<String, dynamic> item) {
    setState(() {
      widget.orderStyle.selected = [item];
    });
    widget.onCalcPrice();
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
                title: Translate.of(context).translate('date'),
                onPressed: _onDatePicker,
              ),
              const SizedBox(height: 16),
              AppPickerItem(
                leading: Icon(
                  Icons.more_time,
                  color: Theme.of(context).hintColor,
                ),
                value: widget.orderStyle.startTime?.viewTime,
                title: Translate.of(context).translate('time'),
                onPressed: _onTimePicker,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Translate.of(context).translate('booked'),
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Translate.of(context).translate('selected'),
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Translate.of(context).translate('empty'),
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                Translate.of(context).translate('order_a_table'),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                runSpacing: 16,
                spacing: 32,
                alignment: WrapAlignment.center,
                children: widget.orderStyle.tableList.map((item) {
                  final booked = item['use'] == true;
                  final selected = widget.orderStyle.selected.contains(item);
                  Function? onPress() {
                    _onSelectTable(item);
                    return null;
                  }

                  Color color = Theme.of(context).dividerColor;
                  if (selected) {
                    color = Theme.of(context).colorScheme.secondary;
                  }
                  if (booked) {
                    color = Theme.of(context).primaryColor;
                  }
                  return InkWell(
                    onTap: booked ? null : onPress,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item['id']}',
                        style: Theme.of(context).textTheme.button!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  );
                }).toList(),
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
