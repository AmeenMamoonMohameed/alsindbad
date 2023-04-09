import 'package:akarak/repository/repository.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

import '../../configs/application.dart';
import '../../configs/routes.dart';
import '../../models/model.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final _textIDController = TextEditingController();
  final _textFullNameController = TextEditingController();
  final _textPassController = TextEditingController();
  final _textConfirmPassController = TextEditingController();
  final _textPhoneNumberController = TextEditingController();
  final _textEmailController = TextEditingController();
  final _focusID = FocusNode();
  final _focusFullName = FocusNode();
  final _focusPass = FocusNode();
  final _focusConfirmPass = FocusNode();
  final _focusPhoneNumber = FocusNode();
  final _focusEmail = FocusNode();

  int _gender = 0;
  bool _isAppearPhoneNumber = false;
  bool _showPassword = false;
  String? _errorID;
  String? _errorFullName;
  String? _errorPass;
  String? _errorConfirmPass;
  String? _errorPhoneNumber;
  String? _errorEmail;

  String _countryPhoneCode = Application.setting.defaultCountryPhoneCode;
  int _userType = 0;

  @override
  void initState() {
    super.initState();
    UserRepository.loadRegUserId().then((value) {
      if (value != null) {
        Navigator.pushReplacementNamed(
          context,
          Routes.otp,
          arguments: {"userId": value, "routeName": Routes.signIn},
        );
      }
    });
  }

  @override
  void dispose() {
    _textIDController.dispose();
    _textFullNameController.dispose();
    _textPassController.dispose();
    _textConfirmPassController.dispose();
    _textPhoneNumberController.dispose();
    _textEmailController.dispose();
    _focusID.dispose();
    _focusFullName.dispose();
    _focusPass.dispose();
    _focusConfirmPass.dispose();
    _focusPhoneNumber.dispose();
    _focusEmail.dispose();
    super.dispose();
  }

  ///On Select Gender
  void _onSelectGender() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          name: Translate.of(context).translate('choose_gender'),
          selected: [
            _gender == 0
                ? Translate.of(context).translate('male')
                : Translate.of(context).translate('female')
          ],
          data: [
            Translate.of(context).translate("male"),
            Translate.of(context).translate("female")
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _gender = selected == Translate.of(context).translate("male") ? 0 : 1;
      });
    }
  }

  ///On sign up
  void _signUp() async {
    UtilOther.hiddenKeyboard(context);
    // Navigator.pushNamed(context, Routes.otp, arguments: "result");
    setState(() {
      _errorID = UtilValidator.validate(_textIDController.text, min: 6);
      _errorFullName =
          UtilValidator.validate(_textFullNameController.text, min: 10);
      _errorPass = UtilValidator.validate(
        _textPassController.text,
        min: 6,
      );
      _errorConfirmPass = UtilValidator.validate(
        _textConfirmPassController.text,
        match: _textPassController.text,
      );
      _errorPhoneNumber = UtilValidator.validate(
        _textPhoneNumberController.text,
        type: ValidateType.phone,
      );
      _errorEmail = UtilValidator.validate(_textEmailController.text,
          type: ValidateType.email, allowEmpty: true);
    });
    if (_errorID == null &&
        _errorFullName == null &&
        _errorPass == null &&
        _errorConfirmPass == null &&
        _errorPhoneNumber == null &&
        _errorEmail == null) {
      final result = await AppBloc.userCubit.onRegister(
        accountName: _textIDController.text,
        fullName: _textFullNameController.text,
        gender: _gender,
        isAppearPhoneNumber: _isAppearPhoneNumber,
        password: _textPassController.text,
        confirmPassword: _textConfirmPassController.text,
        countryCode: _countryPhoneCode,
        phoneNumber: _textPhoneNumberController.text,
        email: _textEmailController.text.trim().isNotEmpty
            ? _textEmailController.text.trim()
            : null,
        userType: _userType,
      );
      if (result != null) {
        await UserRepository.saveRegUserId(result);
        Navigator.pushReplacementNamed(
          context,
          Routes.otp,
          arguments: {"userId": result, "routeName": Routes.account},
        );
        // if (!mounted) return;
        // Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('sign_up'),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Translate.of(context).translate('account_name'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_id'),
                  errorText: _errorID,
                  controller: _textIDController,
                  focusNode: _focusID,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorID = UtilValidator.validate(_textIDController.text);
                    });
                  },
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                        context, _focusID, _focusFullName);
                  },
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textIDController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('full_name'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_full_name'),
                  errorText: _errorFullName,
                  controller: _textFullNameController,
                  focusNode: _focusFullName,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorFullName =
                          UtilValidator.validate(_textFullNameController.text);
                    });
                  },
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                        context, _focusFullName, _focusPass);
                  },
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textFullNameController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
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
                  onPressed: _onSelectGender,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('password'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate(
                    'input_your_password',
                  ),
                  errorText: _errorPass,
                  onChanged: (text) {
                    setState(() {
                      _errorPass = UtilValidator.validate(
                        _textPassController.text,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                      context,
                      _focusPass,
                      _focusConfirmPass,
                    );
                  },
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                  obscureText: !_showPassword,
                  controller: _textPassController,
                  focusNode: _focusPass,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('confirm_password'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate(
                    'input_confirm_password',
                  ),
                  errorText: _errorConfirmPass,
                  onChanged: (text) {
                    setState(() {
                      _errorConfirmPass = UtilValidator.validate(
                        _textConfirmPassController.text,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                      context,
                      _focusConfirmPass,
                      _focusPhoneNumber,
                    );
                  },
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textPhoneNumberController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                  obscureText: true,
                  controller: _textConfirmPassController,
                  focusNode: _focusConfirmPass,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('phone_number'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
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
                        trailing: GestureDetector(
                          dragStartBehavior: DragStartBehavior.down,
                          onTap: () {
                            _textPhoneNumberController.clear();
                          },
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
                      width: MediaQuery.of(context).size.width * 0.36,
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
                                              color:
                                                  Theme.of(context).hintColor),
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
                          showCountryPicker(
                            context: context,
                            showPhoneCode:
                                true, // optional. Shows phone code before the country name.
                            onSelect: (Country country) {
                              setState(() {
                                _countryPhoneCode = "+${country.phoneCode}";
                              });
                            },
                          );
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
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_email'),
                  errorText: _errorEmail,
                  focusNode: _focusEmail,
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textEmailController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                  onSubmitted: (text) {
                    _signUp();
                  },
                  onChanged: (text) {
                    setState(() {
                      _errorEmail = UtilValidator.validate(
                          _textEmailController.text,
                          type: ValidateType.email,
                          allowEmpty: true);
                    });
                  },
                  controller: _textEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('user_account_type'),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  leading: Icon(
                    Icons.child_friendly_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                  value: _userType == 0
                      ? Translate.of(context).translate('property_owner')
                      : _userType == 1
                          ? Translate.of(context).translate('broker')
                          : _userType == 2
                              ? Translate.of(context).translate('office')
                              : Translate.of(context).translate('company'),
                  title: Translate.of(context)
                      .translate('select_the_type_of_user_account'),
                  onPressed: () async {
                    final result = await showModalBottomSheet<String?>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) => AppBottomPicker(
                        picker: PickerModel(
                          selected: [
                            _userType == 0
                                ? Translate.of(context)
                                    .translate('property_owner')
                                : _userType == 1
                                    ? Translate.of(context).translate('broker')
                                    : _userType == 2
                                        ? Translate.of(context)
                                            .translate('office')
                                        : Translate.of(context)
                                            .translate('company'),
                          ],
                          data: [
                            Translate.of(context).translate('property_owner'),
                            Translate.of(context).translate('broker'),
                            Translate.of(context).translate('office'),
                            Translate.of(context).translate('company'),
                          ],
                        ),
                      ),
                    );

                    setState(() {
                      if (result != null) {
                        _userType = result ==
                                Translate.of(context)
                                    .translate('property_owner')
                            ? 0
                            : result ==
                                    Translate.of(context).translate('broker')
                                ? 1
                                : result ==
                                        Translate.of(context)
                                            .translate('office')
                                    ? 2
                                    : 3;
                      }
                    });
                  },
                ),
                if (UserType.values[_userType] == UserType.owner)
                  Text(
                    Translate.of(context).translate(
                        "all_the_services_of_the_owner_of_the_owner_of_the_real_estate_are_completely_free"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.red,
                        fontWeight: FontWeight.w100),
                    maxLines: 3,
                  ),

                const SizedBox(height: 16),
                AppButton(
                  Translate.of(context).translate('sign_up'),
                  mainAxisSize: MainAxisSize.max,
                  onPressed: _signUp,
                ),
                // const SizedBox(height: 16),
                // AppButton(
                //   "${Translate.of(context).translate('sign_up')} ${Translate.of(context).translate('with_google')}",
                //   mainAxisSize: MainAxisSize.max,
                //   onPressed: _signUpGoogle,
                //   icon: FaIcon(
                //     FontAwesomeIcons.google,
                //     color: Theme.of(context).splashColor,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
