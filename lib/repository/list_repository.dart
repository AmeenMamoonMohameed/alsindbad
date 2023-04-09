import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:path/path.dart' as path;

import '../widgets/app_upload_image.dart';
import 'location_repository.dart';

class ListRepository {
  ///load setting
  static Future<SettingModel?> loadSetting() async {
    final response = await Api.requestSetting();
    if (response.succeeded) {
      return SettingModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load setting
  static Future<SubmitSettingModel?> loadSubmitSetting() async {
    final response =
        await Api.requestSubmitSetting(Application.currentCountry?.id ?? 0);
    if (response.succeeded) {
      return SubmitSettingModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load list
  static Future<List?> loadList({
    int? pageNumber,
    int? pageSize,
    FilterModel? filter,
    String? searchString,
    bool? loading = true,
  }) async {
    Map<String, dynamic> params = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      // "filter": filter,
      "searchString": searchString,
    };
    if (filter != null) {
      params.addAll(UtilOther.buildFilterParams(filter));
    }
    final response = await Api.requestList(params, loading);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item, setting: Application.setting);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load wish list
  static Future<List?> loadWishList({
    int? pageNumber,
    int? pageSize,
  }) async {
    Map<String, dynamic> params = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
    };
    final response = await Api.requestWishList(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item, setting: Application.setting);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///add wishList
  static Future<bool> addWishList(id) async {
    final response = await Api.requestAddWishList(id);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///remove wishList
  static Future<bool> removeWishList(id) async {
    final response = await Api.requestRemoveWishList(id);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///clear wishList
  static Future<bool> clearWishList() async {
    final response = await Api.requestClearWishList();
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///load author product
  static Future<List?> loadAuthorList({
    required int pageNumber,
    required int pageSize,
    required String searchString,
    required FilterModel filter,
    required String userID,
    bool? pending,
  }) async {
    Map<String, dynamic> params = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "searchString": searchString,
      "createdBy": userID,
    };
    if (pending == true) {
      params['status'] = 2;
    }
    params.addAll(UtilOther.buildFilterParams(filter));
    final response = await Api.requestAuthorList(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item, setting: Application.setting);
      }).toList();
      return [list, response.pagination, response.user];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  // ///load author product
  // static Future<List?> loadAuthorList({
  //   required int pageNumber,
  //   required int pageSize,
  //   required String searchString,
  //   required FilterModel filter,
  //   bool? pending,
  // }) async {
  //   Map<String, dynamic> params = {
  //     "pageNumber": pageNumber,
  //     "pageSize": pageSize,
  //     "searchString": searchString,
  //     // "userId": userID,
  //   };
  //   if (pending == true) {
  //     params['status'] = 2;
  //   }
  //   params.addAll(UtilOther.buildFilterParams(filter));
  //   final response = await Api.requestAuthorList(params);
  //   if (response.succeeded) {
  //     final list = List.from(response.data ?? []).map((item) {
  //       return ProductModel.fromJson(item, setting: Application.setting);
  //     }).toList();
  //     return [list, response.pagination, response.user];
  //   }
  //   AppBloc.messageCubit.onShow(response.message);
  //   return null;
  // }

  ///Upload image
  static Future<ResultApiModel> uploadImage(File file, progress) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path),
    });
    return await Api.requestUploadImage(formData, progress);
  }

  ///Upload image Bytes
  static Future<ResultApiModel> uploadImageBytes(
      File file, int type, bool isTemp, progress) async {
    Uint8List bytes = file.readAsBytesSync();
    String bs4str = base64Encode(bytes);
    // ByteData.view(bytes.buffer)
    Map<String, dynamic> params = {
      "fileName": file.path.split('/').last,
      "extension": path.extension(file.path),
      "uploadType": type,
      "size": bytes.elementSizeInBytes,
      "data": bs4str,
      "isTemp": isTemp,
    };
    return await Api.requestUploadImageBytes(params, progress);
  }

  ///load detail
  static Future<ProductModel?> loadProduct(id) async {
    final response = await Api.requestProduct({"id": id});
    if (response.succeeded) {
      return ProductModel.fromJson(response.data, setting: Application.setting);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///save product
  static Future<bool> saveProduct(params) async {
    final response = await Api.requestSaveProduct(params);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Delete author item
  static Future<bool> removeProduct(id) async {
    final response = await Api.requestDeleteProduct(id);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return true;
    }
    return false;
  }

  ///Delete author item
  static Future<List<String>?> loadTags(String keyword) async {
    final response = await Api.requestTags({"s": keyword});
    if (response.succeeded) {
      return List.from(response.data ?? []).map((e) {
        return e['name'] as String;
      }).toList();
    }
    AppBloc.messageCubit.onShow(response.message);
    return [];
  }
}
