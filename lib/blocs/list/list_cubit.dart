import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';
import 'package:akarak/utils/logger.dart';

import 'cubit.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit() : super(ListLoading());

  int page = 1;
  List<ProductModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad(FilterModel filter) async {
    page = 1;
    emit(ListLoading());

    ///Fetch API
    final result = await ListRepository.loadList(
      pageNumber: page,
      pageSize: Application.setting.pageSize,
      filter: filter,
      loading: list.isNotEmpty ? false : true,
    );
    if (result != null) {
      list = result[0];
      pagination = result[1];

      ///Notify
      emit(ListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore(FilterModel filter) async {
    page = page + 1;

    ///Notify
    emit(ListSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    ///Fetch API
    final result = await ListRepository.loadList(
      pageNumber: page,
      pageSize: Application.setting.pageSize,
      filter: filter,
      loading: true,
    );
    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];

      ///Notify
      emit(ListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onUpdate(int id) async {
    try {
      final exist = list.firstWhere((e) => e.id == id);
      final result = await ListRepository.loadProduct(id);
      if (result != null) {
        list = list.map((e) {
          if (e.id == exist.id) {
            return result;
          }
          return e;
        }).toList();

        ///Notify
        emit(ListSuccess(
          list: list,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      }
    } catch (error) {
      UtilLogger.log("LIST NOT FOUND UPDATE");
    }
  }
}
