import 'package:akarak/models/model.dart';

abstract class BlockedUsersState {}

class BlockedUsersLoading extends BlockedUsersState {}

class BlockedUsersSuccess extends BlockedUsersState {
  BlockedUsersSuccess();
}

