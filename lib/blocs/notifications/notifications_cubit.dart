import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/logger.dart';

import 'cubit.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsLoading());

  int page = 1;
  List<NotificationModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad() async {
    page = 1;

    ///Fetch API
    final result = await NotificationRepository.load(
      pageNumber: page,
      pageSize: 8, //Application.setting.pageSize,
    );
    if (result != null) {
      list = result[0];
      pagination = result[1];

      ///Notify
      emit(NotificationsSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore() async {
    page = page + 1;

    ///Notify
    emit(NotificationsSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    ///Fetch API
    final result = await NotificationRepository.load(
      pageNumber: page,
      pageSize: 8, //Application.setting.pageSize,
    );
    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];

      ///Notify
      emit(NotificationsSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }
}
