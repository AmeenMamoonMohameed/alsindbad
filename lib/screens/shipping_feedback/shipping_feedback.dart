import 'package:akarak/repository/order_repository.dart';
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

class ShippingFeedback extends StatefulWidget {
  final int orderId;

  const ShippingFeedback({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _ShippingFeedbackState createState() {
    return _ShippingFeedbackState();
  }
}

class _ShippingFeedbackState extends State<ShippingFeedback> {
  final _textReviewController = TextEditingController();
  final _focusReview = FocusNode();

  String? _errorReview;
  String? _errorRating;
  double _rate = 1;

  @override
  void initState() {
    super.initState();
    _rate = 1;
    _textReviewController.text = '';
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
      _errorRating = _rate == 0
          ? Translate.of(context).translate('the_minimum_rating_is_1')
          : null;
    });
    if (_errorReview == null && _errorRating == null) {
      final result = await OrderRepository.shippingFeedback(
        orderId: widget.orderId,
        rate: _rate,
        review: _textReviewController.text,
      );
      if (result) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('delivery_boy_rating'),
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
                    RatingBar.builder(
                      initialRating: _rate,
                      minRating: 1,
                      allowHalfRating: true,
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
