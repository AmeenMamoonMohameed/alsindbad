import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/app_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';

import '../../models/model_user.dart';

enum LoginState {
  init,
  loading,
  success,
  fail,
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.init);

  void onLogin({
    required String countryCode,
    required String phoneNumber,
    required String password,
  }) async {
    ///Notify
    emit(LoginState.loading);
    UserModel? result;
    try {
          ///Set Device Token
      Application.device?.token = await UtilOther.getDeviceToken();
    // فقط للتأخير لبعد ان يتم تعيين توكين الجهاز
    if (Application.device?.token != null) {
    } else {}

      // فقط للتأخير لبعد ان يتم تعيين توكين الجهاز
      if (Application.device?.token != null) {
        ///login via repository
        result = await UserRepository.login(
          countryCode: countryCode,
          phoneNumber: phoneNumber,
          password: password,
        );
        if (result != null) {
          ///Begin start Auth flow
          await AppBloc.authenticateCubit.onSave(result);

          ///Notify
          emit(LoginState.success);
        } else {
          ///Notify
          emit(LoginState.fail);
        }
      } else {
        result = await UserRepository.login(
          countryCode: countryCode,
          phoneNumber: phoneNumber,
          password: password,
        );
        if (result != null) {
          ///Begin start Auth flow
          await AppBloc.authenticateCubit.onSave(result);

          ///Notify
          emit(LoginState.success);
        } else {
          ///Notify
          emit(LoginState.fail);
        }
      }
    } catch (ex) {
      if (result != null) {
        ///Begin start Auth flow
        await AppBloc.authenticateCubit.onSave(result);

        ///Notify
        emit(LoginState.success);
      } else {
        ///Notify
        emit(LoginState.fail);
      }
    }
  }

  void onFetch() async {
    ///Notify
    emit(LoginState.loading);

    ///Set Device Token
    Application.device?.token = await UtilOther.getDeviceToken();

    ///login via repository
    final result = await UserRepository.fetch();

    if (result != null) {
      ///Begin start Auth flow
      await AppBloc.authenticateCubit.onSave(result);

      ///Notify
      emit(LoginState.success);
    } else {
      ///Notify
      emit(LoginState.fail);
    }
  }

  void onLogout() async {
    ///Begin start auth flow
    emit(LoginState.init);
    AppBloc.authenticateCubit.onClear();
  }

  void onDeactivate(String? deactiveReason) async {
    final result = await UserRepository.deactivate(deactiveReason);
    if (result) {
      AppBloc.authenticateCubit.onClear();
    }
  }
}
