import 'package:bloc/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class AddressListCubit extends Cubit<AddressListState> {
  AddressListCubit() : super(AddressListLoading());

  int pageNumber = 1;
  List<AddressModel>? list = [];

  Future<void> onLoad() async {
    pageNumber = 1;

    ///Fetch API
    final result = await AddressRepository.loadAllAddresses();
    list = result;

    ///Notify
    emit(AddressListSuccess(
      list: list,
    ));
  }
}
