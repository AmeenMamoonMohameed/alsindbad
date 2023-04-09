import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';

import '../configs/application.dart';
import '../utils/translate.dart';
import 'model_feature.dart';
import 'model_location.dart';

enum ProductStatus {
  publish,
  draft,
  pending,
  sold,
  incomplete,
  deleted,
}

enum SectionType { sale, rent, saleAndRent }

enum PoductType { ads, product, sponsoredAds }

enum RecordingType { none }

enum FinishingType { full, almostComplete, half, without }

enum PriceType { fixed, bySize }

enum OverlookingType {
  mainStreet,
  byStreet,
  twoStreets,
  threeStreets,
  garden,
  sea
}

enum ActiveReviewType { closed, open }

class ProductModel {
  final int id;
  final String name;
  final String? tradeName;
  final String content;
  final PoductType poductType;
  final SectionType section;
  final RecordingType? recording;
  final String image;
  final String videoURL;
  final CategoryModel? subCategory;
  final CategoryModel? category;
  final BrandModel? brand;
  final String createDate;
  final String date;
  final String timeElapsed;
  final double rate;
  final num numRate;
  final String rateText;
  final ProductStatus status;
  final String statusText;
  final String? statusNote;
  final String? statusColor;
  bool favorite;
  bool isAddedCart;
  final String excerpt;
  final String color;
  final String icon;
  final List<String> tags;
  final PriceType priceType;
  final String price;
  final LocationModel? country;
  final LocationModel? city;
  final LocationModel? state;
  final CurrencyModel? currency;
  final UserModel? createdBy;
  final List<String> gallery;
  final List<FeatureModel> features;
  final List<ProductModel> related;
  final List<ProductModel> latest;
  final List<OpenTimeModel> openHours;
  final List<FileModel> attachments;
  final CoordinateModel? coordinate;
  final String link;
  final bool orderUse;
  final bool activeRating;
  final bool hasMap;
  final ActiveReviewType activeReviews;
  final List<ExtendedAttributeModel> extendedAttributes;
  final int views;
  final String? baracode;
  final bool hasDiscount;
  final double? discount;

  ProductModel({
    required this.id,
    required this.name,
    required this.tradeName,
    required this.section,
    this.poductType = PoductType.ads,
    this.recording,
    required this.image,
    required this.videoURL,
    this.subCategory,
    this.category,
    this.brand,
    required this.createDate,
    required this.date,
    required this.timeElapsed,
    required this.rate,
    required this.numRate,
    required this.rateText,
    required this.status,
    required this.statusText,
    this.statusNote,
    this.statusColor,
    required this.favorite,
    required this.isAddedCart,
    required this.content,
    required this.excerpt,
    required this.color,
    required this.icon,
    required this.tags,
    this.priceType = PriceType.fixed,
    required this.price,
    this.country,
    this.city,
    this.state,
    this.currency,
    this.createdBy,
    required this.gallery,
    required this.features,
    required this.related,
    required this.latest,
    required this.openHours,
    this.coordinate,
    required this.attachments,
    required this.link,
    required this.orderUse,
    required this.hasMap,
    required this.activeRating,
    required this.activeReviews,
    required this.extendedAttributes,
    required this.views,
    this.baracode,
    this.hasDiscount = false,
    this.discount,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    SettingModel? setting,
  }) {
    PoductType poductType = PoductType.ads;
    SectionType section = SectionType.sale;
    RecordingType? recording;
    List<String> gallery = [];
    List<FeatureModel> features = [];
    List<OpenTimeModel> openHours = [];
    List<FileModel> attachments = [];
    List<String> tags = [];
    UserModel? createdBy;
    CategoryModel? subCategory;
    CategoryModel? category;
    BrandModel? brand;
    CoordinateModel? coordinate;
    LocationModel? country;
    LocationModel? state;
    CurrencyModel? currency;
    LocationModel? city;
    ProductStatus status = ProductStatus.publish;
    String statusText = '';
    String videoURL = '';
    String date = '';
    String timeElapsed = '';
    PriceType priceType = PriceType.fixed;
    String price = '';
    bool activeRating = false;
    ActiveReviewType activeReviews = ActiveReviewType.closed;
    List<ExtendedAttributeModel>? extendedAttributes = [];

    if (json['poductType'] != null) {
      poductType = PoductType.values[int.parse(json['poductType'].toString())];
    }

    if (json['priceType'] != null) {
      priceType = PriceType.values[int.parse(json['priceType'].toString())];
    }

    if (json['extendedAttributes'] != null) {
      extendedAttributes =
          List.from(json['extendedAttributes'] ?? []).map((item) {
        return ExtendedAttributeModel.fromJson(item);
      }).toList();
    }

    if (json['createdBy'] != null) {
      createdBy = UserModel.fromJson(json['createdBy']);
    }

    if (json['subCategoryId'] != null) {
      subCategory = Application.submitSetting.categories
          .singleWhere((c) => c.id == json['subCategoryId']);
    }
    if (json['categoryId'] != null) {
      category = Application.submitSetting.categories
          .singleWhere((c) => c.id == json['categoryId']);
    }

    if (json['brandId'] != null &&
        category?.brands != null &&
        category!.brands!.isNotEmpty) {
      brand = category.brands?.singleWhere((c) => c.id == json['brandId']);
    }

    if (json['country'] != null && json['country'] != null) {
      country = LocationModel.fromJson(json['country']);
    }

    if (json['state'] != null) {
      state = LocationModel.fromJson(json['state']);
    }

    if (json['city'] != null) {
      city = LocationModel.fromJson(json['city']);
    }

    if (json['currencyId'] != null) {
      currency = Application.submitSetting.currencies.singleWhere(
          (item) => item.id == (int.tryParse('${json['currencyId']}') ?? 0));
    }

    if (json['latitude'] != null && setting?.useViewMap == true) {
      coordinate = CoordinateModel.fromJson({
        "name": json['name'] ?? "",
        "latitude": json['latitude'] ?? "",
        "longitude": json['longitude'] ?? ""
      });
    }

    // if (json['floors'] != null) {
    //   floors = int.parse(json['floors'].toString());
    // }

    // if (json['rooms'] != null) {
    //   rooms = int.parse(json['rooms'].toString());
    // }

    // if (json['baths'] != null) {
    //   baths = int.parse(json['baths'].toString());
    // }

    // if (json['yearOfCompletion'] != null) {
    //   yearOfCompletion = int.parse(json['baths'].toString());
    // }

    if (json['section'] != null) {
      section = json['section'] == null
          ? SectionType.sale
          : SectionType.values[json['section']];
    }

    // if (json['recording'] != null) {
    //   recording = json['recording'] == null
    //       ? RecordingType.none
    //       : RecordingType.values[json['recording']];
    // }

    // if (json['finishingType'] != null) {
    //   finishingType = json['finishingType'] == null
    //       ? null
    //       : FinishingType.values[json['finishingType']];
    // }

    // if (json['overlooking'] != null) {
    //   overlooking = json['overlooking'] == null
    //       ? null
    //       : OverlookingType.values[json['overlooking']];
    // }

    if (json['ratingStatus'] != null) {
      activeRating = json['ratingStatus'] == 1;
    }

    if (json['activeReviews'] != null) {
      activeReviews = ActiveReviewType.values[json['activeReviews']];
    }

    if (setting?.useViewGalleries == true) {
      gallery = extendedAttributes.where((e) => e.key == "gallery").map((item) {
        return item.text!;
      }).toList();
    }

    if (setting?.useViewStatus == true) {
      statusText = json['statusText'] ?? '';
    }
    status = ProductStatus.values[json['status']];

    if (setting?.useViewVideo == true) {
      videoURL = json['video_url'] ?? '';
    }

    // if (setting?.useViewAddress == true) {
    //   address = json['address'] ?? '';
    // }

    // if (setting?.useViewPhone == true) {
    //   phone = json['phone'] ?? '';
    // }

    // if (setting?.useViewEmail == true) {
    //   email = json['email'] ?? '';
    // }

    // if (setting?.useViewWebsite == true) {
    //   website = json['website'] ?? '';
    // }

    // if (setting?.useViewFacebook == true) {
    //   facebook = json['facebook'] ?? '';
    // }
    // if (setting?.useViewWhatsapp == true) {
    //   whatsapp = json['whatsapp'] ?? '';
    // }
    if (setting?.useViewDateEstablish == true) {
      date = json['date'] ?? '';
    }
    if (setting?.useViewTimeElapsed == true) {
      timeElapsed = json['timeElapsed'] ?? '';
    }

    if (setting?.useViewFeature == true) {
      features = List.from(json['features'] ?? []).map((item) {
        return FeatureModel.fromJson(item);
      }).toList();
    }

    final listRelated = List.from(json['related'] ?? []).map((item) {
      return ProductModel.fromJson(item, setting: setting);
    }).toList();

    final listLatest = List.from(json['lastest'] ?? []).map((item) {
      return ProductModel.fromJson(item, setting: setting);
    }).toList();

    if (setting?.useViewOpenHours == true) {
      openHours = List.from(json['opening_hour'] ?? []).map((item) {
        return OpenTimeModel.fromJson(item);
      }).toList();
    }

    if (setting?.useViewTags == true) {
      tags = List.from(json['tags'] ?? []).map((item) {
        return item.toString();
      }).toList();
    }

    if (setting?.useViewAttachment == true) {
      attachments = List.from(json['attachments'] ?? []).map((item) {
        return FileModel.fromJson(item);
      }).toList();
    }

    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      tradeName: json['tradeName'],
      section: section,
      poductType: poductType,
      recording: recording,
      image: (json['image'] != null &&
              !json['image'].toString().startsWith(Application.domain))
          ? "${Application.domain}${json['image'].toString().replaceAll("\\", "/")}"
          : '',
      videoURL: "https://www.youtube.com/watch?v=jA2ko58woS0", //videoURL,
      subCategory: subCategory,
      category: category,
      brand: brand,
      createDate: json['product_date'] ?? '',
      date: date,
      timeElapsed: timeElapsed,
      rate: double.tryParse('${json['rate']}') ?? 0.0,
      numRate: json['numRate'] ?? 0,
      rateText: json['product_status'] ?? '',
      status: status,
      statusText: statusText,
      statusNote: json['statusNote'],
      statusColor: json['statusColor'],
      favorite: json['favorite'] == true,
      isAddedCart: json['isAddedCart'] == true,
      // floors: floors,
      // rooms: rooms,
      // baths: baths,
      // yearOfCompletion: yearOfCompletion,
      // finishingType: finishingType,
      // overlooking: overlooking,
      // address: address,
      // whatsapp: whatsapp,
      // phone: phone,
      // fax: json['fax'] ?? '',
      // email: email,
      // website: website,
      // facebook: facebook,
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      color: json['color'] ?? '',
      icon: json['icon'] ?? '',
      tags: tags,
      priceType: priceType,
      price: json['price']?.toString() ?? '',
      country: country,
      state: state,
      city: city,
      currency: currency,
      features: features,
      createdBy: createdBy,
      gallery: gallery,
      related: listRelated,
      latest: listLatest,
      openHours: openHours,
      coordinate: coordinate,
      attachments: attachments,
      link: json['guid'] ?? '',
      orderUse: json['orderUse'] ?? true,
      hasMap: json['hasMap'] ?? false,
      activeRating: activeRating,
      activeReviews: activeReviews,
      extendedAttributes: extendedAttributes,
      views: int.parse(json['views']?.toString() ?? "0"),
      baracode: json['baracode'],
      hasDiscount: json['hasDiscount'] ?? false,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subCategoryId": subCategory?.id,
      "categoryId": category?.id,
      "hasMap": hasMap,
      "name": name,
      "image": image
    };
  }

  Map<String, Object?> getProperties() {
    Map<String, Object?> result = <String, Object?>{};

    extendedAttributes
        .where((element) => element.group == "property")
        .forEach((item) {
      if (item.getValue() != null) {
        result[item.key] = item.getValue();
      }
    });

    // if (extendedAttributes != null) {
    //   extendedAttributes.forEach((item) {
    //     result[item.key] = item.getValue();
    //   });
    // }
    return result;
  }
}
