import 'package:akarak/models/model.dart';

abstract class SubmitMessageState {}

class SubmitLoading extends SubmitMessageState {}

class SubmitSuccess extends SubmitMessageState {
  final int? id;
  SubmitSuccess(this.id);
}
