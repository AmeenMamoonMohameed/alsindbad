import 'package:bloc/bloc.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import '../../configs/application.dart';
import 'package:akarak/blocs/bloc.dart';
import '../app_bloc.dart';

class UserCubit extends Cubit<UserModel?> {
  UserCubit() : super(null);

  int pageCompanies = 1;
  List<UserModel> listCompanies = [];
  PaginationModel? paginationCompanies;

  ///Event load user
  Future<UserModel?> onLoadUser() async {
    UserModel? user = await UserRepository.loadUser();
    emit(user);
    return user;
  }

  ///Event fetch user
  Future<UserModel?> onFetchUser() async {
    UserModel? local = await UserRepository.loadUser();
    UserModel? remote = await UserRepository.fetchUser();
    if (local != null && remote != null) {
      final sync = local.updateUser(
        accountName: remote.accountName,
        fullName: remote.fullName,
        phoneNumber: remote.phoneNumber,
        email: remote.email,
        url: remote.url,
        description: remote.description,
        image: remote.profilePictureDataUrl,
      );
      onSaveUser(sync);
      return sync;
    }
    return null;
  }

  ///Event save user
  Future<void> onSaveUser(UserModel user) async {
    await UserRepository.saveUser(user: user);
    emit(user);
  }

  ///Event delete user
  Future<void> onDeleteUser() async {
    // FirebaseMessaging.instance.deleteToken();
    UserRepository.deleteUser();
    emit(null);
    AppBloc.chatSignalRCubit.dispose();
  }

  ///Event update user
  Future<bool> onUpdateUser({
    required String accountName,
    required String fullName,
    required String phoneNumber,
    required bool isAppearPhoneNumber,
    required String email,
    required String url,
    required String description,
    String? image,
  }) async {
    ///Fetch change profile
    final result = await UserRepository.updateProfile(
      accountName: accountName,
      fullName: fullName,
      phoneNumber: phoneNumber,
      isAppearPhoneNumber: isAppearPhoneNumber,
      email: email,
      url: url,
      description: description,
      image: image,
    );

    ///Case success
    if (result) {
      await onFetchUser();
    }
    return result;
  }

  ///Event change password
  Future<bool> onChangePassword(
      String newPassword, String confirmNewPassword, String password) async {
    return await UserRepository.changePassword(
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
        password: password);
  }

  ///Event register
  Future<String?> onRegister({
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
    return await UserRepository.register(
      accountName: accountName,
      fullName: fullName,
      gender: gender,
      isAppearPhoneNumber: isAppearPhoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      countryCode: countryCode,
      phoneNumber: phoneNumber,
      email: email,
      userType: userType,
    );
  }

  Future<void> onLoad(String searchString) async {
    pageCompanies = 1;

    ///Notify
    // emit(UserLoading());

    ///Fetch API
    final result = await UserRepository.loadProfiles(
        pageNumber: pageCompanies,
        pageSize: Application.setting.pageSize,
        keyword: searchString);

    if (result != null) {
      listCompanies = result[0];
      paginationCompanies = result[1];

      ///Notify
      // emit(UserSuccess(
      //   list: listCompanies,
      //   canLoadMore: paginationCompanies!.currentPage < paginationCompanies!.totalPages,
      // ));
    }
  }
}
