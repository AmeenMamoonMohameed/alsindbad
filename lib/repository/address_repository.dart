import 'dart:convert';

import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

class AddressRepository {
  ///Set Default Address
  static Future<bool> setDefault({required AddressModel address}) async {
    final response = await Api.requestSetDefaultAddress({'id': address.id});
    if (response.succeeded) {
      removeDefault();
      saveDefault(address: address);
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Remove Default Address
  static Future<bool> removeDefault() async {
    var result = await Preferences.remove(Preferences.defaultAddress);
    Preferences.setPreferences();
    return result;
  }

  ///Save Default Address
  static Future<bool> saveDefault({required AddressModel address}) async {
    return await Preferences.setString(
      Preferences.defaultAddress,
      jsonEncode(address.toJson()),
    );
  }

  ///Load Default Address
  static Future<AddressModel?> loadDefault() async {
    final result = Preferences.getString(Preferences.defaultAddress);
    if (result != null) {
      return AddressModel.fromJson(jsonDecode(result));
    }
    return null;
  }

  ///All Addresses
  static Future<List<AddressModel>?> loadAllAddresses() async {
    final response = await Api.requestAllAddresses();

    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return AddressModel.fromJson(item);
      }).toList();

      return list;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Submit Address
  static Future<int?> submitAddress({
    required int id,
    required AddressType type,
    required String latitude,
    required String longitude,
    required String name,
    required int stateId,
    required int cityId,
    required String description,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required bool isDefault,
  }) async {
    final Map<String, dynamic> params = {
      "id": id,
      "type": type.index,
      "latitude": latitude,
      "longitude": longitude,
      "name": name,
      "stateId": stateId,
      "cityId": cityId,
      "description": description,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
      "isDefault": isDefault,
    };
    final response = await Api.requestSubmitAddress(params);
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Remove Address
  static Future<int?> removeAddress({
    required int id,
  }) async {
    final response = await Api.requestRemoveAddress(id);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return response.data;
    }
    return null;
  }
}
