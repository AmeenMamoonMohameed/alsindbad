import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  int pageNumber = 1;
  List<ProductModel> listProduct = [];
  List<ProductModel> listProductPending = [];
  List<CommentModel> listComment = [];
  PaginationModel? pagination;
  UserModel? user;
  Timer? timer;

  void onLoad({
    required FilterModel filter,
    required String searchString,
    required String userID,
    required int indexTab,
  }) async {
    pageNumber = 1;

    if (indexTab == 0) {
      if (listProduct.isEmpty) {
        emit(ProfileLoading());
      }
      // var rating = await UserRepository.getUserRatingAsync(userId: userID);

      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: searchString,
        userID: userID,
        filter: filter,
      );

      if (result != null) {
        listProduct = result[0];
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.totalCount);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      }
    } else if (userID == AppBloc.userCubit.state!.userId && indexTab == 1) {
      if (listProductPending.isEmpty) {
        emit(ProfileLoading());
      }

      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: searchString,
        filter: filter,
        userID: userID,
        pending: true,
      );
      if (result != null) {
        listProductPending = result[0];
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.totalCount);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      }
    } else {
      if (listComment.isEmpty) {
        emit(ProfileLoading());
      }

      ///Review Load
      final response = await ReviewRepository.loadAuthorReview(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: searchString,
        createdBy: userID,
      );
      if (response.succeeded) {
        listComment = List.from(response.data['reviews'] ?? []).map((item) {
          return CommentModel.fromJson(item);
        }).toList();

        pagination = response.pagination;

        ///Notify
        emit(ProfileSuccess(
          user: user,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore:
              (pagination?.currentPage ?? 0) < (pagination?.totalPages ?? 0),
        ));
      } else {
        AppBloc.messageCubit.onShow(response.message);
      }
    }
  }

  void onSearch({
    required FilterModel filter,
    required String keyword,
    required String userID,
    required int indexTab,
  }) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () async {
      pageNumber = 1;

      if (indexTab == 0) {
        if (listProduct.isEmpty) {
          emit(ProfileLoading());
        }

        ///Listing Load
        final result = await ListRepository.loadAuthorList(
          pageNumber: pageNumber,
          pageSize: Application.setting.pageSize,
          searchString: keyword,
          userID: userID,
          filter: filter,
        );
        if (result != null) {
          listProduct = result[0];
          pagination = result[1];
          user = result[2];
          user!.updateUser(total: pagination!.totalCount);

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.currentPage < pagination!.totalPages,
          ));
        }
      } else if (indexTab == 1) {
        if (listProductPending.isEmpty) {
          emit(ProfileLoading());
        }

        ///Listing Load
        final result = await ListRepository.loadAuthorList(
          pageNumber: pageNumber,
          pageSize: Application.setting.pageSize,
          searchString: keyword,
          filter: filter,
          userID: userID,
          pending: false,
        );
        if (result != null) {
          listProductPending = result[0];
          pagination = result[1];
          user = result[2];
          user!.updateUser(total: pagination!.totalCount);

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.currentPage < pagination!.totalPages,
          ));
        }
      } else {
        if (listComment.isEmpty) {
          emit(ProfileLoading());
        }

        ///Review Load
        final response = await ReviewRepository.loadAuthorReview(
          pageNumber: pageNumber,
          pageSize: Application.setting.pageSize,
          searchString: keyword,
          createdBy: userID,
        );
        if (response.succeeded) {
          listComment = List.from(response.data ?? []).map((item) {
            return CommentModel.fromJson(item);
          }).toList();

          pagination = response.pagination;

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.currentPage < pagination!.totalPages,
          ));
        } else {
          AppBloc.messageCubit.onShow(response.message);
        }
      }
    });
  }

  void onLoadMore({
    required FilterModel filter,
    required String keyword,
    required String userID,
    required int indexTab,
  }) async {
    pageNumber += 1;

    ///Notify loading more

    emit(ProfileSuccess(
      user: user!,
      listProduct: listProduct,
      listProductPending: listProductPending,
      listComment: listComment,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
      loadingMore: true,
    ));

    if (indexTab == 0) {
      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: keyword,
        userID: userID,
        filter: filter,
      );
      if (result != null) {
        listProduct.addAll(result[0]);
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.totalCount);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      }
    } else if (indexTab == 1) {
      ///pending
      final result = await ListRepository.loadAuthorList(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: keyword,
        filter: filter,
        userID: userID,
        pending: true,
      );
      if (result != null) {
        listProductPending.addAll(result[0]);
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.totalCount);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      }
    } else {
      ///Review Load
      final response = await ReviewRepository.loadAuthorReview(
        pageNumber: pageNumber,
        pageSize: Application.setting.pageSize,
        searchString: keyword,
        createdBy: userID,
      );
      if (response.succeeded) {
        final moreList = List.from(response.data ?? []).map((item) {
          return CommentModel.fromJson(item);
        }).toList();

        listComment.addAll(moreList);
        pagination = response.pagination;

        ///Notify

        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.currentPage < pagination!.totalPages,
        ));
      } else {
        AppBloc.messageCubit.onShow(response.message);
      }
    }
  }
}
