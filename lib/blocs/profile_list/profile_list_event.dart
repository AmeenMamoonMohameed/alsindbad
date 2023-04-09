import 'package:akarak/models/model.dart';

abstract class ProfileListEvent {}

class OnLoadProfileList extends ProfileListEvent {
  final String keyword;
  final bool listing;

  OnLoadProfileList({
    required this.keyword,
    required this.listing,
  });
}

class OnLoadMoreProfileList extends ProfileListEvent {
  final String keyword;
  final bool listing;

  OnLoadMoreProfileList({
    required this.keyword,
    required this.listing,
  });
}

class OnProfileListSearch extends ProfileListEvent {
  final String keyword;
  final bool listing;

  OnProfileListSearch({
    required this.keyword,
    required this.listing,
  });
}
