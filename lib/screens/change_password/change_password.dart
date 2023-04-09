import 'package:akarak/repository/repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

import '../../configs/application.dart';
import '../../configs/routes.dart';
import '../../models/model.dart';
import '../../models/model_chat.dart';
import '../../notificationservice_.dart';
import '../../widgets/widget.dart';

class ChangePassword extends StatefulWidget {
  final String? token;
  final String? countryCode;
  final String? phoneNumber;

  const ChangePassword(
      {Key? key, this.token, this.countryCode, this.phoneNumber})
      : super(key: key);

  @override
  _ChangePasswordState createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  final _textPassController = TextEditingController();
  final _textConfirmPassController = TextEditingController();
  final _textCurrentPassController = TextEditingController();
  final _focusPass = FocusNode();
  final _focusConfirmPass = FocusNode();
  final _focusCurrentPass = FocusNode();

  String? _errorPass;
  String? _errorConfirmPass;
  String? _errorCurrentPass;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textPassController.dispose();
    _textConfirmPassController.dispose();
    _textCurrentPassController.dispose();
    _focusPass.dispose();
    _focusConfirmPass.dispose();
    _focusCurrentPass.dispose();
    super.dispose();
  }

  ///On change password
  void _changePassword() async {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _errorPass = UtilValidator.validate(
        _textPassController.text,
        min: 6,
      );
      _errorConfirmPass = UtilValidator.validate(
        _textConfirmPassController.text,
        match: _textPassController.text,
      );
      _errorCurrentPass = UtilValidator.validate(
        _textCurrentPassController.text,
        min: 6,
      );
    });
    if (widget.token != null &&
        _errorPass == null &&
        _errorConfirmPass == null) {
      final result = await UserRepository.resetPassword(
          countryCode: widget.countryCode!,
          phoneNumber: widget.phoneNumber!,
          newPassword: _textPassController.text,
          confirmNewPassword: _textConfirmPassController.text,
          token: widget.token!);
      if (result) {
        Navigator.pushReplacementNamed(context, Routes.signIn,
            arguments: Routes.account);
      }
    }
    if (_errorPass == null &&
        _errorConfirmPass == null &&
        _errorCurrentPass == null) {
      final result = await AppBloc.userCubit.onChangePassword(
          _textPassController.text,
          _textConfirmPassController.text,
          _textCurrentPassController.text);
      if (!mounted) return;
      if (result) {
        Navigator.pop(context);
      }
    }
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "changePasswordScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('change_password'),
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
                  focusNode: _focusPass,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textPassController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                      context,
                      _focusPass,
                      _focusConfirmPass,
                    );
                  },
                  onChanged: (text) {
                    setState(() {
                      _errorPass = UtilValidator.validate(
                        _textPassController.text,
                      );
                    });
                  },
                  controller: _textPassController,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('confirm_password'),
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate(
                    'confirm_your_password',
                  ),
                  errorText: _errorConfirmPass,
                  focusNode: _focusConfirmPass,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  trailing: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      _textConfirmPassController.clear();
                    },
                    child: const Icon(Icons.clear),
                  ),
                  onSubmitted: (text) {
                    UtilOther.fieldFocusChange(
                      context,
                      _focusConfirmPass,
                      _focusCurrentPass,
                    );
                  },
                  onChanged: (text) {
                    setState(() {
                      _errorConfirmPass = UtilValidator.validate(
                        _textConfirmPassController.text,
                      );
                    });
                  },
                  controller: _textConfirmPassController,
                ),
                if (widget.token == null) ...[
                  const SizedBox(height: 16),
                  Text(
                    Translate.of(context).translate('current_password'),
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppTextInput(
                    hintText: Translate.of(context).translate(
                      'current_password',
                    ),
                    errorText: _errorCurrentPass,
                    focusNode: _focusCurrentPass,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textCurrentPassController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    onSubmitted: (text) {
                      _changePassword();
                    },
                    onChanged: (text) {
                      setState(() {
                        _errorCurrentPass = UtilValidator.validate(
                          _textCurrentPassController.text,
                        );
                      });
                    },
                    controller: _textCurrentPassController,
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  Translate.of(context).translate('confirm'),
                  mainAxisSize: MainAxisSize.max,
                  onPressed: _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
