import 'package:flutter/material.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

import 'model_feature.dart';
import 'model_location.dart';

class FilterModel {
  String? searchString;
  List<int>? containsList;
  SectionType section;
  CategoryModel? mainCategory;
  CategoryModel? subCategory;
  CategoryModel? category;
  BrandModel? brand;
  List<int>? features;
  List<int>? roomsFilter;
  // CountryModel? country;
  int? locationId;
  double? distance;
  CurrencyModel? currency;
  double? minPriceFilter;
  double? maxPriceFilter;
  FinishingType? finishingType;
  OverlookingType? overlooking;
  // String? color;
  SortModel? sortOptions;
  // TimeOfDay? startHour;
  // TimeOfDay? endHour;
  List<ExtendedAttributeModel>? extendedAttributes = [];
  Map<String, dynamic>? byImage;

  FilterModel({
    this.searchString,
    this.containsList,
    this.section = SectionType.sale,
    this.mainCategory,
    this.subCategory,
    this.category,
    this.brand,
    this.features,
    this.roomsFilter,
    this.locationId,
    this.distance,
    this.minPriceFilter,
    this.maxPriceFilter,
    this.currency,
    this.finishingType,
    this.overlooking,
    // this.color,
    this.sortOptions,
    // this.startHour,
    // this.endHour,
    this.extendedAttributes,
    this.byImage,
  });

  factory FilterModel.fromDefault() {
    return FilterModel(
      searchString: null,
      section: SectionType.sale,
      features: [],
      roomsFilter: [],
      sortOptions: Application.setting.sortOptions.first,
      extendedAttributes: [],
      byImage: {},
      // startHour: Application.setting.startHour,
      // endHour: Application.setting.endHour,
    );
  }

  factory FilterModel.fromSource(source) {
    return FilterModel(
      searchString: source.searchString,
      containsList: source.containsList,
      section: source.section,
      mainCategory: source.mainCategory,
      subCategory: source.subCategory,
      category: source.category,
      brand: source.brand,
      features: List<int>.from(source.features),
      roomsFilter: List<int>.from(source.roomsFilter),
      locationId: source.locationId,
      distance: source.distance,
      minPriceFilter: source.minPriceFilter,
      maxPriceFilter: source.maxPriceFilter,
      currency: source.currency,
      finishingType: source.finishingType,
      overlooking: source.overlooking,
      // color: source.color,
      sortOptions: source.sortOptions,
      // startHour: source.startHour,
      // endHour: source.endHour,
      extendedAttributes: source.extendedAttributes,
      byImage: source.byImage,
    );
  }

  FilterModel clone() {
    return FilterModel.fromSource(this);
  }

  void clear() {
    searchString = null;
    containsList = null;
    section = SectionType.sale;
    mainCategory = null;
    subCategory = null;
    category = null;
    brand = null;
    features?.clear();
    roomsFilter?.clear();
    sortOptions = Application.setting.sortOptions.first;
    locationId = null;
    distance = null;
    minPriceFilter = null;
    maxPriceFilter = null;
    currency = null;
    finishingType = null;
    overlooking = null;
    extendedAttributes = null;
    byImage = null;
  }

  bool isEmpty() {
    if (searchString != null && searchString!.isNotEmpty) return false;
    if (containsList != null && containsList!.isNotEmpty) return false;
    if (section != SectionType.sale) return false;
    if (mainCategory != null) return false;
    if (subCategory != null) return false;
    if (category != null) return false;
    if (brand != null) return false;
    if (features != null && features!.isNotEmpty) return false;
    if (roomsFilter != null && roomsFilter!.isNotEmpty) return false;
    if (locationId != null) return false;
    if (distance != null) return false;
    if (minPriceFilter != null) return false;
    if (maxPriceFilter != null) return false;
    if (currency != null) return false;
    if (finishingType != null) return false;
    if (overlooking != null) return false;
    if (sortOptions != Application.setting.sortOptions.first) return false;
    if (extendedAttributes != null && extendedAttributes!.isNotEmpty)
      return false;
    if (byImage != null && byImage!.isNotEmpty) return false;
    return true;
  }
}
