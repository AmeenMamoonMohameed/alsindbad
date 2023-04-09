import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/models/model_feature.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../api/api.dart';
import '../../models/model_location.dart';
import '../../repository/location_repository.dart';

enum TimeType { start, end }

class Filter extends StatefulWidget {
  final FilterModel filter;
  const Filter({Key? key, required this.filter}) : super(key: key);

  @override
  _FilterState createState() {
    return _FilterState();
  }
}

class _FilterState extends State<Filter> {
  late FilterModel _filter;
  LocationModel? state;
  LocationModel? city;

  bool _loadingState = false;
  bool _loadingCity = false;
  List<LocationModel> _listState = [];
  List<LocationModel> _listCity = [];
  // List<PropertyModel> _listProperties = [];
  final Map<String, TextEditingController> _controllers =
      Map<String, TextEditingController>();
  final Map<String, String?> _errors = Map<String, String?>();

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;
    // _listProperties = Application.submitSetting.properties
    //     .where((e) => e.propertyType == PropertyType.filter)
    //     .toList();
    _filter.currency = Application.submitSetting.currencies.isNotEmpty
        ? Application.submitSetting.currencies
            .singleWhere((item) => item.isDefault)
        : null;

    state = _listState.any((item) => item.id == _filter.locationId)
        ? _listState.singleWhere((item) => item.id == _filter.locationId)
        : null;
    if (state == null && _listCity.isNotEmpty) {
      city = _listCity.any((item) => item.id == _filter.locationId)
          ? _listState.singleWhere((item) => item.id == _filter.locationId)
          : null;
      state = _listState.singleWhere((item) => item.id == city?.parentId);
    }
    if (_filter.subCategory != null && _filter.mainCategory == null) {
      _filter.mainCategory = Application.submitSetting.categories.singleWhere(
          (element) => element.id == _filter.subCategory!.parentId);
    }
    if (_filter.category != null && _filter.subCategory == null) {
      _filter.subCategory = Application.submitSetting.categories
          .singleWhere((element) => element.id == _filter.category!.parentId);
      _filter.mainCategory = Application.submitSetting.categories.singleWhere(
          (element) => element.id == _filter.subCategory!.parentId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controllers.forEach((key, value) {
      value.dispose();
    });
  }

  ///Export String hour
  // String _labelTime(TimeOfDay time) {
  //   final hourLabel = time.hour < 10 ? '0${time.hour}' : '${time.hour}';
  //   final minLabel = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
  //   return '$hourLabel:$minLabel';
  // }

  ///Show Picker Time
  // Future<void> _showTimePicker(BuildContext context, TimeType type) async {
  //   final picked = await showTimePicker(
  //     initialTime: TimeOfDay.now(),
  //     context: context,
  //   );
  //   if (type == TimeType.start && picked != null) {
  //     setState(() {
  //       _filter.startHour = picked;
  //     });
  //   }
  //   if (type == TimeType.end && picked != null) {
  //     setState(() {
  //       _filter.endHour = picked;
  //     });
  //   }
  // }

  ///On Navigate Filter State
  void _onChangeState() async {
    _listState = [];

    _loadingState = true;
    setState(() {});
    var list = await LocationRepository.loadLocationById(null);
    _listState.addAll(list?.map((e) => e) ?? []);
    _loadingState = false;
    setState(() {});

    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('select_state'),
        selected: [state],
        data: _listState,
      ),
    );
    if (selected != null && selected is LocationModel) {
      setState(() {
        if (selected != _filter.locationId) {
          _listCity = [];
          city = null;
        }
        _filter.locationId = selected.id;
      });
    }
  }

  ///On Navigate Filter City
  void _onChangeCity() async {
    _listCity = [
      LocationModel(
          id: 0,
          parentId: 0,
          name: Translate.of(context).translate("all_city"),
          locationType: LocationType.city,
          countryId: Application.currentCountry?.id ?? 0)
    ];
    _loadingCity = true;
    setState(() {});
    var list = await LocationRepository.loadLocationById(_filter.locationId);
    _listCity.addAll(list?.map((e) => e) ?? []);
    _loadingCity = false;
    setState(() {});

    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('select_city'),
        selected: [city],
        data: _listCity,
      ),
    );
    if (selected != null && selected is LocationModel) {
      setState(() {
        _filter.locationId = selected.id;
      });
    }
  }

  ///On Navigate Filter Main Category
  void _onChangeMainCategory() async {
    bool isSelected = false;
    CategoryModel? mainCategory;
    while (isSelected == false) {
      FocusManager.instance.primaryFocus?.unfocus();
      final selected = await Navigator.pushNamed(
        context,
        Routes.picker,
        arguments: PickerModel(
          name: Translate.of(context).translate('choose_section'),
          selected: [_filter.mainCategory],
          data: _filter.mainCategory != null
              ? Application.submitSetting.categories
                  .where((item) =>
                      item.parentId == mainCategory?.id &&
                      item.type == CategoryType.main)
                  .toList()
              : Application.submitSetting.categories
                  .where((item) =>
                      item.parentId == null && item.type == CategoryType.main)
                  .toList(),
        ),
      );
      if (selected != null && selected is CategoryModel) {
        _filter.mainCategory = mainCategory = selected;
        if (!Application.submitSetting.categories.any((item) =>
            item.parentId == _filter.mainCategory?.id &&
            item.type == CategoryType.main)) {
          isSelected = true;
        }
        setState(() {});
      } else if (selected is bool && selected == true) {
        isSelected = true;
      }
    }
  }

  ///On Navigate Filter Currency
  void _onChangeCurrency() async {
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('select_currency'),
        selected: [_filter.currency],
        data: Application.submitSetting.currencies,
      ),
    );
    if (selected != null && selected is CurrencyModel) {
      setState(() {
        _filter.currency = selected;
      });
    }
  }

  ///Apply filter
  void _onApply() {
    Navigator.pop(context, _filter);
  }

  ///Create Field
  List<Widget> _onCreateField() {
    _filter.extendedAttributes = [];
    List<Widget> widgets = [];

    // if (_filter.category != null) {
    //   // _listProperties.clear();
    //   // Application.submitSetting.properties
    //   //     .where((item) => item.section == widget.filter.section)
    //   //     .where((property) => property.propertyType == PropertyType.filter)
    //   //     .forEach((property) {
    //   //   // if (property.isGeneric ||
    //   //   //     _filter.category!.properties.contains(property.id)) {
    //   //   //   _listProperties.add(property);
    //   //   // }
    //   // });

    // } else {
    //   // _listProperties.clear();
    //   // Application.submitSetting.properties
    //   //     .where((item) => item.section == widget.filter.section)
    //   //     .where((property) => property.propertyType == PropertyType.filter)
    //   //     .forEach((property) {
    //   //   if (property.isGeneric) {
    //   //     _listProperties.add(property);
    //   //   }
    //   // });
    // }

    _filter.subCategory?.groups?.forEach((group) {
      group.properties
          ?.where((property) => property.propertyType == PropertyType.filter)
          .forEach((item) {
        if (!_filter.extendedAttributes!.any((ex) => ex.key == item.key)) {
          if (item.fieldType == FieldType.rangSlider) {
            _filter.extendedAttributes!.add(ExtendedAttributeModel(
              key: item.key,
              type: ExtendedAttributeType.range,
            ));
          } else if (item.fieldType == FieldType.itemsPicker) {
            _filter.extendedAttributes!.add(ExtendedAttributeModel(
                key: item.key,
                type: ExtendedAttributeType.values[item.valueType.index]));
          } else {
            _filter.extendedAttributes!.add(ExtendedAttributeModel(
              key: item.key,
              type: ExtendedAttributeType.values[item.valueType.index],
            ));
          }
        }

        if (item.fieldType == FieldType.itemPicker) {
          widgets.add(_onCreateItemPicker(item));
        } else if (item.fieldType == FieldType.itemsPicker) {
          widgets.add(_onCreateItemsPicker(item));
        } else if (item.fieldType == FieldType.textInput) {
          widgets.add(_onCreateTextInput(item));
        } else if (item.fieldType == FieldType.rangSlider) {
          widgets.add(_onCreateRangSlider(item));
        } else if (item.fieldType == FieldType.slider) {
          widgets.add(_onCreateSlider(item));
        }
      });
    });
    // for (var e in _listProperties) {
    //   if (!_filter.extendedAttributes!.any((ex) => ex.key == e.key)) {
    //     if (e.fieldType == FieldType.rangSlider) {
    //       _filter.extendedAttributes!.add(ExtendedAttributeModel(
    //         key: e.key,
    //         type: ExtendedAttributeType.range,
    //       ));
    //     } else if (e.fieldType == FieldType.itemsPicker) {
    //       _filter.extendedAttributes!.add(ExtendedAttributeModel(
    //           key: e.key,
    //           type: ExtendedAttributeType.values[e.valueType.index],
    //           isList: true));
    //     } else {
    //       _filter.extendedAttributes!.add(ExtendedAttributeModel(
    //         key: e.key,
    //         type: ExtendedAttributeType.values[e.valueType.index],
    //       ));
    //     }
    //   }

    //   if (e.fieldType == FieldType.itemPicker) {
    //     widgets.add(_onCreateItemPicker(e));
    //   } else if (e.fieldType == FieldType.itemsPicker) {
    //     widgets.add(_onCreateItemsPicker(e));
    //   } else if (e.fieldType == FieldType.textInput) {
    //     widgets.add(_onCreateTextInput(e));
    //   } else if (e.fieldType == FieldType.rangSlider) {
    //     widgets.add(_onCreateRangSlider(e));
    //   } else if (e.fieldType == FieldType.slider) {
    //     widgets.add(_onCreateSlider(e));
    //   }
    // }
    return widgets;
  }

  ///Create Range Slider
  Widget _onCreateRangSlider(PropertyModel property) {
    final index =
        _filter.extendedAttributes!.indexWhere((e) => e.key == property.key);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate(property.name),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    property.min.toString(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    property.max.toString(),
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
              SizedBox(
                height: 16,
                child: RangeSlider(
                  min: property.min,
                  max: property.max,
                  values: RangeValues(
                    _filter.extendedAttributes![index].rangMin ?? property.min,
                    _filter.extendedAttributes![index].rangMax ?? property.max,
                  ),
                  divisions: (property.max - property.min).toInt(),
                  inactiveColor: Theme.of(context).colorScheme.secondary,
                  labels: RangeLabels(
                    property.min.toString(),
                    property.max.toString(),
                  ),
                  onChanged: (range) {
                    setState(() {
                      _filter.extendedAttributes![index].rangMin = range.start;
                      _filter.extendedAttributes![index].rangMax = range.end;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Translate.of(context).translate(property.inputPlacement),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(
                    '${_filter.extendedAttributes![index].rangMin ?? property.min} - ${_filter.extendedAttributes![index].rangMax ?? property.max}',
                    style: Theme.of(context).textTheme.subtitle2,
                  )
                ],
              ),
            ],
          ),
        ]);
  }

  ///Create Slider
  Widget _onCreateSlider(PropertyModel property) {
    final index =
        _filter.extendedAttributes!.indexWhere((e) => e.key == property.key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 50),
        Text(
          Translate.of(context).translate(property.name),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              property.min.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              _filter.extendedAttributes![index].getValue()?.toString() ??
                  property.max.toString(),
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        SizedBox(
            height: 16,
            child: Slider(
              value: double.tryParse(_filter.extendedAttributes![index]
                      .getValue()
                      .toString()) ??
                  property.max,
              max: property.max,
              min: property.min,
              inactiveColor: Theme.of(context).colorScheme.secondary,
              divisions: (property.max - property.min).toInt(),
              label: '${_filter.extendedAttributes![index].getValue() ?? 0}',
              onChanged: (value) {
                setState(() {
                  _filter.extendedAttributes![index].setValue(value);
                });
              },
            )),
      ],
    );
  }

  ///Create Item Picker
  Widget _onCreateTextInput(PropertyModel property) {
    if (_controllers[property.key] == null) {
      _controllers[property.key] = TextEditingController();
    }
    final index =
        _filter.extendedAttributes!.indexWhere((e) => e.key == property.key);

    return Container(
        child: Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              Translate.of(context).translate(property.name),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Tooltip(
              triggerMode: TooltipTriggerMode.longPress,
              showDuration: const Duration(seconds: 1),
              message: _errors[property.key] != null &&
                      _errors[property.key]!.isNotEmpty &&
                      _filter.extendedAttributes![index].getValue() == null
                  ? Translate.of(context).translate(property.inputPlacement)
                  : _filter.extendedAttributes![index].getValue()?.toString() ??
                      "",
              child: AppTextInput(
                hintText:
                    Translate.of(context).translate(property.inputPlacement),
                errorText: _errors[property.key],
                controller: _controllers[property.key]!,
                keyboardType: property.valueType == ValueType.text
                    ? TextInputType.text
                    : TextInputType.number,
                inputFormatters: property.valueType == ValueType.int ||
                        property.valueType == ValueType.decimal
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  _filter.extendedAttributes![index].setValue(text);
                  _errors[property.key] = UtilValidator.validate(
                    text,
                    type: property.valueType == ValueType.int
                        ? ValidateType.realNumber
                        : property.valueType == ValueType.double
                            ? ValidateType.number
                            : ValidateType.normal,
                    max: property.max == null || property.max == 0
                        ? null
                        : property.max,
                    min: property.min == null || property.min == 0
                        ? null
                        : property.min,
                    allowEmpty: !property.isRequired,
                  );
                  (context as Element).markNeedsBuild();
                },
                trailing: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    _controllers[property.key]!.clear();
                    _filter.extendedAttributes![index].setValue(null);
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
          ],
        ),
      )
    ]));
  }

  ///Create Item Picker
  Widget _onCreateItemPicker(PropertyModel property) {
    final index =
        _filter.extendedAttributes!.indexWhere((e) => e.key == property.key);
    List<Widget> chips = [];
    property.json.forEach((e) {
      chips.add(
        SizedBox(
          height: 32,
          child: FilterChip(
            selected: e.value ==
                _filter.extendedAttributes![index].getValue().toString(),
            label: Text(Translate.of(context).translate(e.name)),
            onSelected: (check) {
              if (check) {
                _filter.extendedAttributes![index].setValue(e.value);
              } else {
                _filter.extendedAttributes![index].setValue(null);
              }
              setState(() {});
            },
          ),
        ),
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        Text(
          Translate.of(context).translate(property.name),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  ///Create Items Picker
  Widget _onCreateItemsPicker(PropertyModel property) {
    final index =
        _filter.extendedAttributes!.indexWhere((e) => e.key == property.key);
    List<Widget> chips = [];
    property.json.forEach((e) {
      chips.add(
        SizedBox(
          height: 32,
          child: FilterChip(
            selected: _filter.extendedAttributes![index].text
                .toString()
                .split(",")
                .contains(e.value),
            label: Text(Translate.of(context).translate(e.name)),
            onSelected: (check) {
              if (check) {
                List<String> list = [];
                if (_filter.extendedAttributes![index].text != null &&
                    _filter.extendedAttributes![index].text!.isNotEmpty) {
                  list.addAll(_filter.extendedAttributes![index].text!
                      .split(",")
                      .toList());
                }
                // if (list.length == property.max) {
                //   list.remove(list.first);
                //   list.add(e.value);
                // } else {
                list.add(e.value);
                // }
                _filter.extendedAttributes![index].text = list.join(",");
              } else {
                List<String> list = [];
                if (_filter.extendedAttributes![index].text != null &&
                    _filter.extendedAttributes![index].text!.isNotEmpty) {
                  list.addAll(_filter.extendedAttributes![index].text!
                      .split(",")
                      .toList());
                }
                list.remove(e.value);
                _filter.extendedAttributes![index].text = list.join(",");
              }
              setState(() {});
            },
          ),
        ),
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        Text(
          Translate.of(context).translate(property.name),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  ///Build content
  Widget _buildContent() {
    String unitPrice = Application.submitSetting.currencies.isNotEmpty
        ? Application.submitSetting.currencies
            .singleWhere((item) => item.isDefault)
            .code
        : "";
    Widget stateWidget = Text(
      Translate.of(context).translate('select_state'),
      style: Theme.of(context).textTheme.caption,
    );
    Widget cityWidget = Text(
      Translate.of(context).translate('select_city'),
      style: Theme.of(context).textTheme.caption,
    );
    Widget stateAction = RotatedBox(
      quarterTurns: AppLanguage.isRTL() ? 2 : 0,
      child: const Icon(
        Icons.keyboard_arrow_right,
        textDirection: TextDirection.ltr,
      ),
    );

    Widget cityAction = RotatedBox(
      quarterTurns: AppLanguage.isRTL() ? 2 : 0,
      child: const Icon(
        Icons.keyboard_arrow_right,
        textDirection: TextDirection.ltr,
      ),
    );

    if (state != null) {
      stateWidget = Text(
        state!.name,
        style: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(color: Theme.of(context).primaryColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (city != null) {
      cityWidget = Text(
        city!.name,
        style: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(color: Theme.of(context).primaryColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_loadingState) {
      stateAction = const Padding(
        padding: EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (_loadingCity) {
      cityAction = const Padding(
        padding: EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            ToggleSwitch(
              minWidth: double.infinity,
              initialLabelIndex: widget.filter.section.index,
              totalSwitches: 2,
              activeFgColor: Colors.white,
              inactiveBgColor: Theme.of(context).dividerColor,
              labels: [
                Translate.of(context).translate('sale'),
                Translate.of(context).translate('rent'),
              ],
              onToggle: (index) {
                widget.filter.section =
                    index == 0 ? SectionType.sale : SectionType.rent;
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Column(children: [
              const SizedBox(height: 16),
              InkWell(
                onTap: _onChangeState,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Translate.of(context).translate('state'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          stateWidget,
                        ],
                      ),
                    ),
                    stateAction
                  ],
                ),
              )
            ]),
            Visibility(
              visible: state != null || city != null,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _onChangeCity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Translate.of(context).translate('city'),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              cityWidget,
                            ],
                          ),
                        ),
                        cityAction,
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            InkWell(
              onTap: _onChangeMainCategory,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('section'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _filter.mainCategory != null
                              ? _filter.mainCategory!.name
                              : Translate.of(context)
                                  .translate('select_section'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      textDirection: TextDirection.ltr,
                    ),
                  )
                ],
              ),
            ),
            if (_filter.mainCategory != null) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.grey.withOpacity(0.1)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Application.submitSetting.categories
                    .where((element) =>
                        element.parentId == _filter.mainCategory?.id &&
                        element.type == CategoryType.sub)
                    .map((item) {
                  final selected = _filter.subCategory == item;
                  return SizedBox(
                    height: 32,
                    child: FilterChip(
                      backgroundColor: Theme.of(context).dividerColor,
                      selectedColor:
                          Theme.of(context).dividerColor.withOpacity(0.3),
                      selected: selected,
                      label: Text(item.name,
                          style: Theme.of(context).textTheme.caption!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.black : null)),
                      onSelected: (check) {
                        if (check) {
                          _filter.subCategory = item;
                        } else {
                          _filter.subCategory = null;
                        }
                        setState(() {});
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            if (_filter.subCategory != null &&
                _filter.subCategory?.hasBrands == true &&
                _filter.subCategory!.brands != null &&
                _filter.subCategory!.brands!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                Translate.of(context).translate('brand'),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filter.subCategory!.brands!.map((item) {
                  final selected = _filter.brand == item;
                  return SizedBox(
                    height: 32,
                    child: FilterChip(
                      backgroundColor: Theme.of(context).dividerColor,
                      selectedColor:
                          Theme.of(context).dividerColor.withOpacity(0.3),
                      selected: selected,
                      label: Text(item.name),
                      onSelected: (check) {
                        if (check) {
                          _filter.brand = item;
                        } else {
                          _filter.brand = null;
                        }
                        setState(() {});
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        Translate.of(context).translate('price_currency'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      AppPickerItem(
                        title:
                            Translate.of(context).translate('select_currency'),
                        value: widget.filter.currency?.code,
                        withTooltip: true,
                        onPressed: _onChangeCurrency,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translate.of(context).translate('price_range'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${Application.setting.minPriceFilter}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      '${Application.setting.maxPriceFilter}',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 16,
                  child: RangeSlider(
                    min: Application.setting.minPriceFilter,
                    max: Application.setting.maxPriceFilter,
                    values: RangeValues(
                      widget.filter.minPriceFilter ??
                          Application.setting.minPriceFilter,
                      widget.filter.maxPriceFilter ??
                          Application.setting.maxPriceFilter,
                    ),
                    onChanged: (range) {
                      setState(() {
                        widget.filter.minPriceFilter = range.start;
                        widget.filter.maxPriceFilter = range.end;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Translate.of(context).translate('avg_price'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      '${widget.filter.minPriceFilter?.toInt() ?? Application.setting.minPriceFilter} ${_filter.currency?.code ?? unitPrice}  - ${widget.filter.maxPriceFilter?.toInt() ?? Application.setting.maxPriceFilter} ${_filter.currency?.code ?? unitPrice}',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _onCreateField(),
            ),

            if (_filter.features != null && _filter.features!.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    Translate.of(context).translate('features'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Application.submitSetting.features.map((item) {
                      final selected =
                          _filter.features?.any((e) => e == item.id);
                      return SizedBox(
                        height: 32,
                        child: FilterChip(
                          selected: selected ?? false,
                          label: Text(item.name),
                          onSelected: (check) {
                            if (check) {
                              _filter.features ??= [];
                              _filter.features!.add(item.id);
                            } else {
                              _filter.features!.remove(item.id);
                            }
                            setState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('sort_options'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Application.setting.sortOptions.map((item) {
                final selected = _filter.sortOptions == item;
                return SizedBox(
                  height: 32,
                  child: FilterChip(
                    selected: selected,
                    label: Text(Translate.of(context).translate(item.name),
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.black : null)),
                    onSelected: (check) {
                      if (check) {
                        _filter.sortOptions = item;
                      } else {
                        _filter.sortOptions = item;
                      }
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // if (_filter.category.isEmpty ||
            //     _filter.category
            //         .any((e) => e.description.split(',').contains("distance")))
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       const SizedBox(height: 50),
            //       Text(
            //         Translate.of(context).translate('distance'),
            //         style: Theme.of(context)
            //             .textTheme
            //             .headline6!
            //             .copyWith(fontWeight: FontWeight.bold),
            //       ),
            //       const SizedBox(height: 4),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: <Widget>[
            //           Text(
            //             '0Km',
            //             style: Theme.of(context).textTheme.caption,
            //           ),
            //           Text(
            //             '30Km',
            //             style: Theme.of(context).textTheme.caption,
            //           )
            //         ],
            //       ),
            //       Slider(
            //         value: widget.filter.distance ?? 0,
            //         max: 30,
            //         min: 0,
            //         divisions: 2,
            //         label: '${widget.filter.distance ?? 0}',
            //         onChanged: (value) {
            //           setState(() {
            //             widget.filter.distance = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),

            // if (_filter.category.isEmpty ||
            //     _filter.category.any(
            //         (e) => e.description.split(',').contains("businessColor")))
            //   Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         const SizedBox(height: 50),
            //         if (Application.setting.color.isNotEmpty)
            //           Text(
            //             Translate.of(context).translate('business_color'),
            //             style: Theme.of(context)
            //                 .textTheme
            //                 .headline6!
            //                 .copyWith(fontWeight: FontWeight.bold),
            //           ),
            //         if (Application.setting.color.isNotEmpty)
            //           const SizedBox(height: 8),
            //         if (Application.setting.color.isNotEmpty)
            //           Wrap(
            //             spacing: 16,
            //             runSpacing: 8,
            //             children: Application.setting.color.map((item) {
            //               Widget checked = Container();
            //               if (_filter.color == item) {
            //                 checked = const Icon(
            //                   Icons.check,
            //                   color: Colors.white,
            //                 );
            //               }
            //               return InkWell(
            //                 onTap: () {
            //                   setState(() {
            //                     _filter.color = item;
            //                   });
            //                 },
            //                 child: Container(
            //                   width: 32,
            //                   height: 32,
            //                   decoration: BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     color: UtilColor.getColorFromHex(item),
            //                   ),
            //                   child: checked,
            //                 ),
            //               );
            //             }).toList(),
            //           ),
            //       ]),

            // if (_filter.category.isEmpty ||
            //     _filter.category
            //         .any((e) => e.description.split(',').contains("openTime")))
            //   Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            //       Widget>[
            //     const SizedBox(height: 50),
            //     Text(
            //       Translate.of(context).translate('open_time'),
            //       style: Theme.of(context)
            //           .textTheme
            //           .headline6!
            //           .copyWith(fontWeight: FontWeight.bold),
            //     ),
            //     const SizedBox(height: 8),
            //     Container(
            //       padding: const EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: Theme.of(context).dividerColor,
            //         borderRadius: const BorderRadius.all(
            //           Radius.circular(8),
            //         ),
            //       ),
            //       child: IntrinsicHeight(
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             Expanded(
            //               child: InkWell(
            //                 onTap: () {
            //                   _showTimePicker(context, TimeType.start);
            //                 },
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: <Widget>[
            //                     Text(
            //                       Translate.of(context).translate(
            //                         'start_time',
            //                       ),
            //                       style: Theme.of(context).textTheme.caption,
            //                     ),
            //                     const SizedBox(height: 4),
            //                     Text(
            //                       _labelTime(_filter.startHour!),
            //                       style: Theme.of(context).textTheme.subtitle2,
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //             VerticalDivider(
            //               color: Theme.of(context).disabledColor,
            //             ),
            //             const SizedBox(width: 8),
            //             Expanded(
            //               child: InkWell(
            //                 onTap: () {
            //                   _showTimePicker(context, TimeType.end);
            //                 },
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: <Widget>[
            //                     Text(
            //                       Translate.of(context).translate(
            //                         'end_time',
            //                       ),
            //                       style: Theme.of(context).textTheme.caption,
            //                     ),
            //                     const SizedBox(height: 4),
            //                     Text(
            //                       _labelTime(_filter.endHour!),
            //                       style: Theme.of(context).textTheme.subtitle2,
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('filter'),
        ),
        actions: [
          Visibility(
            visible: !_filter.isEmpty(),
            child: AppButton(
              Translate.of(context).translate('clear'),
              onPressed: () {
                setState(() {
                  _filter.clear();
                });
              },
              type: ButtonType.text,
            ),
          ),
          AppButton(
            Translate.of(context).translate('apply'),
            onPressed: _onApply,
            type: ButtonType.text,
          )
        ],
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
}
