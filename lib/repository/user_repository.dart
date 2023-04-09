import 'dart:convert';

import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

class UserRepository {
  ///Fetch api login
  static Future<UserModel?> login({
    required String countryCode,
    required String phoneNumber,
    required String password,
  }) async {
    final Map<String, dynamic> params = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "password": password,
    };
    final response = await Api.requestLogin(params);

    if (response.succeeded) {
      removeRegUserId();
      return UserModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Fetch User Data
  static Future<UserModel?> fetch() async {
    final response = await Api.requestFetch();

    if (response.succeeded) {
      removeRegUserId();
      return UserModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Fetch api validToken
  static Future<bool> validateToken() async {
    final response = await Api.requestValidateToken();
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Fetch api deactivate
  static Future<bool> deactivate(String? deactiveReason) async {
    final Map<String, dynamic> params = {
      "deactiveReason": deactiveReason,
    };
    final response = await Api.requestDeactivate(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return true;
    }
    return false;
  }

  ///Fetch api change Password
  static Future<bool> changePassword(
      {required String newPassword,
      required String confirmNewPassword,
      required String password}) async {
    final Map<String, dynamic> params = {
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
      "password": password,
    };
    final response = await Api.requestChangePassword(params);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Fetch api reset password
  static Future<bool> resetPassword(
      {required String countryCode,
      required String phoneNumber,
      required String newPassword,
      required String confirmNewPassword,
      required String token}) async {
    final Map<String, dynamic> params = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "password": newPassword,
      "confirmPassword": confirmNewPassword,
      "token": token,
    };
    final response = await Api.requestResetPassword(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return true;
    }
    return false;
  }

  ///Validation phone number
  static Future<bool> validationPhoneNumber(
      {required String countryCode, required String phoneNumber}) async {
    final Map<String, dynamic> params = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber
    };
    final response = await Api.requestValidationPhoneNumber(params);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Fetch api forgot Password
  static Future<double?> sendVerifiyCodeForgotPassword(
      {required String countryCode,
      required String phoneNumber,
      required String confirmType}) async {
    final Map<String, dynamic> params = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "confirmType": confirmType
    };
    final response = await Api.requestSendVerifiyCodeForgotPassword(params);
    if (response.succeeded) {
      return double.tryParse(response.data.toString());
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///confirm forgot Password
  static Future<String?> confirmForgotPassword(
      {required String countryCode,
      required String phoneNumber,
      required String otp}) async {
    final Map<String, dynamic> params = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "otp": otp
    };
    final response = await Api.requestConfirmForgotPassword(params);
    if (response.succeeded) {
      return response.data;
      // removeRegUserId();
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Fetch api register account
  static Future<String?> register({
    required String accountName,
    required String fullName,
    required int gender,
    required bool isAppearPhoneNumber,
    required String password,
    required String confirmPassword,
    required String countryCode,
    required String phoneNumber,
    required String? email,
    required int userType,
  }) async {
    final Map<String, dynamic> params = {
      "accountName": accountName,
      "fullName": fullName,
      "gender": gender,
      "isAppearPhoneNumber": isAppearPhoneNumber,
      "password": password,
      "confirmPassword": confirmPassword,
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "email": email,
      "userType": userType,
    };
    final response = await Api.requestRegister(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return response.data;
    }
    return null;
  }

  ///confirm PhoneNumber
  static Future<bool> confirmPhoneNumber(
      {required String userId, required String otp}) async {
    final Map<String, dynamic> params = {"userId": userId, "otp": otp};
    final response = await Api.requestConfirmPhoneNumber(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      removeRegUserId();
    }
    return response.succeeded;
  }

  ///Resend Verification PhoneNumber
  static Future<double?> sendVerificationPhoneNumber(
      {required String userId, required String confirmType}) async {
    final Map<String, dynamic> params = {
      "userId": userId,
      "confirmType": confirmType,
    };
    final response = await Api.requestSendVerificationPhoneNumber(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.succeeded) {
      return double.tryParse(response.data.toString());
    }
    return null;
  }

  ///Save RegUserId
  static Future<bool> saveRegUserId(String userId) async {
    return await Preferences.setString(Preferences.regUserId, userId);
  }

  ///Load RegUserId
  static Future<String?> loadRegUserId() async {
    final result = Preferences.getString(Preferences.regUserId);
    return result;
  }

  ///Remove RegUserId
  static Future<bool> removeRegUserId() async {
    return await Preferences.remove(Preferences.regUserId);
  }

  ///Fetch api forgot Password
  static Future<bool> updateProfile({
    required String accountName,
    required String fullName,
    required String phoneNumber,
    required bool isAppearPhoneNumber,
    required String email,
    required String url,
    required String description,
    String? image,
  }) async {
    Map<String, dynamic> params = {
      "accountName": accountName,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "isAppearPhoneNumber": isAppearPhoneNumber,
      "email": email,
      "url": url,
      "description": description,
    };
    if (image != null) {
      params['profilePictureDataUrl'] = image;
    }
    final response = await Api.requestChangeProfile(params);
    AppBloc.messageCubit.onShow(response.message);

    ///Case success
    if (response.succeeded) {
      return true;
    }
    return false;
  }

  ///Save User
  static Future<bool> saveUser({required UserModel user}) async {
    return await Preferences.setString(
      Preferences.user,
      jsonEncode(user.toJson()),
    );
  }

  ///Load User
  static Future<UserModel?> loadUser() async {
    final result = Preferences.getString(Preferences.user);
    if (result != null) {
      return UserModel.fromJson(jsonDecode(result));
    }
    return null;
  }

  ///Fetch User
  static Future<UserModel?> fetchUser() async {
    final response = await Api.requestUser();
    if (response.succeeded) {
      return UserModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Delete User
  static Future<bool> deleteUser() async {
    return await Preferences.remove(Preferences.user);
  }

  ///Load Companies
  static Future<List?> loadProfiles(
      {pageNumber, pageSize, keyword, userType}) async {
    final response = await Api.requestProfiles(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchString: keyword,
        userType: userType.index);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return UserModel.fromJson(item);
      }).toList();

      return [list, response.pagination];
    }

    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  /// Get User Rating
  static Future<double> getUserRatingAsync({
    required String userId,
  }) async {
    final response = await Api.requestUserRating(userId);

    if (response.succeeded) {
      return double.tryParse(response.data.toString()) ?? 0;
    }
    AppBloc.messageCubit.onShow(response.message);
    return 0;
  }
}
