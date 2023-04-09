import 'package:bloc/bloc.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

import '../../repository/view_repository.dart';
import 'views_state.dart';

class ViewsCubit extends Cubit<ViewsState> {
  int productsViewsPageNumber = 1;
  int profileViewsPageNumber = 1;
  TotalViewsModel? totalViews;
  List<ViewsModel> productsViewsList = [];
  List<ViewsModel> profileViewsList = [];
  PaginationModel? productsViewsPagination;
  PaginationModel? profileViewsPagination;

  ViewsCubit() : super(ViewsLoading());

  Future<void> onLoad({bool byDays = true}) async {
    totalViews = await ViewsRepository.getTotalViews();
    await AppBloc.viewsCubit.onLoadProductsViews(byDays: byDays);
    await AppBloc.viewsCubit.onLoadProfileViews(byDays: byDays);

    // emit(ViewsSuccess(
    //     list: productsViewsList,
    //     canLoadMore: productsViewsPagination!.currentPage <
    //         productsViewsPagination!.totalPages,
    //     type: ViewsStateType.productViews,
    //     totalViews: totalViews));

    // emit(ViewsSuccess(
    //     list: profileViewsList,
    //     canLoadMore: profileViewsPagination!.currentPage <
    //         profileViewsPagination!.totalPages,
    //     type: ViewsStateType.profileViews,
    //     totalViews: totalViews));
  }

  Future<void> onLoadProductsViews({bool byDays = true}) async {
    ///Fetch API Views
    productsViewsPageNumber = 1;
    productsViewsList = [];
    var result = await ViewsRepository.getProductsViews(
        from: DateTime.now().toUtc().add(const Duration(days: -10)).toString(),
        to: DateTime.now().toUtc().add(const Duration(days: 10)).toString(),
        pageNumber: productsViewsPageNumber,
        pageSize: 10,
        byDays: byDays);
    if (result != null) {
      productsViewsList = result[0];
      productsViewsPagination = result[1];

      emit(ViewsSuccess(
          list: productsViewsList,
          canLoadMore: productsViewsPagination!.currentPage <
              productsViewsPagination!.totalPages,
          type: ViewsStateType.productViews,
          totalViews: totalViews));
    }
  }

  Future<void> onLoadProfileViews({bool byDays = true}) async {
    ///Fetch API Views
    profileViewsPageNumber = 1;
    profileViewsList = [];
    var result = await ViewsRepository.getProfileViews(
        from: DateTime.now().toUtc().add(const Duration(days: -10)).toString(),
        to: DateTime.now().toUtc().add(const Duration(days: 10)).toString(),
        pageNumber: profileViewsPageNumber,
        pageSize: 10,
        byDays: byDays);
    if (result != null) {
      profileViewsList = result[0];
      profileViewsPagination = result[1];

      emit(ViewsSuccess(
          list: profileViewsList,
          canLoadMore: profileViewsPagination!.currentPage <
              profileViewsPagination!.totalPages,
          type: ViewsStateType.profileViews,
          totalViews: totalViews));
    }
  }

  Future<void> onLoadMoreProductsViews({bool byDays = true}) async {
    productsViewsPageNumber = productsViewsPageNumber + 1;
    var result = await ViewsRepository.getProductsViews(
        from: DateTime.now().toUtc().add(const Duration(days: -10)).toString(),
        to: DateTime.now().toUtc().add(const Duration(days: 10)).toString(),
        pageNumber: productsViewsPageNumber,
        pageSize: 10,
        byDays: byDays);
    if (result != null) {
      productsViewsList.addAll(result[0]);
      productsViewsPagination = result[1];

      emit(ViewsSuccess(
          list: productsViewsList,
          canLoadMore: productsViewsPagination!.currentPage <
              productsViewsPagination!.totalPages,
          type: ViewsStateType.productViews,
          totalViews: totalViews));
    }
  }

  Future<void> onLoadMoreProfileViews({bool byDays = true}) async {
    profileViewsPageNumber = profileViewsPageNumber + 1;
    var result = await ViewsRepository.getProfileViews(
        from: DateTime.now().toUtc().add(const Duration(days: -10)).toString(),
        to: DateTime.now().toUtc().add(const Duration(days: 10)).toString(),
        pageNumber: profileViewsPageNumber,
        pageSize: 10,
        byDays: byDays);
    if (result != null) {
      profileViewsList.addAll(result[0]);
      profileViewsPagination = result[1];

      emit(ViewsSuccess(
          list: profileViewsList,
          canLoadMore: profileViewsPagination!.currentPage <
              profileViewsPagination!.totalPages,
          type: ViewsStateType.profileViews,
          totalViews: totalViews));
    }
  }
}
