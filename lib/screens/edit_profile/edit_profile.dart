import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:vibration/vibration.dart';

import '../../configs/application.dart';
import '../../configs/routes.dart';
import '../../notificationservice_.dart';
import '../../widgets/widget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  final _textAccountNameController = TextEditingController();
  final _textFullNameController = TextEditingController();
  final _textPhoneNumberController = TextEditingController();
  final _textEmailController = TextEditingController();
  final _textWebsiteController = TextEditingController();
  final _textInfoController = TextEditingController();
  final _focusAccountName = FocusNode();
  final _focusFullName = FocusNode();
  final _focusPhoneNumber = FocusNode();
  final _focusEmail = FocusNode();
  final _focusWebsite = FocusNode();
  final _focusInfo = FocusNode();
  final picker = ImagePicker();

  String? _image;
  String? _errorAccountName;
  String? _errorFullName;
  String? _errorPhoneNumber;
  String? _errorEmail;
  String? _errorWebsite;
  String? _errorInfo;
  int _gender = 0;
  bool _isAppearPhoneNumber = false;
  String _countryPhoneCode = Application.setting.defaultCountryPhoneCode;

  @override
  void initState() {
    super.initState();
    final user = AppBloc.userCubit.state!;
    _countryPhoneCode = user.countryCode;
    _textAccountNameController.text = user.accountName;
    _textFullNameController.text = user.fullName;
    _textPhoneNumberController.text = user.phoneNumber;
    _textEmailController.text = user.email;
    _textWebsiteController.text = user.url;
    _textInfoController.text = user.description;
    _isAppearPhoneNumber = user.isAppearPhoneNumber;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On update image
  void _updateProfile() async {
    UtilOther.hiddenKeyboard(context);

    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }

    setState(() {
      _errorAccountName =
          UtilValidator.validate(_textAccountNameController.text);
      _errorFullName = UtilValidator.validate(_textFullNameController.text);
      _errorPhoneNumber = UtilValidator.validate(
        _textPhoneNumberController.text,
        type: ValidateType.number,
        allowEmpty: false,
      );
      _errorEmail = UtilValidator.validate(
        _textEmailController.text,
        type: ValidateType.email,
      );
      _errorWebsite = UtilValidator.validate(_textWebsiteController.text);
      _errorInfo = UtilValidator.validate(_textInfoController.text);
    });
    if (_errorAccountName == null &&
        _errorFullName == null &&
        _errorPhoneNumber == null &&
        _errorEmail == null &&
        _errorWebsite == null &&
        _errorInfo == null) {
      ///Fetch change profile
      final result = await AppBloc.userCubit.onUpdateUser(
          accountName: _textAccountNameController.text,
          fullName: _textFullNameController.text,
          phoneNumber: _textPhoneNumberController.text,
          isAppearPhoneNumber: _isAppearPhoneNumber,
          email: _textEmailController.text,
          url: _textWebsiteController.text,
          description: _textInfoController.text,
          image: _image);

      ///Case success
      if (result) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "homeScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('edit_profile')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: AppUploadImage(
                          shape: UploadImageShape.circle,
                          type: UploadType.profilePicture,
                          isTemp: true,
                          image: AppBloc.userCubit.state!.profilePictureDataUrl,
                          onChange: (result) {
                            setState(() {
                              _image = result;
                            });
                            // AppBloc.userCubit.onFetchUser();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('account_name'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText:
                        Translate.of(context).translate('input_account_name'),
                    errorText: _errorAccountName,
                    focusNode: _focusAccountName,
                    textInputAction: TextInputAction.next,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textAccountNameController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      UtilOther.fieldFocusChange(
                        context,
                        _focusAccountName,
                        _focusFullName,
                      );
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorAccountName = UtilValidator.validate(
                          _textAccountNameController.text,
                        );
                      });
                    },
                    controller: _textAccountNameController,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('full_name'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText:
                        Translate.of(context).translate('input_full_name'),
                    errorText: _errorFullName,
                    focusNode: _focusFullName,
                    textInputAction: TextInputAction.next,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textFullNameController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      UtilOther.fieldFocusChange(
                        context,
                        _focusFullName,
                        _focusPhoneNumber,
                      );
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorFullName = UtilValidator.validate(
                          _textFullNameController.text,
                        );
                      });
                    },
                    controller: _textFullNameController,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('gender'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppPickerItem(
                    title: Translate.of(context).translate('choose_gender'),
                    value: _gender == 0
                        ? Translate.of(context).translate('male')
                        : Translate.of(context).translate('female'),
                    withTooltip: true,
                    onPressed: () {
                      AppBloc.messageCubit.onShow('gender_cannot_be_changed');
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('phone'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: AppTextInput(
                          hintText: Translate.of(context)
                              .translate('input_phone_number'),
                          errorText: _errorPhoneNumber,
                          focusNode: _focusPhoneNumber,
                          readOnly: true,
                          trailing: GestureDetector(
                            dragStartBehavior: DragStartBehavior.down,
                            onTap: () {},
                            child: const Icon(Icons.clear),
                          ),
                          onSubmitted: (text) {
                            UtilOther.fieldFocusChange(
                              context,
                              _focusPhoneNumber,
                              _focusEmail,
                            );
                          },
                          onChanged: (text) {
                            setState(() {
                              _errorPhoneNumber = UtilValidator.validate(
                                _textPhoneNumberController.text,
                                type: ValidateType.phone,
                              );
                            });
                          },
                          controller: _textPhoneNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: TextButton(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _countryPhoneCode,
                                  textDirection: TextDirection.ltr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        Translate.of(context).translate(
                                          'select_country',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .hintColor),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ]),
                          onPressed: () {
                            // showCountryPicker(
                            //   context: context,
                            //   showPhoneCode:
                            //       true, // optional. Shows phone code before the country name.
                            //   onSelect: (Country country) {
                            //     setState(() {
                            //       _countryPhoneCode = "+${country.phoneCode}";
                            //     });
                            //   },
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAppearPhoneNumber = !_isAppearPhoneNumber;
                      });
                    },
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Checkbox(
                          value: _isAppearPhoneNumber,
                          onChanged: (value) {
                            setState(() {
                              _isAppearPhoneNumber = value!;
                            });
                          },
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Center(
                            child: Text(
                              Translate.of(context).translate(
                                  'do_you_want_to_show_the_phone_number_in_the_profile'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('email'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText: Translate.of(context).translate('input_email'),
                    errorText: _errorEmail,
                    focusNode: _focusEmail,
                    textInputAction: TextInputAction.next,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textEmailController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      UtilOther.fieldFocusChange(
                        context,
                        _focusEmail,
                        _focusWebsite,
                      );
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorEmail = UtilValidator.validate(
                          _textEmailController.text,
                          type: ValidateType.email,
                        );
                      });
                    },
                    controller: _textEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('website'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText: Translate.of(context).translate(
                      'input_website',
                    ),
                    errorText: _errorWebsite,
                    focusNode: _focusWebsite,
                    textInputAction: TextInputAction.next,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textWebsiteController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      UtilOther.fieldFocusChange(
                        context,
                        _focusWebsite,
                        _focusInfo,
                      );
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorWebsite = UtilValidator.validate(
                          _textWebsiteController.text,
                        );
                      });
                    },
                    controller: _textWebsiteController,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('information'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: Color(0xff3a5ba0)),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText: Translate.of(context).translate(
                      'input_information',
                    ),
                    errorText: _errorInfo,
                    focusNode: _focusInfo,
                    maxLines: 5,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textInfoController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      _updateProfile();
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorInfo = UtilValidator.validate(
                          _textInfoController.text,
                        );
                      });
                    },
                    controller: _textInfoController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                Translate.of(context).translate('confirm'),
                mainAxisSize: MainAxisSize.max,
                onPressed: _updateProfile,
              ),
            )
          ],
        ),
      ),
    );
  }
}
