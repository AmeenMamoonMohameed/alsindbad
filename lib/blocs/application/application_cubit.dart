import 'dart:convert';
import 'dart:io';
import 'package:akarak/api/websockets.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../repository/location_repository.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit() : super(ApplicationState.loading);

  ///On Before Setup Application
  void onBeforeSetup() async {
    ///Notify
    emit(ApplicationState.loading);

    var countries = await LocationRepository.loadCountries();
    if (countries != null && countries.isNotEmpty) {
      await Preferences.setString(Preferences.countries,
          jsonEncode(countries.map((e) => e.toJson()).toList()));
      Application.countries = countries.map((e) => e).toList();
    } else {
      final result = Preferences.getString(Preferences.countries);
      if (result != null) {
        Application.countries = List.from(jsonDecode(result) ?? []).map((item) {
          return CountryModel.fromJson(item);
        }).toList();
      }
    }
    if (Preferences.getString(Preferences.countries) != null) {
      ///Notify
      emit(ApplicationState.firstTime);
    }
  }

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup(Application.host);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //connected
        return true;
      }
    } on SocketException catch (_) {
      //not connected
      return false;
    }
    return false;
  }

  ///On Setup Application
  void onSetup() async {
    ///Get old Theme & Font & Language & Dark Mode & Domain
    await Preferences.setPreferences();

    Application.currentCountry = LocationRepository.loadCountry();

    final oldTheme = Preferences.getString(Preferences.theme);
    final oldFont = Preferences.getString(Preferences.font);
    final oldLanguage = Preferences.getString(Preferences.language);
    final oldDarkOption = Preferences.getString(Preferences.darkOption);
    final oldDomain = Preferences.getString(Preferences.domain);
    final oldTextScale = Preferences.getDouble(Preferences.textScaleFactor);

    DarkOption? darkOption;
    String? font;
    ThemeModel? theme;

    ///Setup domain
    if (oldDomain != null) {
      Application.domain = oldDomain;
    }

    ///Setup Language
    if (oldLanguage != null) {
      AppBloc.languageCubit.onUpdate(Locale(oldLanguage));
    }

    ///Find font support available [Dart null safety issue]
    try {
      font = AppTheme.fontSupport.firstWhere((item) {
        return item == oldFont;
      });
    } catch (e) {
      UtilLogger.log("ERROR", e);
    }

    ///Setup theme
    if (oldTheme != null) {
      theme = ThemeModel.fromJson(jsonDecode(oldTheme));
    }

    ///check old dark option
    if (oldDarkOption != null) {
      switch (oldDarkOption) {
        case 'off':
          darkOption = DarkOption.alwaysOff;
          break;
        case 'on':
          darkOption = DarkOption.alwaysOn;
          break;
        default:
          darkOption = DarkOption.dynamic;
      }
    }

    ///Setup application & setting
    final results = await Future.wait([
      PackageInfo.fromPlatform(),
      UtilOther.getDeviceInfo(),
      Firebase.initializeApp(),
    ]);
    Application.packageInfo = results[0] as PackageInfo;
    Application.device = results[1] as DeviceModel;

    SettingModel? setting;
    SubmitSettingModel? submitSetting;

    var firstInit = Preferences.getBool(Preferences.firstInit);

    if (await checkInternet()) {
      //connected
      try {
        setting = await ListRepository.loadSetting();
        submitSetting = await ListRepository.loadSubmitSetting();
      } finally {}
      while (setting == null) {
        try {
          setting ??= await ListRepository.loadSetting();
        } finally {}
      }
      while (submitSetting == null) {
        try {
          submitSetting ??= await ListRepository.loadSubmitSetting();
        } finally {}
      }
    } else {
      //not connected
      while ((setting == null || submitSetting == null) &&
          (firstInit == null || firstInit == false)) {
        try {
          setting = await ListRepository.loadSetting();
          submitSetting = await ListRepository.loadSubmitSetting();
        } catch (ex) {}
      }
    }

    if (setting != null) {
      Application.setting = setting;
      await Preferences.setString(
        Preferences.setting,
        jsonEncode(setting.toJson()),
      );
    } else {
      var settingJson = Preferences.get(Preferences.setting);
      if (settingJson != null) {
        Application.setting =
            setting = SettingModel.fromJson(jsonDecode(settingJson));
      }
    }
    if (submitSetting != null) {
      Application.submitSetting = submitSetting;
      await Preferences.setString(
        Preferences.submitSetting,
        jsonEncode(submitSetting.toJson()),
      );
    } else {
      var submitSettingJson = Preferences.get(Preferences.submitSetting);
      if (submitSettingJson != null) {
        Application.submitSetting = submitSetting =
            SubmitSettingModel.fromJson(jsonDecode(submitSettingJson));
      }
    }

    ///Setup Theme & Font with dark Option
    AppBloc.themeCubit.onChangeTheme(
      theme: theme,
      font: font,
      darkOption: darkOption,
      textScaleFactor: oldTextScale,
    );

    // This is just a basic example. For real apps, you must show some
    // friendly dialog box before call the request method.
    // This is very important to not harm the user experience

    ///Start location service
    AppBloc.locationCubit.onLocationService();

    ///Authentication begin check
    await AppBloc.authenticateCubit.onCheck();

    // bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) {
    //   AwesomeNotifications().requestPermissionToSendNotifications();
    // }

    ///First or After upgrade version show intro preview app
    final hasReview = Preferences.containsKey(
      '${Preferences.reviewIntro}.${Application.packageInfo?.version}',
    );
    if (hasReview) {
      if (setting != null && submitSetting != null) {
        var firstInit = Preferences.getBool(Preferences.firstInit);
        if (firstInit == null || firstInit == false) {
          await Preferences.setBool(Preferences.firstInit, true);
        }

        ///Notify
        emit(ApplicationState.completed);
      }
    } else {
      ///Notify
      emit(ApplicationState.intro);
    }
  }

  ///On Complete Intro
  void onCompletedIntro() async {
    await Preferences.setBool(
      '${Preferences.reviewIntro}.${Application.packageInfo?.version}',
      true,
    );

    ///Notify
    emit(ApplicationState.completed);
  }

  ///On Change Domain
  void onChangeDomain(String domain) async {
    emit(ApplicationState.loading);
    final isDomain = Uri.tryParse(domain);
    if (isDomain != null) {
      Application.domain = domain;
      Api.httpManager.changeDomain(domain);
      await Preferences.setString(
        Preferences.domain,
        domain,
      );
      await Future.delayed(const Duration(milliseconds: 250));
      AppBloc.authenticateCubit.onClear();
      emit(ApplicationState.completed);
    } else {
      AppBloc.messageCubit.onShow('domain_not_correct');
    }
  }
}
