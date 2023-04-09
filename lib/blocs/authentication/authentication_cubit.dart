import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/utils.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.loading);

  Future<void> onCheck() async {
    ///Notify
    emit(AuthenticationState.loading);

    ///Event load user
    UserModel? user = await AppBloc.userCubit.onLoadUser();

    if (user != null) {
      ///Attach token push
      Application.device?.token = await UtilOther.getDeviceToken();

      ///Save user
      await AppBloc.userCubit.onSaveUser(user);

      ///Valid token server
      final result = await UserRepository.validateToken();

      if (result) {
        ///Load wishList
        AppBloc.wishListCubit.onLoad();

        ///Fetch user
        AppBloc.userCubit.onFetchUser();

        ///Notify
        emit(AuthenticationState.success);
      } else {
        ///Logout
        onClear();
      }
    } else {
      ///Notify
      emit(AuthenticationState.fail);
    }
    AppBloc.realTimeCubit.connect();
  }

  Future<void> onSave(UserModel user) async {
    ///Notify
    emit(AuthenticationState.loading);

    ///Event Save user
    // AppBloc.userCubit.onSaveUser(user).ignore();
    // await AppBloc.initCubit.onLoad();
    // ///Event Save user
    await AppBloc.userCubit.onSaveUser(user);
    await AppBloc.chatCubit.onInit(isChatUsers: true);
    AppBloc.realTimeCubit.disconnect();
    AppBloc.realTimeCubit.connect();

    ///Load wishList
    AppBloc.wishListCubit.onLoad();

    /// Notify
    emit(AuthenticationState.success);
  }

  void onClear() {
    /// Notify
    emit(AuthenticationState.fail);

    ///Delete user
    AppBloc.userCubit.onDeleteUser();
    AppBloc.realTimeCubit.disconnect();
    AppBloc.realTimeCubit.connect();
  }
}
