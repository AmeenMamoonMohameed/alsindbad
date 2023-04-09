import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';

enum ProductViewType { small, grid, list, block, card, smallWithViews, pending }

enum DetailViewType { basic }

final mapListMode = {
  'small': ProductViewType.small,
  'list': ProductViewType.list,
  'grid': ProductViewType.grid,
  'block': ProductViewType.block,
  'card': ProductViewType.card,
};

final detailMode = {
  'basic': DetailViewType.basic,
};

class SettingModel {
  final String defaultCountryPhoneCode;
  final List<SortModel> sortOptions;
  final List<int> roomsFilter; // --
  final int minLengthPhoneNumber;
  final int maxLengthPhoneNumber;
  final int pageSize;
  final ProductViewType listMode;
  final DetailViewType detailViewType;
  final bool enableSubmit;
  final double minPrice;
  final double maxPrice;
  final double minPriceFilter; // --
  final double maxPriceFilter; // --
  final double maxArea;
  final double minArea;
  final double maxAreaFilter; // --
  final double minAreaFilter; // --
  final List<String> color;
  final String unitPrice;
  final String unitArea;
  final int maxFloors;
  final int maxRooms;
  final int maxBaths;
  final int maxYearOfCompletion;
  final int minYearOfCompletion;
  // final TimeOfDay startHour;
  // final TimeOfDay endHour;
  final bool canConfirmBySms;
  final bool canConfirmByWhatsapp;
  final bool canConfirmByCall;
  final bool useViewAddress;
  final bool useViewPhone;
  final bool useViewEmail;
  final bool useViewWebsite;
  final bool useViewFacebook;
  final bool useViewWhatsapp;
  final bool useViewSocial;
  final bool useViewStatus;
  final bool useViewDateEstablish;
  final bool useViewTimeElapsed;
  final bool useViewGalleries;
  final bool useViewAttachment;
  final bool useViewVideo;
  final bool useViewMap;
  final bool useViewPrice;
  final bool useViewArea;
  final bool useViewOpenHours;
  final bool useViewTags;
  final bool useViewFeature;
  final bool useViewAdmob;

  SettingModel({
    required this.defaultCountryPhoneCode,
    required this.roomsFilter,
    required this.sortOptions,
    required this.minLengthPhoneNumber,
    required this.maxLengthPhoneNumber,
    required this.pageSize,
    required this.listMode,
    required this.detailViewType,
    required this.enableSubmit,
    required this.maxPrice,
    required this.minPrice,
    required this.minPriceFilter,
    required this.maxPriceFilter,
    required this.maxAreaFilter,
    required this.minAreaFilter,
    required this.maxArea,
    required this.minArea,
    required this.color,
    required this.unitPrice,
    required this.unitArea,
    required this.maxFloors,
    required this.maxRooms,
    required this.maxBaths,
    required this.maxYearOfCompletion,
    required this.minYearOfCompletion,
    // required this.startHour,
    // required this.endHour,
    required this.canConfirmBySms,
    required this.canConfirmByWhatsapp,
    required this.canConfirmByCall,
    required this.useViewAddress,
    required this.useViewPhone,
    required this.useViewEmail,
    required this.useViewWebsite,
    required this.useViewFacebook,
    required this.useViewWhatsapp,
    required this.useViewSocial,
    required this.useViewStatus,
    required this.useViewDateEstablish,
    required this.useViewTimeElapsed,
    required this.useViewGalleries,
    required this.useViewAttachment,
    required this.useViewVideo,
    required this.useViewMap,
    required this.useViewPrice,
    required this.useViewArea,
    required this.useViewOpenHours,
    required this.useViewTags,
    required this.useViewFeature,
    required this.useViewAdmob,
  });

  factory SettingModel.fromDefault() {
    return SettingModel(
      defaultCountryPhoneCode: '+967',
      roomsFilter: [],
      sortOptions: [],
      minLengthPhoneNumber: 9,
      maxLengthPhoneNumber: 9,
      pageSize: 20,
      listMode: ProductViewType.list,
      detailViewType: DetailViewType.basic,
      enableSubmit: true,
      minPrice: 0.0,
      maxPrice: 100.0,
      minPriceFilter: 0.0,
      maxPriceFilter: 100.0,
      maxAreaFilter: 30.0,
      minAreaFilter: 5.0,
      maxArea: 3000.0,
      minArea: 10.0,
      color: [],
      unitPrice: 'USD',
      unitArea: 'm2',
      maxFloors: 50,
      maxRooms: 30,
      maxBaths: 6,
      maxYearOfCompletion: 2025,
      minYearOfCompletion: 1980,
      // startHour: const TimeOfDay(hour: 8, minute: 0),
      // endHour: const TimeOfDay(hour: 15, minute: 0),
      canConfirmBySms: false,
      canConfirmByWhatsapp: true,
      canConfirmByCall: false,
      useViewAddress: true,
      useViewPhone: true,
      useViewEmail: true,
      useViewWebsite: true,
      useViewFacebook: true,
      useViewWhatsapp: true,
      useViewSocial: true,
      useViewStatus: true,
      useViewDateEstablish: true,
      useViewTimeElapsed: true,
      useViewGalleries: true,
      useViewAttachment: true,
      useViewVideo: true,
      useViewMap: true,
      useViewPrice: true,
      useViewArea: true,
      useViewOpenHours: true,
      useViewTags: true,
      useViewFeature: true,
      useViewAdmob: true,
    );
  }

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] ?? {};
    final permissions = json['permissions'] ?? {};
    final settingDetailView = settings['mobile_listing_view'];

    // TimeOfDay? startHour;
    // TimeOfDay? endHour;
    // if (settings['time_min'] != null) {
    //   List<String> split = settings['time_min'].split(':');
    //   startHour = TimeOfDay(
    //     hour: int.tryParse(split[0]) ?? 0,
    //     minute: int.tryParse(split[1]) ?? 0,
    //   );
    // }
    // if (settings['time_max'] != null) {
    //   List<String> split = settings['time_max'].split(':');
    //   endHour = TimeOfDay(
    //     hour: int.tryParse(split[0]) ?? 0,
    //     minute: int.tryParse(split[1]) ?? 0,
    //   );
    // }

    return SettingModel(
      defaultCountryPhoneCode: json['defaultCountryPhoneCode'] ?? '+967',
      roomsFilter: List.from(json['rooms'] ?? []).map((item) {
        return int.tryParse(item.toString())!;
      }).toList(),
      sortOptions: List.from(json['sortOptions'] ?? []).map((item) {
        return SortModel.fromJson(item);
      }).toList(),
      minLengthPhoneNumber: json['minLengthPhoneNumber'] ?? 9,
      maxLengthPhoneNumber: json['maxLengthPhoneNumber'] ?? 9,
      pageSize: json['pageSize'] ?? 20,
      listMode: mapListMode[json['listMode']] ?? ProductViewType.list,
      detailViewType: detailMode[settingDetailView] ?? DetailViewType.basic,
      enableSubmit: json['allowSubmit'] ?? true,
      minPrice: double.tryParse('${json['minPrice']}') ?? 0.0, //
      maxPrice: double.tryParse('${json['maxPrice']}') ?? 100.0, //
      minPriceFilter: double.tryParse('${json['minPriceFilter']}') ?? 0.0, //
      maxPriceFilter: double.tryParse('${json['maxPriceFilter']}') ?? 100.0, //
      maxAreaFilter: double.tryParse('${json['maxAreaFilter']}') ?? 30.0, //
      minAreaFilter: double.tryParse('${json['minAreaFilter']}') ?? 5.0, //
      maxArea: double.tryParse('${json['maxArea']}') ?? 3000.0, // //
      minArea: double.tryParse('${json['minArea']}') ?? 10.0, //
      color: json['colorOption'] ?? [],
      unitPrice: json['unitPrice'] ?? 'USD', //
      unitArea: json['unitArea'] ?? 'm2', //
      maxFloors: json['maxFloors'] ?? 50, //
      maxRooms: json['maxRooms'] ?? 30, //
      maxBaths: json['maxBaths'] ?? 6, //
      maxYearOfCompletion: json['maxYearOfCompletion'] ?? 2025, //
      minYearOfCompletion: json['minYearOfCompletion'] ?? 1980, //
      // startHour: startHour ?? const TimeOfDay(hour: 8, minute: 0),
      // endHour: endHour ?? const TimeOfDay(hour: 15, minute: 0),
      canConfirmBySms: permissions['canConfirmBySms'] ?? false,
      canConfirmByWhatsapp: permissions['canConfirmByWhatsapp'] ?? true,
      canConfirmByCall: permissions['canConfirmByCall'] ?? false,
      useViewAddress: permissions['view_address_use'] ?? true,
      useViewPhone: permissions['view_phone_use'] ?? true,
      useViewEmail: permissions['view_email_use'] ?? true,
      useViewWebsite: permissions['view_website_use'] ?? true,
      useViewFacebook: permissions['view_facebook_use'] ?? true,
      useViewWhatsapp: permissions['view_whatsapp_use'] ?? true,
      useViewSocial: permissions['social_network_use'] ?? true,
      useViewStatus: permissions['view_status_use'] ?? true,
      useViewDateEstablish: permissions['view_date_establish_use'] ?? true,
      useViewTimeElapsed: permissions['view_time_elapsed_use'] ?? true,
      useViewGalleries: permissions['view_gallery_use'] ?? true,
      useViewAttachment: permissions['view_attachment_use'] ?? true,
      useViewVideo: permissions['view_video_url_use'] ?? true,
      useViewMap: permissions['view_map_use'] ?? true,
      useViewPrice: permissions['view_price_use'] ?? true,
      useViewArea: permissions['view_area_use'] ?? true,
      useViewOpenHours: permissions['view_opening_hour_use'] ?? true,
      useViewTags: permissions['view_tags_use'] ?? true,
      useViewFeature: permissions['view_feature_use'] ?? true,
      useViewAdmob: permissions['view_admob_use'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultCountryPhoneCode': defaultCountryPhoneCode,
      'rooms': roomsFilter,
      'sortOptions': sortOptions.map((e) => e.toJson()).toList(),
      'minLengthPhoneNumber': minLengthPhoneNumber,
      'maxLengthPhoneNumber': maxLengthPhoneNumber,
      'pageSize': pageSize,
      'listMode': listMode.name,
      'detailViewType': detailViewType.name,
      'enableSubmit': enableSubmit,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minPriceFilter': minPriceFilter,
      'maxPriceFilter': maxPriceFilter,
      'color': color,
      'unitPrice': unitPrice,
      'unitArea': unitArea,
      'canConfirmBySms': canConfirmBySms,
      'canConfirmByWhatsapp': canConfirmByWhatsapp,
      'canConfirmByCall': canConfirmByCall,
      'useViewAddress': useViewAddress,
      'useViewPhone': useViewPhone,
      'useViewEmail': useViewEmail,
      'useViewWebsite': useViewWebsite,
      'useViewFacebook': useViewFacebook,
      'useViewWhatsapp': useViewWhatsapp,
      'useViewSocial': useViewSocial,
      'useViewStatus': useViewStatus,
      'useViewDateEstablish': useViewDateEstablish,
      'useViewTimeElapsed': useViewTimeElapsed,
      'useViewAttachment': useViewAttachment,
      'useViewVideo': useViewVideo,
      'useViewMap': useViewMap,
      'useViewPrice': useViewPrice,
      'useViewArea': useViewArea,
      'useViewOpenHours': useViewOpenHours,
      'useViewTags': useViewTags,
      'useViewFeature': useViewFeature,
      'useViewAdmob': useViewAdmob,
    };
  }
}
