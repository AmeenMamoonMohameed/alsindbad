import 'package:bloc/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import '../../configs/application.dart';
import 'cubit.dart';

class ChatUsersListCubit extends Cubit<ChatUsersListState> {
  ChatUsersListCubit() : super(ChatUsersListLoading());

  String keyword = "";
  int pageNumber = 1;
  List<ChatUserModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad() async {
    pageNumber = 1;

    ///Fetch API
    final result = await ChatRepository.loadChatUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      loading: list.isNotEmpty ? false : true,
    );

    ///Notify
    if (result != null) {
      list = result[0];
      pagination = result[1];

      emit(ChatUsersListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore() async {
    pageNumber = pageNumber + 1;

    ///Notify
    emit(ChatUsersListSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    final result = await ChatRepository.loadChatUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
    );
    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];

      ///Notify
      emit(ChatUsersListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  void onSeenMessage(String userId) {
    ///Notify
    emit(SeenMessageSuccess(
      userId: userId,
    ));

    // final index = list.indexWhere((e) => e.lastMessage?.fromUserId == userId);
    // list[index].lastMessage?.status == Status.seen;
    // final updatedMessage = list[index];
    // list[index] = updatedMessage;
  }


}
