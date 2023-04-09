import 'package:akarak/models/model.dart';

abstract class AddressListState {}

class AddressListLoading extends AddressListState {}

class AddressListSuccess extends AddressListState {
  final List<AddressModel>? list;

  AddressListSuccess({
    required this.list,
  });
}
