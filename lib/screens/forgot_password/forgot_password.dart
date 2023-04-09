import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter/services.dart';

import '../../configs/application.dart';
import '../../configs/routes.dart';
import '../../repository/repository.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _textPhoneNumberController = TextEditingController();

  String? _errorPhoneNumber;
  String _countryPhoneCode = Application.setting.defaultCountryPhoneCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textPhoneNumberController.dispose();
    super.dispose();
  }

  ///Fetch API
  void _forgotPassword() {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _errorPhoneNumber = UtilValidator.validate(
        _textPhoneNumberController.text,
        type: ValidateType.phone,
      );
    });
    if (_errorPhoneNumber == null) {
      UserRepository.validationPhoneNumber(
              countryCode: _countryPhoneCode,
              phoneNumber: _textPhoneNumberController.text)
          .then((value) {
        if (value) {
          Navigator.pushNamed(
            context,
            Routes.otpForgotPassword,
            arguments: {
              "countryCode": _countryPhoneCode,
              "phoneNumber": _textPhoneNumberController.text
            },
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('forgot_password'),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                        trailing: GestureDetector(
                          dragStartBehavior: DragStartBehavior.down,
                          onTap: () {},
                          child: const Icon(Icons.clear),
                        ),
                        onSubmitted: (text) {
                          _forgotPassword();
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
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AppButton(
                    Translate.of(context).translate('reset_password'),
                    mainAxisSize: MainAxisSize.max,
                    onPressed: _forgotPassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
