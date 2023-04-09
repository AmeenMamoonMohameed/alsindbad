import 'package:akarak/app_properties.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import "package:flutter/services.dart";
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../repository/location_repository.dart';

class AddAddress extends StatefulWidget {
  final AddressModel? item;
  final bool? isSelectable;
  const AddAddress({
    Key? key,
    this.item,
    this.isSelectable = false,
  }) : super(key: key);

  @override
  _SubmitState createState() {
    return _SubmitState();
  }
}

class _SubmitState extends State<AddAddress> {
  final regInt = RegExp('[^0-9]');

  final _textAddressNameController = TextEditingController();
  final _textFirstNameController = TextEditingController();
  final _textLastNameController = TextEditingController();
  final _textDescriptionController = TextEditingController();
  final _textWhatsappController = TextEditingController();
  final _textPhoneController = TextEditingController();

  final _focusAddressName = FocusNode();
  final _focusFirstName = FocusNode();
  final _focusLastName = FocusNode();
  final _focusDescription = FocusNode();
  final _focusWhatsapp = FocusNode();
  final _focusPhone = FocusNode();

  bool _processing = false;

  String? _errorAddressName;
  String? _errorFirstName;
  String? _errorLastName;
  String? _errorDescription;
  String? _errorState;
  String? _errorCity;
  String? _errorGps;
  String? _errorPhone;

  /// Data
  List<LocationModel>? _listState;
  List<LocationModel>? _listCity;
  bool _loadingState = false;
  bool _loadingCity = false;

  ///Data Params
  bool isDefault = false;
  LocationModel? _state;
  LocationModel? _city;
  CoordinateModel? _gps;

  @override
  void initState() {
    super.initState();
    _onProcess();
  }

  @override
  void dispose() {
    _textAddressNameController.dispose();
    _textFirstNameController.dispose();
    _textLastNameController.dispose();
    _textDescriptionController.dispose();
    _textWhatsappController.dispose();
    _textPhoneController.dispose();
    _focusAddressName.dispose();
    _focusFirstName.dispose();
    _focusLastName.dispose();
    _focusDescription.dispose();
    _focusWhatsapp.dispose();
    _focusPhone.dispose();
    super.dispose();
  }

  ///On Load Edit Address
  void _onProcess() async {
    setState(() {
      _processing = true;
    });
    Map<String, dynamic> params = {};
    if (widget.item != null) {
      params['id'] = widget.item!.id;
    }

    if (widget.item != null) {
      isDefault = widget.item!.isDefault;
      _textAddressNameController.text = widget.item!.name;
      _textFirstNameController.text = widget.item!.firstName;
      _textLastNameController.text = widget.item!.lastName;
      _textPhoneController.text = widget.item!.phoneNumber;
      _textDescriptionController.text = widget.item!.description;
      // _state = LocationModel(
      //     id: 1,
      //     countryId: Application.currentCountry!.id,
      //     parentId: 0,
      //     name: widget.item!.state);
      // _city = LocationModel(
      //     id: 1,
      //     countryId: Application.currentCountry!.id,
      //     parentId: 0,
      //     name: widget.item!.city);
      _gps = CoordinateModel(
          name: widget.item!.name,
          longitude: double.parse(widget.item!.longitude),
          latitude: double.parse(widget.item!.latitude));
      _listState = await LocationRepository.loadLocationById(null);
      _listCity =
          await LocationRepository.loadLocationById(widget.item!.stateId);
      _state = _listState
          ?.singleWhere((element) => element.id == widget.item!.stateId);
      _city = _listCity
          ?.singleWhere((element) => element.id == widget.item!.cityId);
    }
    setState(() {
      _processing = false;
    });
  }

  ///On Select state
  void _onSelectState() async {
    _loadingState = true;
    setState(() {});

    _listState = await LocationRepository.loadLocationById(null);
    _loadingState = false;
    setState(() {});

    // ignore: use_build_context_synchronously
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('choose_state'),
        selected: [_state],
        data: _listState ?? [],
      ),
    );
    if (selected != null && selected is LocationModel) {
      setState(() {
        _state = selected;
        _listCity = null;
        _city = null;
      });
      setState(() {});
    }
  }

  ///On Select city
  void _onSelectCity() async {
    if (_state == null) {
      AppBloc.messageCubit.onShow('choose_state');
      return;
    }
    _loadingCity = true;
    setState(() {});

    _listCity = await LocationRepository.loadLocationById(_state!.id);
    _loadingCity = false;
    setState(() {});

    // ignore: use_build_context_synchronously
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('choose_city'),
        selected: [_city],
        data: _listCity ?? [],
      ),
    );
    if (selected != null && selected is LocationModel) {
      setState(() {
        _city = selected;
      });
    }
  }

  ///On Select Address
  void _onSelectAddress() async {
    final selected = await Navigator.pushNamed(
      context,
      Routes.gpsPicker,
      arguments: _gps,
    );
    if (selected != null && selected is CoordinateModel) {
      setState(() {
        _gps = selected;
      });
    }
  }

  ///On Submit
  void _onSubmit() async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }

    final success = _validData();
    if (success) {
      int? result;
      final address = await AddressRepository.loadDefault();
      result = await AddressRepository.submitAddress(
        id: widget.item?.id ?? 0,
        // country: Application.currentCountry!.name,
        stateId: _state!.id,
        cityId: _city!.id,
        name: _textAddressNameController.text,
        description: _textDescriptionController.text,
        firstName: _textFirstNameController.text,
        lastName: _textLastNameController.text,
        isDefault: isDefault,
        latitude: _gps!.latitude.toString(),
        longitude: _gps!.longitude.toString(),
        phoneNumber: _textPhoneController.text,
        type: AddressType.receiptAddress,
      );
      if (result != null) {
        if (!isDefault && address != null && result == address.id) {
          AddressRepository.removeDefault();
        }
        _onSuccess();
      }
    }
  }

  ///On Success
  Future<void> _onSuccess() async {
    if (isDefault) {
      await AddressRepository.saveDefault(
          address: AddressModel(
        id: widget.item?.id ?? 0,
        stateId: _state!.id,
        state: _state!.name,
        cityId: _city!.id,
        city: _city!.name,
        name: _textAddressNameController.text,
        description: _textDescriptionController.text,
        firstName: _textFirstNameController.text,
        lastName: _textLastNameController.text,
        isDefault: isDefault,
        latitude: _gps!.latitude.toString(),
        longitude: _gps!.longitude.toString(),
        phoneNumber: _textPhoneController.text,
        type: AddressType.receiptAddress,
      ));
    }
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, Routes.addressList,
        arguments: widget.isSelectable);
  }

  ///valid data
  bool _validData() {
    ///Address Name
    _errorAddressName = UtilValidator.validate(
      _textAddressNameController.text,
    );

    ///First Name
    _errorFirstName = UtilValidator.validate(
      _textFirstNameController.text,
    );

    ///Last Name
    _errorLastName = UtilValidator.validate(
      _textLastNameController.text,
    );

    ///Description
    _errorDescription = UtilValidator.validate(
      _textDescriptionController.text,
    );

    ///State
    _errorState = _state == null
        ? "${Translate.of(context).translate('state')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///City
    _errorCity = _city == null
        ? "${Translate.of(context).translate('city')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///Gps
    _errorGps = _gps == null
        ? "${Translate.of(context).translate('location_coordinates')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///Phone
    _errorPhone = UtilValidator.validate(
      _textPhoneController.text,
      type: ValidateType.phone,
      allowEmpty: false,
    );

    if (_errorAddressName != null ||
        _errorFirstName != null ||
        _errorLastName != null ||
        _errorDescription != null ||
        _errorState != null ||
        _errorCity != null ||
        _errorGps != null ||
        _errorPhone != null) {
      setState(() {});
      return false;
    }

    return true;
  }

  ///Build content
  Widget _buildContent() {
    if (_processing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('location'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppPickerItem(
                    title: _errorState ??
                        Translate.of(context).translate('choose_state'),
                    value: _state?.name,
                    loading: _loadingState,
                    color: _errorState != null
                        ? Theme.of(context).errorColor
                        : null,
                    onPressed: _onSelectState,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppPickerItem(
                    title: _errorCity ??
                        Translate.of(context).translate('choose_city'),
                    value: _city?.name,
                    loading: _loadingCity,
                    color: _errorCity != null
                        ? Theme.of(context).errorColor
                        : null,
                    withTooltip: true,
                    onPressed: _onSelectCity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('address_name'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            AppTextInput(
              hintText: Translate.of(context).translate('input_address_name'),
              errorText: _errorAddressName,
              controller: _textAddressNameController,
              focusNode: _focusAddressName,
              textInputAction: TextInputAction.next,
              onChanged: (text) {
                setState(() {
                  _errorAddressName = UtilValidator.validate(
                    _textAddressNameController.text,
                  );
                });
              },
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textAddressNameController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('address_description'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              maxLines: 6,
              hintText:
                  Translate.of(context).translate('input_address_description'),
              errorText: _errorDescription,
              controller: _textDescriptionController,
              focusNode: _focusDescription,
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                setState(() {
                  _errorDescription = UtilValidator.validate(
                    _textDescriptionController.text,
                  );
                });
              },
              leading: Icon(
                Icons.home_outlined,
                color: Theme.of(context).hintColor,
              ),
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textDescriptionController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 16),
            AppPickerItem(
              leading: Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).hintColor,
              ),
              title: _errorGps ??
                  Translate.of(context).translate(
                    'choose_gps_location',
                  ),
              value: _gps != null
                  ? '${_gps!.latitude.toStringAsFixed(3)},${_gps!.longitude.toStringAsFixed(3)}'
                  : null,
              color: _errorGps != null ? Theme.of(context).errorColor : null,
              onPressed: _onSelectAddress,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  isDefault = !isDefault;
                });
              },
              child: Row(
                children: [
                  Text(
                    Translate.of(context).translate('default_delivery_address'),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: isDefault,
                    onChanged: (value) {
                      setState(() {
                        isDefault = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_first_name'),
              errorText: _errorFirstName,
              controller: _textFirstNameController,
              focusNode: _focusFirstName,
              textInputAction: TextInputAction.next,
              onChanged: (text) {
                setState(() {
                  _errorFirstName = UtilValidator.validate(
                    _textFirstNameController.text,
                  );
                });
              },
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textFirstNameController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_last_name'),
              errorText: _errorLastName,
              controller: _textLastNameController,
              focusNode: _focusLastName,
              textInputAction: TextInputAction.next,
              onChanged: (text) {
                setState(() {
                  _errorLastName = UtilValidator.validate(
                    _textLastNameController.text,
                  );
                });
              },
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textLastNameController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_phone'),
              errorText: _errorPhone,
              controller: _textPhoneController,
              focusNode: _focusPhone,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                setState(() {
                  _errorPhone = UtilValidator.validate(
                    _textPhoneController.text,
                    type: ValidateType.phone,
                    min: Application.setting.minLengthPhoneNumber.toDouble(),
                    max: Application.setting.maxLengthPhoneNumber.toDouble(),
                    allowEmpty: false,
                  );
                });
              },
              // onSubmitted: (text) {
              //   UtilOther.fieldFocusChange(
              //     context,
              //     _focusPhone,
              //     _focusFax,
              //   );
              // },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: _onSubmit,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 1.5,
                  decoration: BoxDecoration(
                      gradient: mainButton,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.16),
                          offset: Offset(0, 5),
                          blurRadius: 10.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(9.0)),
                  child: Center(
                    child: Text(
                        Translate.of(context)
                            .translate(widget.item != null ? 'update' : 'add'),
                        style: const TextStyle(
                            color: Color(0xfffefefe),
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            fontSize: 20.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String textTitle = Translate.of(context).translate('add_new_address');
    if (widget.item != null) {
      textTitle = Translate.of(context).translate('update_address');
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(textTitle),
        ),
        body: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }
}
