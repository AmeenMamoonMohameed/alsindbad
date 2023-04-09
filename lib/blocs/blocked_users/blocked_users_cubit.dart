import 'package:bloc/bloc.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';
import '../../repository/chat_repository.dart';

class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  BlockedUsersCubit() : super(BlockedUsersLoading());

  String keyword = "";
  int pageNumber = 1;
  List<ChatUserModel> list = [];

  Future<void> unblockUser(String userId) async {
    bool? isSuccess = await ChatRepository.unblockUser(userId);
    if (isSuccess ?? false) {
      list.removeWhere((element) => element.userId == userId);
      emit(BlockedUsersSuccess());
    }
  }

  Future<void> onLoad() async {
    pageNumber = 1;

    ///Fetch API
    final result = await ChatRepository.loadBlockedUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      loading: list.isNotEmpty ? false : true,
    );
    if (AppBloc.userCubit.state == null) return;

    ///Notify
    if (result != null) {
      list = result[0];
      emit(BlockedUsersSuccess());
    }
  }
}
