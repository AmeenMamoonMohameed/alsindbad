import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class WishListCubit extends Cubit<WishListState> {
  WishListCubit() : super(WishListLoading());

  int page = 1;
  List<ProductModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad({int? updateID}) async {
    page = 1;

    final result = await ListRepository.loadWishList(
      pageNumber: page,
      pageSize: Application.setting.pageSize,
    );
    if (result != null) {
      list = result[0];
      pagination = result[1];

      ///Notify
      emit(WishListSuccess(
        updateID: updateID,
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore() async {
    page = page + 1;

    ///Notify
    emit(WishListSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    final result = await ListRepository.loadWishList(
      pageNumber: page,
      pageSize: Application.setting.pageSize,
    );
    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];

      ///Notify
      emit(WishListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<bool> onAdd(int id) async {
    final result = await ListRepository.addWishList(id);
    if (result) {
      onLoad(updateID: id);
    }
    return result;
  }

  Future<bool> onRemove(int? id) async {
    var result = false;
    if (id != null) {
      result = await ListRepository.removeWishList(id);
    } else {
      result = await ListRepository.clearWishList();
    }
    onLoad(updateID: id);
    return result;
  }
}
