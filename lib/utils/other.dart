import 'dart:io';

import 'package:akarak/widgets/app_button.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class UtilOther {
  static fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode next,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  static hiddenKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<DeviceModel?> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        return DeviceModel(
          uuid: android.androidId,
          model: "Android",
          version: android.version.sdkInt.toString(),
          type: android.model,
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
        return DeviceModel(
          uuid: ios.identifierForVendor,
          name: ios.name,
          model: ios.systemName,
          version: ios.systemVersion,
          type: ios.utsname.machine,
        );
      }
    } catch (e) {
      UtilLogger.log("ERROR", e);
    }
    return null;
  }

  static Future<String?> getDeviceToken() async {
    // var d = await FirebaseMessaging.instance.getToken();
    // await FirebaseMessaging.instance.requestPermission();
    try {
      // return await FirebaseMessaging.instance.getToken();
      return null;
    } catch (ex) {
      print(ex);
    }
  }

  static Map<String, dynamic> buildFilterParams(FilterModel filter) {
    Map<String, dynamic> params = {
      "searchString": filter.searchString,
      "category": filter.category?.id ??
          filter.subCategory?.id ??
          filter.mainCategory?.id,
      "brand": filter.brand?.id,
      "byImage": filter.byImage,
    };
    params['section'] = filter.section.index;
    if (filter.locationId != null) {
      params['locationId'] = filter.locationId!;
    }
    if (filter.distance != null) {
      params['distance'] = filter.distance;
    }
    if (filter.currency != null) {
      params['currencyId'] = filter.currency!.id;
    }
    if (filter.minPriceFilter != null) {
      params['priceMin'] = filter.minPriceFilter!.toInt();
    }
    if (filter.maxPriceFilter != null) {
      params['priceMax'] = filter.maxPriceFilter!.toInt();
    }
    if (filter.containsList != null && filter.containsList!.isNotEmpty) {
      params['containsList'] =
          filter.containsList!.map((item) => item).toList();
    }
    if (filter.features != null && filter.features!.isNotEmpty) {
      params['features'] = filter.features!.map((item) => item).toList();
    }
    if (filter.sortOptions != null) {
      params['orderby'] = filter.sortOptions!.field;
      params['order'] = filter.sortOptions!.value;
    }
    if (filter.extendedAttributes != null) {
      params['extendedAttributes'] = filter.extendedAttributes;
    }
    return params;
  }

  ///On show message
  static void showMessage(
      {required BuildContext context,
      required String title,
      required String message,
      VoidCallback? func,
      String? funcName}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            if (func != null)
              AppButton(
                funcName!,
                onPressed: func,
                type: ButtonType.text,
              ),
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
          ],
        );
      },
    );
  }

  static Future<String> createDynamicLink(
      String dynamicLink, bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://alsindbad.online',
      longDynamicLink: Uri.parse(
        dynamicLink,
      ),
      link: Uri.parse(dynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'com.arma.akarak',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.arma.akarak',
        minimumVersion: '0',
      ),
      // socialMetaTagParameters: SocialMetaTagParameters(title: )
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await FirebaseDynamicLinks.instance.buildLink(parameters);
    }

    return url.toString();
  }

  ///Singleton factory
  static final UtilOther _instance = UtilOther._internal();

  factory UtilOther() {
    return _instance;
  }

  UtilOther._internal();
}
