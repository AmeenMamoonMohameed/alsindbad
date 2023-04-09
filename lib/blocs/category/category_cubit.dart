import 'package:bloc/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryLoading());
  List<CategoryModel> list = [];
  int? parentId;

  Future<void> onLoad(String keyword) async {
    if (keyword.isEmpty) {
      final result = await CategoryRepository.loadCategory();
      if (result != null) {
        list = result;
      }

      ///Notify
      if (parentId != null) {
        emit(CategorySuccess(list.where((item) {
          return item.name.toUpperCase().contains(keyword.toUpperCase()) &&
              item.parentId == parentId;
        }).toList()));
      } else {
        emit(CategorySuccess(list.where((item) {
          return item.name.toUpperCase().contains(keyword.toUpperCase());
        }).toList()));
      }
    } else {
      if (list.isEmpty) {
        final result = await CategoryRepository.loadCategory();
        if (result != null) {
          list = result;
        }
      }

      ///Notify
      emit(CategorySuccess(list.where((item) {
        return item.name.toUpperCase().contains(keyword.toUpperCase());
      }).toList()));
    }
  }
}
