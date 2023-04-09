import 'dart:convert';

import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

import '../configs/application.dart';
import '../configs/preferences.dart';
import '../models/model_location.dart';

class LocationRepository {
  ///Load Countries
  static Future<List<CountryModel>?> loadCountries() async {
    final result = await Api.requestCountries();
    if (result.succeeded) {
      return List.from(result.data ?? []).map((item) {
        return CountryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return List<CountryModel>.empty();
  }

  ///Load Location
  static Future<List<LocationModel>?> loadLocation(LocationType? type) async {
    final result = await Api.requestLocation(type);
    if (result.succeeded) {
      return List.from(result.data ?? []).map((item) {
        return LocationModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return List<LocationModel>.empty();
  }

  ///Load Location
  static Future<List<LocationModel>?> loadLocationById(int? id) async {
    dynamic data = {};
    if (id != null) {
      data = {"countryId": Application.currentCountry?.id, "parentId": id};
    } else {
      data = {"countryId": Application.currentCountry?.id};
    }
    final result = await Api.requestLocationById(data);
    if (result.succeeded) {
      return List.from(result.data ?? []).map((item) {
        return LocationModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }

  ///Change Current Country
  static Future<void> onChangeCountry({required CountryModel country}) async {
    ///Current Country
    await Preferences.setString(
      Preferences.currentCountry,
      jsonEncode(country.toJson()),
    );
  }

  ///Get Current Country
  static CountryModel? loadCountry() {
    ///Current Country
    var country = Preferences.get(Preferences.currentCountry);
    if (country != null) return CountryModel.fromJson(jsonDecode(country));
    return null;
  }
}
