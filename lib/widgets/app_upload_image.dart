import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import '../configs/application.dart';

enum UploadImageShape { circle, square }

enum UploadType { product, profilePicture, document }

class AppUploadImage extends StatefulWidget {
  final String? title;
  final String? image;
  final Function(String) onChange;
  final UploadImageShape shape;
  final UploadType type;
  final bool isTemp;

  const AppUploadImage({
    Key? key,
    this.title,
    this.image,
    required this.onChange,
    this.shape = UploadImageShape.square,
    this.type = UploadType.product,
    this.isTemp = false,
  }) : super(key: key);

  @override
  _AppUploadImageState createState() {
    return _AppUploadImageState();
  }
}

class _AppUploadImageState extends State<AppUploadImage> {
  final _picker = ImagePicker();

  File? _file;
  double? _percent;
  bool _completed = false;
  bool showAction = false;
  Widget progress = Container();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void test(dynamic percent) {
    setState(() {
      _percent = percent;
    });
  }

  Future<void> _uploadImage() async {
    if (showAction) {
      setState(() {
        showAction = false;
      });
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;
      if (!mounted) return;
      setState(() {
        _completed = false;
        _file = File(pickedFile.path);
      });
      // final response = await ListRepository.uploadImage(_file!, (percent) {
      //   setState(() {
      //     _percent = percent;
      //   });
      // });
      final response = await ListRepository.uploadImageBytes(
          _file!, widget.type.index, widget.isTemp, (percent) {
        setState(() {
          _percent = percent;
        });
      });
      if (response.succeeded) {
        setState(() {
          _completed = true;
        });
        final item = response.data;
        widget.onChange(item);
      } else {
        AppBloc.messageCubit.onShow(response.message);
      }
    } catch (e) {
      AppBloc.messageCubit.onShow(e.toString());
    }
  }

  Widget? _buildContent() {
    if (widget.image != null && _file == null) return null;

    switch (widget.shape) {
      case UploadImageShape.circle:
        if (_file == null) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: const Icon(
              Icons.add,
              size: 18,
              color: Colors.white,
            ),
          );
        }

        if (_completed) {
          return Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).primaryColor,
          );
        } else if (_percent != null) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              _percent != null ? "${_percent?.toInt().toString()}%" : '',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          );
        }
        return Container();

      default:
        if (_file == null) {
          Widget title = Container();
          if (widget.title != null) {
            title = Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.caption,
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title,
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }

        if (_completed) {
          return Container(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.check_circle,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        // if (_percent != null && _percent! < 100) {
        //   return Container(
        //     alignment: Alignment.bottomLeft,
        //     child: Container(
        //         clipBehavior: Clip.antiAlias,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(2),
        //         ),
        //         child: LinearProgressIndicator(
        //           value: _percent,
        //           semanticsValue: _percent?.toString() ?? "00",
        //           semanticsLabel: _percent?.toString() ?? "00",
        //           backgroundColor: Theme.of(context).cardColor,
        //         )),
        //   );
        // }

        // return Container(
        //   alignment: Alignment.bottomLeft,
        //   child: Container(
        //     clipBehavior: Clip.antiAlias,
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(2),
        //     ),
        //     child: LinearProgressIndicator(
        //       backgroundColor: Theme.of(context).cardColor,
        //     ),
        //   ),
        // );
        return Container(
          alignment: Alignment.bottomLeft,
          child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                fit: StackFit.loose,
                clipBehavior: Clip.hardEdge,
                children: [
                  if (_percent != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        alignment: Alignment.topRight,
                        child: Text(
                          "${_percent!.toInt().toString()}%",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: LinearProgressIndicator(
                      value: _percent,
                      semanticsValue: _percent?.toString() ?? "00",
                      semanticsLabel: _percent?.toString() ?? "00",
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                ],
              )),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    DecorationImage? decorationImage;
    BorderType borderType = BorderType.RRect;
    Widget circle = Container();

    if (widget.image != null) {
      decorationImage = DecorationImage(
        image: NetworkImage(
          !widget.image!.startsWith(Application.domain)
              ? "${Application.domain}${widget.image!.replaceAll("TYPE", "full").replaceAll("\\", "/")}"
              : widget.image!.replaceAll("TYPE", "full").replaceAll("\\", "/"),
        ),
        fit: BoxFit.cover,
      );
    }
    if (_file != null) {
      decorationImage = DecorationImage(
        image: FileImage(
          _file!,
        ),
        fit: BoxFit.cover,
      );
    }

    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: decorationImage,
    );

    if (widget.shape == UploadImageShape.circle) {
      borderType = BorderType.Circle;
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        image: decorationImage,
      );
      if (_percent != null && _percent! < 100) {
        circle = CircularProgressIndicator(
          value: _percent,
          semanticsValue: _percent?.toString() ?? "00",
          semanticsLabel: _percent?.toString() ?? "00",
          backgroundColor: Theme.of(context).cardColor,
        );
      } else if (_file != null && !_completed) {
        circle = const CircularProgressIndicator();
      }
    }

    return InkWell(
      onTap: _uploadImage,
      child: Stack(
        children: [
          DottedBorder(
            borderType: borderType,
            radius: const Radius.circular(8),
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: decoration,
              alignment: Alignment.center,
              child: _buildContent(),
            ),
          ),
          Positioned.fill(child: circle),
        ],
      ),
    );
  }
}
