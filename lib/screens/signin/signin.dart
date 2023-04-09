// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';

class SignIn extends StatefulWidget {
  final String from;
  const SignIn({Key? key, required this.from}) : super(key: key);

  @override
  _SignInState createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
  final _textIDController = TextEditingController();
  final _textPassController = TextEditingController();
  final _focusID = FocusNode();
  final _focusPass = FocusNode();

  bool _showPassword = false;
  String? _errorID;
  String? _errorPass;
  String _countryPhoneCode = Application.setting.defaultCountryPhoneCode;

  @override
  void initState() {
    super.initState();
    _textIDController.text = "777517527";
    _textPassController.text = r'123Pa$$word!';
  }

  @override
  void dispose() {
    _textIDController.dispose();
    _textPassController.dispose();
    _focusID.dispose();
    _focusPass.dispose();
    super.dispose();
  }

  ///On navigate forgot password
  void _forgotPassword() {
    Navigator.pushNamed(context, Routes.forgotPassword);
  }

  ///On navigate sign up
  void _signUp() {
    Navigator.pushNamed(context, Routes.signUp);
  }

  ///On login
  void _login() async {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _errorID = UtilValidator.validate(
        _textIDController.text,
        type: ValidateType.phone,
        allowEmpty: false,
      );
      _errorPass = UtilValidator.validate(_textPassController.text);
    });
    if (_errorID == null && _errorPass == null) {
      AppBloc.loginCubit.onLogin(
        countryCode: _countryPhoneCode,
        phoneNumber: _textIDController.text,
        password: _textPassController.text,
      );
      if (AppBloc.userCubit.state != null) {
        AppBloc.loginCubit.onFetch();
      }

      if (AppBloc.userCubit.state != null) {
        // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        //   if (!isAllowed) {
        //     // This is just a basic example. For real apps, you must show some
        //     // friendly dialog box before call the request method.
        //     // This is very important to not harm the user experience
        //     AwesomeNotifications().requestPermissionToSendNotifications();
        //   }
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('sign_in'),
        ),
      ),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, login) {
          if (login == LoginState.success) {
            Navigator.pop(context, widget.from);
          }
        },
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: AppTextInput(
                          hintText: Translate.of(context)
                              .translate('input_phone_number'),
                          errorText: _errorID,
                          focusNode: _focusID,
                          trailing: GestureDetector(
                            dragStartBehavior: DragStartBehavior.down,
                            onTap: () {
                              _textIDController.clear();
                            },
                            child: const Icon(Icons.clear),
                          ),
                          onSubmitted: (text) {
                            UtilOther.fieldFocusChange(
                              context,
                              _focusID,
                              _focusPass,
                            );
                          },
                          onChanged: (text) {
                            setState(() {
                              _errorID = UtilValidator.validate(
                                _textIDController.text,
                                type: ValidateType.phone,
                              );
                            });
                          },
                          controller: _textIDController,
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
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText: Translate.of(context).translate('password'),
                    errorText: _errorPass,
                    textInputAction: TextInputAction.done,
                    onChanged: (text) {
                      setState(() {
                        _errorPass = UtilValidator.validate(
                          _textPassController.text,
                        );
                      });
                    },
                    onSubmitted: (text) {
                      _login();
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
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, login) {
                      return AppButton(
                        Translate.of(context).translate('sign_in'),
                        mainAxisSize: MainAxisSize.max,
                        onPressed: _login,
                        loading: login == LoginState.loading,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AppButton(
                        Translate.of(context).translate('forgot_password'),
                        onPressed: _forgotPassword,
                        type: ButtonType.text,
                      ),
                      AppButton(
                        Translate.of(context).translate('sign_up'),
                        onPressed: _signUp,
                        type: ButtonType.text,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
