import 'package:akarak/models/model.dart';

abstract class ReviewState {}

class ReviewLoading extends ReviewState {}

class RatingSuccess extends ReviewState {
  final RateModel rating;

  RatingSuccess({
    required this.rating,
  });
}

class ReviewSuccess extends ReviewState {
  final List<CommentModel> list;
  final bool canLoadMore;

  ReviewSuccess({
    required this.list,
    required this.canLoadMore,
  });
}
class ReviewByIdSuccess extends ReviewState {
  final int? productId;
  final List<CommentModel> list;
  final RateModel rate;

  ReviewByIdSuccess({
    this.productId,
    required this.list,
    required this.rate,
  });
}
