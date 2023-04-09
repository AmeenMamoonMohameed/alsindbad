import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../../configs/application.dart';
import '../../configs/image.dart';

class Feedback extends StatefulWidget {
  final int productId;
  final double? totalRate;
  final CommentModel? review;
  final String? type;

  const Feedback({
    Key? key,
    required this.productId,
    this.totalRate,
    this.review,
    this.type,
  }) : super(key: key);

  @override
  _FeedbackState createState() {
    return _FeedbackState();
  }
}

class _FeedbackState extends State<Feedback> {
  final _textReviewController = TextEditingController();
  final _focusReview = FocusNode();

  String? _errorReview;
  String? _errorRating;
  double _rate = 1;

  @override
  void initState() {
    super.initState();
    if (widget.type == "replay" &&
        widget.review != null &&
        widget.review!.reviewType != ReviewType.replayForReview) {
      if (widget.totalRate != null && widget.totalRate != 0) {
        _rate = widget.totalRate!;
      }
      _textReviewController.text = '';
    } else if (widget.type == "replay" &&
        widget.review != null &&
        widget.review!.reviewType == ReviewType.replayForReview) {
      if (widget.totalRate != null && widget.totalRate != 0) {
        _rate = widget.totalRate!;
      }
      _textReviewController.text =
          widget.review == null ? '' : widget.review!.content;
    } else {
      _rate =
          widget.review == null ? widget.totalRate ?? 0 : widget.review!.rating;
      _textReviewController.text =
          widget.review == null ? '' : widget.review!.content;
    }
  }

  @override
  void dispose() {
    _textReviewController.dispose();
    _focusReview.dispose();
    super.dispose();
  }

  ///On send
  void _onSave() async {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _errorReview = UtilValidator.validate(_textReviewController.text);
      _errorRating = _rate == 0 && widget.type != "replay"
          ? Translate.of(context).translate('the_minimum_rating_is_1')
          : null;
    });
    if (_errorReview == null && _errorRating == null) {
      if (widget.type == "replay" &&
          widget.review != null &&
          widget.review!.reviewType != ReviewType.replayForReview) {
        // For new replay
        final result = await AppBloc.reviewCubit.onSaveReplay(
          id: 0,
          reviewId: widget.review!.id,
          productId: widget.productId,
          content: _textReviewController.text,
        );
        if (result) {
          if (!mounted) return;
          Navigator.pop(context);
        }
      } else if (widget.review != null &&
          widget.review!.reviewType == ReviewType.replayForReview) {
        // For edit replay
        final result = await AppBloc.reviewCubit.onSaveReplay(
          id: widget.review == null ? 0 : widget.review!.id,
          reviewId: widget.review!.parentId,
          productId: widget.productId,
          content: _textReviewController.text,
        );
        if (result) {
          if (!mounted) return;
          Navigator.pop(context);
        }
      } else {
        final result = await AppBloc.reviewCubit.onSave(
          id: widget.review == null ? 0 : widget.review!.id,
          productId: widget.productId,
          content: _textReviewController.text,
          rate: _rate,
        );
        if (result) {
          if (!mounted) return;
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('feedback'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (AppBloc
                            .userCubit.state!.profilePictureDataUrl.isEmpty)
                          Image.asset(
                            Images.user,
                            height: 60,
                            width: 60,
                          ),
                        if (AppBloc
                            .userCubit.state!.profilePictureDataUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: Application.domain +
                                AppBloc.userCubit.state!.profilePictureDataUrl
                                    .replaceAll("\\", "/")
                                    .replaceAll("TYPE", "thumb"),
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) {
                              return AppPlaceholder(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return AppPlaceholder(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.error),
                                ),
                              );
                            },
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (widget.review == null ||
                        (widget.type != "replay" &&
                            widget.review!.reviewType !=
                                ReviewType.replayForReview))
                      RatingBar.builder(
                        initialRating: _rate == 0 ? 1 : _rate,
                        minRating: 1,
                        allowHalfRating: false,
                        unratedColor: Colors.amber.withAlpha(100),
                        itemCount: 5,
                        itemSize: 24.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rate) {
                          setState(() {
                            _rate = rate;
                          });
                        },
                      ),
                    Text(
                      Translate.of(context).translate('tap_rate'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    if (_errorRating != null)
                      Text(
                        _errorRating!,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(color: Theme.of(context).errorColor),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              Translate.of(context).translate('description'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppTextInput(
                            hintText: Translate.of(context).translate(
                              'input_feedback',
                            ),
                            errorText: _errorReview,
                            focusNode: _focusReview,
                            maxLines: 5,
                            trailing: GestureDetector(
                              dragStartBehavior: DragStartBehavior.down,
                              onTap: () {
                                _textReviewController.clear();
                              },
                              child: const Icon(Icons.clear),
                            ),
                            onSubmitted: (text) {
                              _onSave();
                            },
                            onChanged: (text) {
                              setState(() {
                                _errorReview = UtilValidator.validate(
                                  _textReviewController.text,
                                );
                              });
                            },
                            controller: _textReviewController,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppButton(
                Translate.of(context).translate('send'),
                onPressed: _onSave,
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        ),
      ),
    );
  }
}
