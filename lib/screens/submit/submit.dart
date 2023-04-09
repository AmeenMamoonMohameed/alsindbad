import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import "package:flutter/services.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toggle_switch/toggle_switch.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../models/model_feature.dart';
import '../../repository/location_repository.dart';

class Submit extends StatefulWidget {
  final ProductModel? item;
  const Submit({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  _SubmitState createState() {
    return _SubmitState();
  }
}

class _SubmitState extends State<Submit> {
  final regInt = RegExp('[^0-9]');

  final _textNameController = TextEditingController();
  final _textTradeNameController = TextEditingController();
  final _textBaracodeController = TextEditingController();
  final _textContentController = TextEditingController();
  final _textDiscountController = TextEditingController();
  // final _textTagsController = TextEditingController();
  final _textYoutubeVideoController = TextEditingController();
  final _textAddressController = TextEditingController();
  final _textWhatsappController = TextEditingController();
  final _textPhoneController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textSizesController = <TextEditingController>[];
  final _textPricesController = <TextEditingController>[];
  final _textMainPriceController = TextEditingController();

  final _focusName = FocusNode();
  final _focusTradeName = FocusNode();
  final _focusBaracode = FocusNode();
  final _focusContent = FocusNode();
  final _focusDiscount = FocusNode();
  final _focusYoutubeVideo = FocusNode();
  final _focusAddress = FocusNode();
  final _focusWhatsapp = FocusNode();
  final _focusPhone = FocusNode();
  final _focusPrice = FocusNode();
  final _focusSizes = <FocusNode>[];
  final _focusPrices = <FocusNode>[];

  bool _processing = false;

  String? _errorCurrency;
  String? _errorName;
  String? _errorDiscount;
  String? _errorState;
  String? _errorCity;
  String? _errorSubCategory;
  String? _errorCategory;
  String? _errorBrand;
  String? _errorGps;
  String? _errorYoutubeVideo;
  String? _errorAddress;
  String? _errorWhatsapp;
  String? _errorPhone;
  String? _errorStatus;
  String? _errorPrice;
  final List<String?> _errorSizes = [];
  final List<String?> _errorPrices = [];

  /// Data
  List<Widget> _listPropertyWidgets = [];
  List<CategoryModel> _listCategories = [];
  List<FeatureModel> _listFeatures = [];
  List<LocationModel>? _listState;
  List<LocationModel>? _listCity;
  bool _loadingState = false;
  bool _loadingCity = false;

  ///Data Params
  bool _hasDiscount = false;
  bool paymentActivation = false;
  SectionType _section = SectionType.sale;
  String? _image;
  CategoryModel? _subCategory;
  CategoryModel? _category;
  BrandModel? _brand;
  List<String> _tags = [];
  List<String> _sizes = [];
  PriceType _priceType = PriceType.fixed;
  LocationModel? _state;
  LocationModel? _city;
  CurrencyModel? _currency = Application.submitSetting.currencies.isNotEmpty
      ? Application.submitSetting.currencies
          .singleWhere((item) => item.isDefault)
      : null;
  CoordinateModel? _gps;
  List<ExtendedAttributeModel> _extendedAttributes = [];
  List<Color>? _colors = [];
  // IconModel? _icon;
  String? _date;
  // List<OpenTimeModel>? _time;
  Map<String, dynamic> _socials = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _onProcess();
  }

  @override
  void dispose() {
    _textNameController.dispose();
    _textTradeNameController.dispose();
    _textBaracodeController.dispose();
    _textContentController.dispose();
    _textDiscountController.dispose();
    // _textTagsController.dispose();
    _textYoutubeVideoController.dispose();
    _textAddressController.dispose();
    _textWhatsappController.dispose();
    _textPhoneController.dispose();
    _textPriceController.dispose();
    _textMainPriceController.dispose();
    for (var element in _textSizesController) {
      element.dispose();
    }
    for (var element in _textPricesController) {
      element.dispose();
    }
    _focusName.dispose();
    _focusTradeName.dispose();
    _focusBaracode.dispose();
    _focusContent.dispose();
    _focusDiscount.dispose();
    _focusYoutubeVideo.dispose();
    _focusAddress.dispose();
    _focusWhatsapp.dispose();
    _focusPhone.dispose();
    _focusPrice.dispose();
    for (var element in _focusSizes) {
      element.dispose();
    }
    for (var element in _focusPrices) {
      element.dispose();
    }

    super.dispose();
  }

  ///On Load Edit Product
  void _onProcess() async {
    setState(() {
      _processing = true;
    });
    Map<String, dynamic> params = {};
    if (widget.item != null) {
      params['id'] = widget.item!.id;
    }
    _listCategories = Application.submitSetting.categories;
    _listFeatures = Application.submitSetting.features;

    if (widget.item != null) {
      final result = await ListRepository.loadProduct(widget.item!.id);
      if (result != null) {
        _image = result.image;
        // _gallery = result.gallery;
        _textNameController.text = result.name;
        _textTradeNameController.text = result.tradeName ?? '';
        _textBaracodeController.text = result.baracode ?? '';
        _textContentController.text = result.content;
        _hasDiscount = result.hasDiscount;
        _textDiscountController.text =
            result.discount != null ? result.discount!.toString() : "";
        _subCategory = result.subCategory;
        _category = result.category;
        _brand = result.brand;
        _section = result.section;
        // _tags = result.tags;
        _state = result.state;
        _city = result.city;
        _currency = result.currency;
        _gps = result.coordinate;
        _extendedAttributes = result.extendedAttributes;
        _date = result.date;
        _category?.groups?.forEach((group) {
          group.properties
              ?.where(
                  (property) => property.propertyType == PropertyType.entity)
              .where((e) => e.section == _section)
              .forEach((property) {
            _onSetProperty(property);
            // if (!result.extendedAttributes
            //     .any((ex) => ex.key == property.key)) {
            //   _onSetProperty(property);
            // }
            // _listPropertyWidgets.add(PropertyWidgett(
            //     property: property,
            //     extendedAttribute: result.extendedAttributes
            //         .singleWhere((ex) => ex.key == property.key)));
          });
        });
        _priceType = result.priceType;
        _textPriceController.text = result.price.replaceAll(regInt, '');
        if (_extendedAttributes.any((element) => element.key == 'size')) {
          for (var item in _extendedAttributes
              .where((element) => element.key == 'size')) {
            _textSizesController.add(TextEditingController(text: item.text));
            _focusSizes.add(FocusNode());
            _errorSizes.add(null);
            if (_priceType == PriceType.bySize) {
              _textPricesController
                  .add(TextEditingController(text: item.double_.toString()));
              _focusPrices.add(FocusNode());
              _errorPrices.add(null);
            }
          }
        }
        if (_extendedAttributes.any((element) => element.key == 'color')) {
          for (var item in _extendedAttributes
              .where((element) => element.key == 'color')) {
            _colors ??= [];
            _colors!.add(Color(int.parse('0x${item.text!}')));
          }
        }
        _extendedAttributes
            .where((item) => item.group == "social")
            .forEach((item) {
          if (_extendedAttributes.any((e) => e.key == item.key)) {
            _socials[item.key] =
                _extendedAttributes.firstWhere((e) => e.key == item.key).text ??
                    '';
          }
        });
        if (_extendedAttributes.any((e) => e.key == "youtubeVideo")) {
          _textYoutubeVideoController.text = _extendedAttributes
                  .firstWhere((e) => e.key == "youtubeVideo")
                  .text ??
              '';
        }
        if (_extendedAttributes.any((e) => e.key == "address")) {
          _textAddressController.text =
              _extendedAttributes.firstWhere((e) => e.key == "address").text ??
                  '';
        }
        if (_extendedAttributes.any((e) => e.key == "whatsapp")) {
          _textWhatsappController.text =
              _extendedAttributes.firstWhere((e) => e.key == "whatsapp").text ??
                  '';
        }

        if (_extendedAttributes.any((e) => e.key == "phone")) {
          _textPhoneController.text =
              _extendedAttributes.firstWhere((e) => e.key == "phone").text ??
                  '';
        }
        // _time = result.openHours;
        _listState = await LocationRepository.loadLocationById(null);
        _listCity = await LocationRepository.loadLocationById(_state!.id);
      }
    }
    setState(() {
      _processing = false;
    });
  }

  ///On Upload Gallery
  void _onUploadGallery() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.galleryUpload,
      arguments:
          _extendedAttributes.where((e) => e.key == "gallery").map((item) {
        return item.text!;
      }).toList(),
    );

    if (result != null && result is List<String>) {
      setState(() {
        _extendedAttributes.removeWhere((e) => e.key == "gallery");
        for (var e in result) {
          _extendedAttributes.add(ExtendedAttributeModel(
              key: "gallery", text: e, group: "gallery"));
        }
      });
    }
  }

  ///On Select Category
  void _onSetProprties() {
    setState(() {
      // _extendedAttributes.removeWhere((e) => e.group == "property");
      _listPropertyWidgets = [];
      if (_category != null) {
        _category?.groups?.forEach((group) {
          group.properties
              ?.where(
                  (property) => property.propertyType == PropertyType.entity)
              .where((e) =>
                  e.section == _section || e.section == SectionType.saleAndRent)
              .forEach((property) {
            _onSetProperty(property);
            // _listPropertyWidgets.add(PropertyWidgett(
            //     property: property,
            //     extendedAttribute: _extendedAttributes.last));
          });
        });
        setState(() {});
      }
    });
  }

  void _onSetProperty(PropertyModel property) {
    if (!_extendedAttributes.any((element) => element.key == property.key)) {
      if (property.valueType == ValueType.decimal) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: property.key,
            type: ExtendedAttributeType.decimal,
            group: "property",
            propertyId: property.id));
      } else if (property.valueType == ValueType.int) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: property.key,
            type: ExtendedAttributeType.int,
            group: "property",
            propertyId: property.id));
      } else if (property.valueType == ValueType.double) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: property.key,
            type: ExtendedAttributeType.double,
            group: "property",
            propertyId: property.id));
      } else if (property.valueType == ValueType.dateTime) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: property.key,
            type: ExtendedAttributeType.dateTime,
            group: "property",
            propertyId: property.id));
      } else if (property.valueType == ValueType.text) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: property.key,
            type: ExtendedAttributeType.text,
            group: "property",
            propertyId: property.id));
      }
    }
    _listPropertyWidgets.add(const SizedBox(height: 16));
    _listPropertyWidgets.add(PropertyWidgett(
        property: property,
        extendedAttribute: _extendedAttributes
            .singleWhere((element) => element.key == property.key)
            .copyWith(propertyId: property.id)));
  }

  ///On Select Category
  void _onSelectSubCategory() async {
    UtilOther.hiddenKeyboard(context);
    bool isExit = false;
    CategoryModel? mainCategory;
    while (!isExit &&
        (mainCategory == null ||
            (mainCategory.type == CategoryType.main &&
                (_listCategories
                    .where((item) => item.parentId == mainCategory?.id)
                    .isNotEmpty)))) {
      FocusManager.instance.primaryFocus?.unfocus();
      final selected = await Navigator.pushNamed(
        context,
        Routes.picker,
        arguments: PickerModel(
          name: Translate.of(context).translate('choose_category'),
          selected: [_subCategory],
          data: mainCategory != null
              ? _listCategories
                  .where((item) => item.parentId == mainCategory?.id)
                  .toList()
              : _listCategories.where((item) => item.parentId == null).toList(),
        ),
      );
      if (selected != null && selected is CategoryModel) {
        mainCategory = selected;
        if (selected.type == CategoryType.sub) {
          _subCategory = selected;
          _onSetProprties();
        } else {
          if (mainCategory.type == CategoryType.main &&
              (_listCategories
                  .where((item) => item.parentId == mainCategory?.id)
                  .isEmpty)) {
            FocusManager.instance.primaryFocus?.unfocus();
            final selected = await Navigator.pushNamed(
              context,
              Routes.picker,
              arguments: PickerModel(
                name: Translate.of(context).translate('choose_category'),
                selected: [_subCategory],
                data: mainCategory != null
                    ? _listCategories
                        .where((item) => item.parentId == mainCategory?.id)
                        .toList()
                    : _listCategories
                        .where((item) => item.parentId == null)
                        .toList(),
              ),
            );
          }
        }
        _errorSubCategory = null;
        setState(() {});
      } else if (selected is bool && selected == true) {
        isExit = true;
        setState(() {
          _errorSubCategory =
              "${Translate.of(context).translate('category')} ${Translate.of(context).translate('must_be_selected')}";
        });
      } else {
        setState(() {
          _errorSubCategory =
              "${Translate.of(context).translate('category')} ${Translate.of(context).translate('must_be_selected')}";
        });
      }
    }
  }

  ///On Select Category
  void _onSelectCategory() async {
    UtilOther.hiddenKeyboard(context);
    FocusManager.instance.primaryFocus?.unfocus();
    if (_subCategory == null) {
      AppBloc.messageCubit.onShow(Translate.of(context)
          .translate('the_category_must_be_selected_first'));
      return;
    }
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('choose_category'),
        selected: [_category],
        data: _listCategories
            .where((item) => item.parentId == _subCategory!.id)
            .toList(),
      ),
    );
    if (selected != null) {
      _category = selected as CategoryModel;
      if (_category!.hasColors) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: 'color', text: 'FF000000', group: 'color'));
        _colors = [Colors.black];
      } else {
        if (_extendedAttributes.any((element) => element.key == 'color')) {
          _extendedAttributes.remove(_extendedAttributes
              .singleWhere((element) => element.key == 'color'));
        }
        _colors!.remove(_colors!.first);
      }
      _onSetProprties();
      // setState(() {});
    }
  }

  ///Select Brand
  Future<void> _onSelectBrand() async {
    UtilOther.hiddenKeyboard(context);

    FocusManager.instance.primaryFocus?.unfocus();
    if (_category == null) {
      AppBloc.messageCubit.onShow(
          Translate.of(context).translate('please_select_the_category_first'));
      return;
    }
    if (!_category!.hasBrands) {
      AppBloc.messageCubit.onShow(Translate.of(context)
          .translate('the_brand_cannot_be_specified_for_this_category!'));
      return;
    }
    if (_category!.brands == null || _category!.brands!.isEmpty) {
      AppBloc.messageCubit
          .onShow(Translate.of(context).translate('there_are_no_brands!'));
      return;
    }
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('choose_brand'),
        selected: [_brand],
        data: _category!.brands!,
      ),
    );
    if (selected != null && selected is BrandModel) {
      setState(() {
        _brand = selected;
        _errorBrand = null;
      });
      _onSetProprties();
    } else {
      setState(() {
        _errorBrand =
            "${Translate.of(context).translate('brand')} ${Translate.of(context).translate('must_be_selected')}";
      });
    }
  }

  ///Select Section
  Future<void> _onSelectSection() async {
    UtilOther.hiddenKeyboard(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [
            _section == SectionType.rent
                ? Translate.of(context).translate('rent')
                : Translate.of(context).translate('sale')
          ],
          data: [
            Translate.of(context).translate('sale'),
            Translate.of(context).translate('rent'),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _section = result == Translate.of(context).translate('rent')
            ? SectionType.rent
            : SectionType.sale;
      });
      _onSetProprties();
    }
  }

  // ///On Input Tag
  void _onChooseTag() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.tagsPicker,
      arguments: _tags,
    );
    if (result != null && result is List<String>) {
      setState(() {
        _tags = result;
      });
    }
  }

  ///On Select state
  void _onSelectState() async {
    UtilOther.hiddenKeyboard(context);
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
    UtilOther.hiddenKeyboard(context);
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

  ///On Select currency
  void _onSelectCurrency() async {
    UtilOther.hiddenKeyboard(context);
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        name: Translate.of(context).translate('choose_currency'),
        selected: [_currency],
        data: Application.submitSetting.currencies,
      ),
    );
    if (selected != null && selected is CurrencyModel) {
      setState(() {
        _currency = selected;
        _textMainPriceController.text =
            double.tryParse(_textPriceController.text) != null
                ? (double.parse(_textPriceController.text) *
                        (_currency?.exchange ?? 1))
                    .toString()
                : "";
      });
    }
  }

  ///On Select Address
  void _onSelectAddress() async {
    UtilOther.hiddenKeyboard(context);
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

  ///On Select Color
  void _onSelectColor(int index) async {
    UtilOther.hiddenKeyboard(context);
    final result = await showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        Color? selected;
        return AlertDialog(
          title: Text(Translate.of(context).translate('choose_color')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Theme.of(context).primaryColor,
              onColorChanged: (color) {
                selected = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.pop(context);
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('apply'),
              onPressed: () {
                Navigator.pop(context, selected);
              },
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _colors![index] = result;
        _extendedAttributes
            .where((element) => element.key == 'color')
            .toList()[index]
            .text = result.toHex;
      });
    }
  }

  ///Show Picker Time
  void _onShowDatePicker() async {
    UtilOther.hiddenKeyboard(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      initialDate: now,
      firstDate: DateTime(now.year),
      context: context,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _date = picked.dateView;
      });
    }
  }

  // ///On Select Open Time
  // void _onOpenTime() async {
  //   final result = await Navigator.pushNamed(
  //     context,
  //     Routes.openTime,
  //     arguments: _time,
  //   );
  //   if (result != null && result is List<OpenTimeModel>) {
  //     setState(() {
  //       _time = result;
  //     });
  //   }
  // }

  ///Select social network
  void _onSocialNetwork() async {
    UtilOther.hiddenKeyboard(context);
    final result = await Navigator.pushNamed(
      context,
      Routes.socialNetwork,
      arguments: _socials,
    );
    if (result != null && result is Map<String, dynamic>) {
      _socials = result;
      _extendedAttributes.removeWhere((item) => item.group == "social");
      _socials.forEach((key, value) {
        _extendedAttributes.add(ExtendedAttributeModel(
            key: key,
            type: ExtendedAttributeType.text,
            text: value,
            group: "social"));
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
      _extendedAttributes.removeWhere((ex) => ex.group == "property");
      for (var p in _listPropertyWidgets) {
        if (p is PropertyWidgett) {
          _extendedAttributes.add(p.extendedAttribute!);
        }
      }

      final result = await AppBloc.submitCubit.onSubmit(
        id: widget.item?.id,
        name: _textNameController.text,
        tradeName: _textTradeNameController.text,
        baracode: _textBaracodeController.text,
        section: _section,
        content: _textContentController.text,
        country: Application.currentCountry,
        state: _state,
        city: _city,
        date: _date,
        image: _image ?? '',
        currency: _currency!,
        priceType: _priceType,
        price: _textPriceController.text,
        hasDiscount: _hasDiscount,
        discount:
            _hasDiscount ? double.parse(_textDiscountController.text) : null,
        gps: _gps,
        // tags: _tags,
        subCategory: _subCategory!,
        category: _category!,
        brand: _brand,
        extendedAttributes: _extendedAttributes,
        // time: _time,
      );
      if (result) {
        _onSuccess();
      }
    }
  }

  ///On Success
  void _onSuccess() {
    Navigator.pushReplacementNamed(context, Routes.submitSuccess);
  }

  ///valid data
  bool _validData() {
    ///Title
    _errorName = UtilValidator.validate(
      _textNameController.text,
    );

    ///Discount
    _errorDiscount = UtilValidator.validate(
      type: ValidateType.realNumber,
      max: 99,
      min: 1,
      allowEmpty: !_hasDiscount,
      _textDiscountController.text,
    );

    ///State
    _errorState = _state == null
        ? "${Translate.of(context).translate('state')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///City
    _errorCity = _city == null
        ? "${Translate.of(context).translate('city')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///Currency
    _errorCurrency = _currency == null
        ? "${Translate.of(context).translate('currency')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///Sub Category
    if (_subCategory == null) {
      _errorSubCategory = _subCategory == null
          ? "${Translate.of(context).translate('category')} ${Translate.of(context).translate('must_be_selected')}"
          : null;
    }

    ///Category
    if (_category == null) {
      _errorCategory = _category == null
          ? "${Translate.of(context).translate('category')} ${Translate.of(context).translate('must_be_selected')}"
          : null;
    }

    for (var property in _listPropertyWidgets) {
      if (property is PropertyWidgett) {
        property._validData();
      }
    }

    ///Brand
    if (_category?.hasBrands ?? false) {
      _errorBrand = _brand == null
          ? "${Translate.of(context).translate('brand')} ${Translate.of(context).translate('must_be_selected')}"
          : null;
    } else {
      _errorBrand = null;
    }

    ///Gps
    _errorGps = _gps == null && (_category?.hasMap ?? false)
        ? "${Translate.of(context).translate('location_coordinates')} ${Translate.of(context).translate('must_be_selected')}"
        : null;

    ///Sizes
    if (_textSizesController.isNotEmpty) {
      for (int i = 0; i < _textSizesController.length; i++) {
        _errorSizes[i] = UtilValidator.validate(
          _textSizesController[i].text,
        );
      }
    }

    ///Prices
    if (_textPricesController.isNotEmpty) {
      for (int i = 0; i < _textPricesController.length; i++) {
        _errorPrices[i] = UtilValidator.validate(
          _textPricesController[i].text,
          type: ValidateType.number,
          allowEmpty: false,
        );
      }
    }

    ///Youtube Video
    _errorYoutubeVideo = UtilValidator.validate(
      _textYoutubeVideoController.text,
      type: ValidateType.url,
      allowEmpty: true,
    );

    ///Address
    _errorAddress = UtilValidator.validate(_textAddressController.text,
        allowEmpty: (_category?.hasMap ?? false) ? false : true);

    ///Whatsapp
    _errorWhatsapp = UtilValidator.validate(
      _textWhatsappController.text,
      type: ValidateType.number,
      allowEmpty: true,
    );

    ///Phone
    _errorPhone = UtilValidator.validate(
      _textPhoneController.text,
      type: ValidateType.phone,
      allowEmpty: true,
    );

    ///Price
    _errorPrice = UtilValidator.validate(
      _textPriceController.text,
      type: ValidateType.number,
      allowEmpty: false,
    );

    if (_errorName != null ||
        _errorDiscount != null ||
        _errorState != null ||
        _errorCity != null ||
        _errorCurrency != null ||
        _errorSubCategory != null ||
        _errorCategory != null ||
        // _errorBrand != null ||
        _errorGps != null ||
        _errorYoutubeVideo != null ||
        _errorAddress != null ||
        _errorPhone != null ||
        _errorStatus != null ||
        _errorPrice != null ||
        _errorSizes.any((element) => element != null) ||
        _errorPrices.any((element) => element != null) ||
        _listPropertyWidgets.any((e) =>
                e is PropertyWidgett &&
                e.errorWedgit != null &&
                e.errorWedgit != "") ==
            true) {
      setState(() {});
      return false;
    }

    ///Feature image
    if (_image == null) {
      AppBloc.messageCubit.onShow('main_image_require');
      return false;
    }

    return true;
  }

  ///Build gallery
  Widget _buildGallery() {
    DecorationImage? decorationImage;
    IconData icon = Icons.add;
    if (_extendedAttributes.any((e) => e.key == "gallery")) {
      icon = Icons.dashboard_customize_outlined;
      decorationImage = DecorationImage(
        image: NetworkImage(
          Application.domain +
              _extendedAttributes
                  .where((e) => e.key == "gallery")
                  .first
                  .text!
                  .replaceAll("\\", "/")
                  .replaceAll("TYPE", "full"),
        ),
        fit: BoxFit.cover,
      );
    }
    return InkWell(
      onTap: _onUploadGallery,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        color: Theme.of(context).primaryColor,
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: decorationImage,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  ///Build content
  Widget _buildContent() {
    String textActionOpenTime = Translate.of(context).translate('add');
    // Widget icon = Icon(
    //   Icons.help_outline,
    //   color: Theme.of(context).hintColor,
    // );
    // if (_time != null) {
    //   textActionOpenTime = Translate.of(context).translate('edit');
    // }
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
            SizedBox(
              height: 180,
              child: AppUploadImage(
                title: Translate.of(context).translate('upload_main_image'),
                type: UploadType.product,
                isTemp: true,
                image: _image,
                onChange: (result) {
                  setState(() {
                    _image = result;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildGallery(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('product_name'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_product_name'),
              errorText: _errorName,
              controller: _textNameController,
              focusNode: _focusName,
              textInputAction: TextInputAction.next,
              onChanged: (text) {
                setState(() {
                  _errorName = UtilValidator.validate(
                    _textNameController.text,
                  );
                });
              },
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textNameController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('trade_name'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_trade_name'),
              controller: _textTradeNameController,
              focusNode: _focusTradeName,
              textInputAction: TextInputAction.next,
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textTradeNameController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('baracode'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_baracode'),
              controller: _textBaracodeController,
              focusNode: _focusBaracode,
              textInputAction: TextInputAction.next,
              trailing: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textBaracodeController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () async {
                        // String barcodeScanRes =
                        //     await FlutterBarcodeScanner.scanBarcode(
                        //         "0xFF000000",
                        //         Translate.of(context).translate('cancel'),
                        //         true,
                        //         ScanMode.BARCODE);
                        // if (barcodeScanRes.isNotEmpty) {
                        //   _textBaracodeController.text = barcodeScanRes;
                        // }
                      },
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
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
              Translate.of(context).translate('category'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              title: _errorSubCategory ??
                  Translate.of(context).translate('choose_category'),
              value: _subCategory?.name,
              color: _errorSubCategory != null
                  ? Theme.of(context).errorColor
                  : null,
              onPressed: _onSelectSubCategory,
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('label'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              title: _errorCategory ??
                  Translate.of(context).translate('choose_lebel'),
              value: _category?.name,
              color:
                  _errorCategory != null ? Theme.of(context).errorColor : null,
              onPressed: _onSelectCategory,
            ),
            if (_category?.enableRent ?? false) ...[
              const SizedBox(height: 16),
              Text(
                Translate.of(context).translate('section'),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppPickerItem(
                title: Translate.of(context).translate('choose_section'),
                value: _section == SectionType.rent
                    ? Translate.of(context).translate('rent')
                    : Translate.of(context).translate('sale'),
                onPressed: () async {
                  await _onSelectSection();
                },
              ),
            ],
            if (_category?.hasBrands ?? false) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translate.of(context).translate('brand'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      AppPickerItem(
                        // leading: _icon?.icon ?? icon,
                        title: _errorBrand ??
                            Translate.of(context).translate('choose_brand'),
                        value: _brand?.name ?? "",
                        color: _errorBrand != null
                            ? Theme.of(context).errorColor
                            : null,
                        onPressed: () async {
                          await _onSelectBrand();
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (_category != null) Column(children: _listPropertyWidgets),
            const SizedBox(height: 8),
            if (_category?.hasColors ?? false) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.3,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Wrap(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('colors'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () {
                                _colors ??= [];
                                _colors!.add(Colors.black);
                                _extendedAttributes
                                    .add(ExtendedAttributeModel(key: 'color'));
                                setState(() {});
                              },
                              icon: const Icon(Icons.add, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_colors != null && _colors!.isNotEmpty) ...[
                        for (int i = 0; i < _colors!.length; i++) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AppPickerItem(
                                    leading: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _colors![i],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    value: _colors![i].value.toRadixString(16),
                                    title: Translate.of(context).translate(
                                      'choose_color',
                                    ),
                                    onPressed: () {
                                      _onSelectColor(_colors!.lastIndexWhere(
                                          (element) => element == _colors![i]));
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _colors!.remove(_colors![i]);
                                    _extendedAttributes.remove(
                                        _extendedAttributes
                                            .where((element) =>
                                                element.key == 'color')
                                            .toList()[i]);

                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 0.3,
                  style: BorderStyle.solid,
                ),
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Wrap(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            Translate.of(context).translate('price'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Scrollbar(
                        child: ToggleSwitch(
                          minWidth: double.infinity,
                          initialLabelIndex: _priceType.index,
                          totalSwitches: 2,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Theme.of(context).dividerColor,
                          labels: [
                            Translate.of(context).translate('fixed'),
                            Translate.of(context).translate('by_size'),
                          ],
                          onToggle: (index) {
                            _priceType =
                                index == 0 ? PriceType.fixed : PriceType.bySize;
                            if (_priceType == PriceType.bySize) {
                              for (var item in _extendedAttributes
                                  .where((element) => element.key == 'size')) {
                                _textPricesController.add(TextEditingController(
                                    text: item.double_ == null
                                        ? _textPriceController.text
                                        : item.double_.toString()));
                                _focusPrices.add(FocusNode());
                                _errorPrices.add(null);
                              }
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          if (_priceType == PriceType.fixed) ...[
                            Expanded(
                              flex: 2,
                              child: AppTextInput(
                                hintText: Translate.of(context).translate(
                                  'input_price',
                                ),
                                errorText: _errorPrice,
                                controller: _textPriceController,
                                focusNode: _focusPrice,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onChanged: (text) {
                                  setState(() {
                                    _textMainPriceController
                                        .text = double.tryParse(
                                                _textPriceController.text) !=
                                            null
                                        ? (double.parse(
                                                    _textPriceController.text) *
                                                (_currency?.exchange ?? 1))
                                            .toString()
                                        : "";
                                    _errorPrice = UtilValidator.validate(
                                      _textPriceController.text,
                                      type: ValidateType.number,
                                      max: Application.setting.maxPrice,
                                      min: Application.setting.minPrice,
                                      allowEmpty: false,
                                    );
                                  });
                                },
                                onSubmitted: (text) {},
                                leading: Icon(
                                  Icons.price_change_outlined,
                                  color: Theme.of(context).hintColor,
                                ),
                                // trailing: TextButton(
                                //   onPressed: _onSelectCurrency,
                                //   child: Text(_currency!.code),
                                // ),
                                trailing: GestureDetector(
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTap: () {
                                    _textPriceController.clear();
                                    setState(() {});
                                  },
                                  child: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            constraints: _priceType == PriceType.fixed
                                ? null
                                : const BoxConstraints(maxWidth: 150),
                            child: Expanded(
                              child: AppPickerItem(
                                title: _errorCurrency ??
                                    Translate.of(context)
                                        .translate('choose_currency'),
                                value: _currency?.code,
                                color: _errorCurrency != null
                                    ? Theme.of(context).errorColor
                                    : null,
                                withTooltip: true,
                                onPressed: _onSelectCurrency,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_textPriceController.text.isNotEmpty &&
                        _currency?.isDefault == false) ...[
                      const SizedBox(height: 4),
                      AppTextInput(
                        hintText: Translate.of(context).translate(
                          'price_in_default_currency',
                        ),
                        controller: _textMainPriceController,
                        // focusNode: _focusMainPrice,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: (text) {
                          // setState(() {
                          // });
                        },
                        onSubmitted: (text) {
                          // UtilOther.fieldFocusChange(
                          //   context,
                          //   _focusPrice,
                          //   _focusPriceMax,
                          // );
                        },
                        leading: Icon(
                          Icons.price_change_outlined,
                          color: Theme.of(context).hintColor,
                        ),
                        readOnly: true,
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('sizes'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () {
                              _extendedAttributes.add(ExtendedAttributeModel(
                                  key: 'size',
                                  type: ExtendedAttributeType.text,
                                  group: 'sizes'));
                              _textSizesController.add(TextEditingController());
                              _focusSizes.add(FocusNode());
                              _errorSizes.add(null);
                              if (_priceType == PriceType.bySize) {
                                _textPricesController
                                    .add(TextEditingController());
                                _focusPrices.add(FocusNode());
                                _errorPrices.add(null);
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.add, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_textSizesController.isNotEmpty) ...[
                      for (int i = 0; i < _textSizesController.length; i++) ...[
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.3,
                                  style: BorderStyle.solid,
                                ),
                                // color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.rectangle,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child:
                                    // Row(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: [
                                    //     Expanded(
                                    //       child:

                                    Wrap(
                                  // mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: AppTextInput(
                                          hintText: Translate.of(context)
                                              .translate('input_size'),
                                          errorText: _errorSizes[i],
                                          controller: _textSizesController[i],
                                          focusNode: _focusSizes[i],
                                          textInputAction: TextInputAction.done,
                                          onChanged: (text) {
                                            setState(() {
                                              _errorSizes[i] =
                                                  UtilValidator.validate(
                                                      _textSizesController[i]
                                                          .text,
                                                      allowEmpty: false);
                                              _extendedAttributes
                                                  .where((item) =>
                                                      item.key == 'size')
                                                  .toList()[i]
                                                  .text = text;
                                            });
                                          },
                                          leading: Icon(
                                            Icons.format_size,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          trailing: GestureDetector(
                                            dragStartBehavior:
                                                DragStartBehavior.down,
                                            onTap: () {
                                              _textSizesController[i].clear();
                                            },
                                            child: const Icon(Icons.clear),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_priceType == PriceType.bySize)
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: AppTextInput(
                                              hintText: Translate.of(context)
                                                  .translate('price'),
                                              errorText: _errorPrices[i],
                                              controller:
                                                  _textPricesController[i],
                                              focusNode: _focusPrices[i],
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onChanged: (text) {
                                                setState(() {
                                                  _errorPrices[i] =
                                                      UtilValidator.validate(
                                                          _textPricesController[
                                                                  i]
                                                              .text,
                                                          type: ValidateType
                                                              .number,
                                                          allowEmpty: false);
                                                  _extendedAttributes
                                                          .where(
                                                              (item) =>
                                                                  item.key ==
                                                                  'size')
                                                          .toList()[i]
                                                          .double_ =
                                                      double.tryParse(text);
                                                  if (i == 0) {
                                                    _textPriceController.text =
                                                        text;
                                                  }
                                                });
                                              },
                                              leading: Icon(
                                                Icons.price_change_outlined,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              trailing: GestureDetector(
                                                dragStartBehavior:
                                                    DragStartBehavior.down,
                                                onTap: () {
                                                  _textPricesController[i]
                                                      .clear();
                                                },
                                                child: const Icon(Icons.clear),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                //   ),
                                // ],
                                // ),
                              ),
                            ),
                            if ((i != 0 && _priceType == PriceType.bySize) ||
                                _priceType == PriceType.fixed)
                              Positioned(
                                left: AppLanguage.isRTL() ? 0 : null,
                                right: AppLanguage.isRTL() ? null : 0,
                                top: 0,
                                child: InkWell(
                                  // padding: const EdgeInsets.all(0),
                                  // iconSize: double.infinity,
                                  onTap: () {
                                    _extendedAttributes.remove(
                                        _extendedAttributes
                                            .where((item) => item.key == 'size')
                                            .toList()[i]);
                                    _textSizesController
                                        .remove(_textSizesController[i]);
                                    _focusSizes.remove(_focusSizes[i]);
                                    _errorSizes.remove(_errorSizes[i]);
                                    _textPricesController
                                        .remove(_textPricesController[i]);
                                    _focusPrices.remove(_focusPrices[i]);
                                    _errorPrices.remove(_errorPrices[i]);

                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ],
                    ],
                    if (_priceType == PriceType.bySize)
                      Row(
                        children: [
                          Text(
                            Translate.of(context).translate(
                                'the_first_price_is_set_as_the_default_price'),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Colors.blue),
                          )
                        ],
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _hasDiscount = !_hasDiscount;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Translate.of(context)
                                      .translate('has_discount'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Checkbox(
                                  value: _hasDiscount,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasDiscount = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_hasDiscount)
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: AppTextInput(
                                hintText: Translate.of(context)
                                    .translate('discount_rate'),
                                errorText: _errorDiscount,
                                controller: _textDiscountController,
                                focusNode: _focusDiscount,
                                keyboardType: TextInputType.number,
                                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textInputAction: TextInputAction.next,
                                onChanged: (text) {
                                  setState(() {
                                    _errorDiscount = UtilValidator.validate(
                                      type: ValidateType.realNumber,
                                      max: 99,
                                      min: 1,
                                      allowEmpty: !_hasDiscount,
                                      _textDiscountController.text,
                                    );
                                  });
                                },
                                trailing: GestureDetector(
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTap: () {
                                    _textDiscountController.clear();
                                  },
                                  child: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      paymentActivation = !paymentActivation;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Translate.of(context).translate('payment_activation'),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Checkbox(
                        value: paymentActivation,
                        onChanged: (value) {
                          setState(() {
                            paymentActivation = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('the_explanation'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              maxLines: 10,
              hintText: Translate.of(context).translate('input_explanation'),
              controller: _textContentController,
              focusNode: _focusContent,
              textInputAction: TextInputAction.done,
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textContentController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 8),
            AppTextInput(
              hintText:
                  Translate.of(context).translate('input_youtube_video_url'),
              errorText: _errorYoutubeVideo,
              controller: _textYoutubeVideoController,
              focusNode: _focusYoutubeVideo,
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                setState(() {
                  _errorYoutubeVideo = UtilValidator.validate(
                      _textYoutubeVideoController.text,
                      type: ValidateType.url,
                      allowEmpty: true);
                  if (!_extendedAttributes
                      .any((item) => item.key == "youtube_video_url")) {
                    _extendedAttributes.add(ExtendedAttributeModel(
                        key: "youtubeVideo",
                        type: ExtendedAttributeType.text,
                        text: _textYoutubeVideoController.text,
                        group: "video"));
                  }
                  _extendedAttributes
                      .singleWhere((item) => item.key == "youtubeVideo")
                      .text = _textYoutubeVideoController.text;
                });
              },
              // onSubmitted: (text) {
              //   UtilOther.fieldFocusChange(
              //     context,
              //     _focusYoutubeVideo,
              //     _focusAddress,
              //   );
              // },
              leading: Icon(
                Icons.video_camera_back_outlined,
                color: Theme.of(context).hintColor,
              ),
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textYoutubeVideoController.clear();
                },
                child: const Icon(Icons.clear),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (_category?.hasMap ?? false) ...[
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
              const SizedBox(height: 8),
              AppTextInput(
                hintText: Translate.of(context).translate('input_address'),
                errorText: _errorAddress,
                controller: _textAddressController,
                focusNode: _focusAddress,
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  setState(() {
                    _errorAddress = UtilValidator.validate(
                      _textAddressController.text,
                    );
                    if (!_extendedAttributes
                        .any((item) => item.key == "address")) {
                      _extendedAttributes.add(ExtendedAttributeModel(
                          key: "address",
                          type: ExtendedAttributeType.text,
                          text: _textAddressController.text,
                          group: "concat"));
                    }
                    _extendedAttributes
                        .singleWhere((item) => item.key == "address")
                        .text = _textAddressController.text;
                  });
                },
                onSubmitted: (text) {
                  UtilOther.fieldFocusChange(
                    context,
                    _focusAddress,
                    _focusWhatsapp,
                  );
                },
                leading: Icon(
                  Icons.home_outlined,
                  color: Theme.of(context).hintColor,
                ),
                trailing: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    _textAddressController.clear();
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ],
            const SizedBox(height: 8),
            AppTextInput(
              hintText: Translate.of(context).translate('input_whatsapp'),
              errorText: _errorWhatsapp,
              controller: _textWhatsappController,
              focusNode: _focusWhatsapp,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                setState(() {
                  _errorWhatsapp = UtilValidator.validate(
                    _textWhatsappController.text,
                    type: ValidateType.number,
                    allowEmpty: true,
                  );
                  if (!_extendedAttributes
                      .any((item) => item.key == "whatsapp")) {
                    _extendedAttributes.add(ExtendedAttributeModel(
                        key: "whatsapp",
                        type: ExtendedAttributeType.text,
                        text: _textWhatsappController.text,
                        group: "concat"));
                  }
                  _extendedAttributes
                      .singleWhere((item) => item.key == "whatsapp")
                      .text = _textWhatsappController.text;
                });
              },
              onSubmitted: (text) {
                UtilOther.fieldFocusChange(
                  context,
                  _focusWhatsapp,
                  _focusPhone,
                );
              },
              leading: Icon(
                Icons.home_outlined,
                color: Theme.of(context).hintColor,
              ),
              trailing: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  _textWhatsappController.clear();
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
                    allowEmpty: true,
                  );
                  if (!_extendedAttributes.any((item) => item.key == "phone")) {
                    _extendedAttributes.add(ExtendedAttributeModel(
                        key: "phone",
                        type: ExtendedAttributeType.text,
                        text: _textPhoneController.text,
                        group: "concat"));
                  }
                  _extendedAttributes
                      .singleWhere((item) => item.key == "phone")
                      .text = _textPhoneController.text;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translate.of(context).translate('social_network'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _onSocialNetwork,
                  child: Text(
                    textActionOpenTime,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String textTitle = Translate.of(context).translate('add_new_listing');
    String textAction = Translate.of(context).translate('add');
    if (widget.item != null) {
      textTitle = Translate.of(context).translate('update_listing');
      textAction = Translate.of(context).translate('update');
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(textTitle),
          actions: [
            AppButton(
              textAction,
              onPressed: _onSubmit,
              type: ButtonType.text,
            )
          ],
        ),
        body: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }
}

class PropertyWidgett extends StatelessWidget {
  late BuildContext context;
  final PropertyModel property;
  late String? errorWedgit;
  final ExtendedAttributeModel? extendedAttribute;
  final TextEditingController _controle = TextEditingController();

  PropertyWidgett({Key? key, required this.property, this.extendedAttribute})
      : super(key: key) {
    errorWedgit = "";
  }
  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (property.fieldType == FieldType.textInput) {
      return _buildtextInputProperty();
    } else if (property.fieldType == FieldType.itemPicker) {
      return _builditemPickerProperty();
    } else if (property.fieldType == FieldType.itemsPicker) {
      return _builditemsPickerProperty();
    } else if (property.fieldType == FieldType.slider) {
      return _buildSlider();
    } else if (property.fieldType == FieldType.rangSlider) {
      return _buildRangSlider();
    } else if (property.fieldType == FieldType.checkBox) {
      return _buildCheckBox();
    }
    return Container();
  }

  ///valid data
  bool _validData() {
    if (property.isRequired) {
      if (extendedAttribute!.getValue() == null ||
          extendedAttribute!.getValue().toString().isEmpty) {
        if (property.fieldType == FieldType.textInput) {
          errorWedgit = Translate.of(context).translate('value_not_empty');
        } else if (property.fieldType == FieldType.itemPicker) {
          errorWedgit = Translate.of(context).translate('must_be_selected');
        } else if (property.fieldType == FieldType.itemsPicker) {
          errorWedgit = Translate.of(context).translate('must_be_selected');
        } else {
          errorWedgit = null;
        }
      } else {
        errorWedgit = null;
      }
    }
    (context as Element).markNeedsBuild();
    return true;
  }

// Text input
  Widget _buildtextInputProperty() {
    _controle.text = extendedAttribute!.getValue()?.toString() ?? "";

    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
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
              message: errorWedgit != null &&
                      errorWedgit!.isNotEmpty &&
                      extendedAttribute!.getValue() == null
                  ? Translate.of(context).translate(property.inputPlacement)
                  : extendedAttribute!.getValue()?.toString() ?? "",
              child: AppTextInput(
                hintText:
                    Translate.of(context).translate(property.inputPlacement),
                errorText: errorWedgit,
                controller: _controle,
                keyboardType: property.valueType == ValueType.text
                    ? TextInputType.text
                    : TextInputType.number,
                inputFormatters: property.valueType == ValueType.int ||
                        property.valueType == ValueType.decimal
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  extendedAttribute!.setValue(text);
                  errorWedgit = UtilValidator.validate(
                    text,
                    type: property.valueType == ValueType.int
                        ? ValidateType.realNumber
                        : property.valueType == ValueType.double
                            ? ValidateType.number
                            : ValidateType.normal,
                    max: property.max == 0 ? null : property.max,
                    min: property.min == 0 ? null : property.min,
                    allowEmpty: !property.isRequired,
                  );
                  // (context as Element).markNeedsBuild();
                },
                trailing: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    _controle.clear();
                    extendedAttribute!.setValue(null);
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

// dropbox input
  Widget _builditemsPickerProperty() {
    List<JsonProperty> selectedList = [];
    extendedAttribute!.getValue()?.toString().split(',').forEach((item) {
      if (property.json.any((j) => j.value == item.toString())) {
        selectedList
            .add(property.json.singleWhere((j) => j.value == item.toString()));
      }
    });

    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate(property.name),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              leading: Icon(
                Icons.bedroom_parent_outlined,
                color: Theme.of(context).hintColor,
              ),
              value:
                  selectedList.map((e) => e.name /** title => key */).join(','),
              title: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? errorWedgit!
                  : Translate.of(context).translate(property.inputPlacement),
              color: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? Theme.of(context).errorColor
                  : null,
              onPressed: () {
                _onSelectPropertyItems();
              },
            ),
            if (errorWedgit != null)
              Text(
                errorWedgit!,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Theme.of(context).errorColor),
              )
          ],
        ),
      ),
    ]);
  }

  ///Select Property Items
  void _onSelectPropertyItems() async {
    List<JsonProperty> selectedList = [];
    extendedAttribute!.getValue()?.toString().split(',').forEach((item) {
      if (property.json.any((j) => j.value == item.toString())) {
        selectedList
            .add(property.json.singleWhere((j) => j.value == item.toString()));
      }
    });
    final result = await Navigator.pushNamed(
      context,
      Routes.categoryPicker,
      arguments: PickerModel(
        name: Translate.of(context).translate(property.name),
        selected: selectedList,
        data: property.json,
      ),
    );
    if (result != null && result is List<JsonProperty>) {
      extendedAttribute!.setValue(result.map((e) => e.value).join(','));
      _validData();
      (context as Element).markNeedsBuild();
    }
  }

// dropbox input
  Widget _builditemPickerProperty() {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate(property.name),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              leading: Icon(
                Icons.bedroom_parent_outlined,
                color: Theme.of(context).hintColor,
              ),
              value: property.json
                      .any((j) => j.value == extendedAttribute!.text)
                  ? property.json
                      .singleWhere((j) => j.value == extendedAttribute!.text)
                      .name
                  : "",
              title: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? errorWedgit!
                  : Translate.of(context).translate(property.inputPlacement),
              color: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? Theme.of(context).errorColor
                  : null,
              onPressed: () async {
                await _onSelectPropertyItem();
              },
            ),
            if (errorWedgit != null)
              Text(
                errorWedgit!,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Theme.of(context).errorColor),
              )
          ],
        ),
      ),
    ]);
  }

  ///Select Property Items
  Future<void> _onSelectPropertyItem() async {
    final result = await showModalBottomSheet<JsonProperty?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [
            property.json.any((e) => e.value == extendedAttribute!.getValue())
                ? property.json.singleWhere(
                    (e) => e.value == extendedAttribute!.getValue())
                : null
          ],
          data: property.json,
        ),
        hasScroll: true,
      ),
    );

    if (result != null) {
      var propertySelected =
          property.json.singleWhere((e) => e.name == result.name);
      extendedAttribute!.setValue(propertySelected.value);
      _validData();
      (context as Element).markNeedsBuild();
    }
  }

  ///Create Slider
  Widget _buildSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        Text(
          Translate.of(context).translate(property.name),
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
              property.min.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              extendedAttribute!.double_?.toString() ?? property.max.toString(),
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        SizedBox(
            height: 8,
            child: Slider(
              value: extendedAttribute!.double_?.toDouble() ?? property.max,
              max: property.max,
              min: property.min,
              divisions: (property.max - property.min).toInt(),
              inactiveColor: Theme.of(context).colorScheme.secondary,
              label: '${extendedAttribute!.double_ ?? 0}',
              onChanged: (value) {
                extendedAttribute!.double_ = value;
                (context as Element).markNeedsBuild();
              },
            )),
        if (errorWedgit != null && errorWedgit!.isNotEmpty)
          Text(
            errorWedgit!,
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: Theme.of(context).errorColor),
          )
      ],
    );
  }

  ///Create Range Slider
  Widget _buildRangSlider() {
    extendedAttribute!.rangMin ??= property.min;
    extendedAttribute!.rangMax ??= property.max;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate(property.name),
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
                    extendedAttribute!.rangMin ?? property.min,
                    extendedAttribute!.rangMax ?? property.max,
                  ),
                  divisions: (property.max - property.min).toInt(),
                  inactiveColor: Theme.of(context).colorScheme.secondary,
                  labels: RangeLabels(
                    property.min.toString(),
                    property.max.toString(),
                  ),
                  onChanged: (range) {
                    extendedAttribute!.rangMin = range.start;
                    extendedAttribute!.rangMax = range.end;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
              if (errorWedgit != null && errorWedgit!.isNotEmpty)
                Text(
                  errorWedgit!,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Theme.of(context).errorColor),
                ),
              if (errorWedgit == null || errorWedgit!.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Translate.of(context).translate(property.inputPlacement),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      '${extendedAttribute!.rangMin ?? property.min} - ${extendedAttribute!.rangMax ?? property.max}',
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  ],
                ),
            ],
          ),
        ]);
  }

  ///Create Check Box
  Widget _buildCheckBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translate.of(context).translate(property.name),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 12,
              child: Checkbox(
                value: extendedAttribute?.bool_ ?? false,
                onChanged: (value) {
                  extendedAttribute?.bool_ = value;
                  (context as Element).markNeedsBuild();
                },
                // setState(() {
                //   extendedAttribute.bool_ = value;
                // }),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class WidgetItem {
  // final PropertyModel property;
  final int propertyId;
  late Widget? widget;
  late Object? value = "";
  late String? errorWedgit;
  late Object? controle = Object;

  WidgetItem({required this.propertyId, this.widget, this.errorWedgit = ""});
}
