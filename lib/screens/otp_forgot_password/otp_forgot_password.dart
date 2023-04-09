import 'dart:async';
import 'package:flutter/material.dart';
import 'package:akarak/utils/utils.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../blocs/bloc.dart';
import '../../configs/image.dart';
import '../../configs/routes.dart';
import '../../repository/repository.dart';

class OtpForgotPassword extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;

  const OtpForgotPassword(
      {Key? key, required this.countryCode, required this.phoneNumber})
      : super(key: key);

  @override
  _OtpForgotPasswordState createState() {
    return _OtpForgotPasswordState();
  }
}

class _OtpForgotPasswordState extends State<OtpForgotPassword>
    with TickerProviderStateMixin {
  // Constants
  late int time = 60;
  late AnimationController _controller;

  // Variables
  late Size _screenSize;
  late String? _currentDigit;

  late Timer timer;
  late int totalTimeInSeconds;
  late bool _hideResendButton = false;
  late bool _isFirst = true;

  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  _OtpForgotPasswordState() {
    _currentDigit = null;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Returns "Appbar"
  get _getAppbar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: const Icon(
          Icons.close_outlined,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return Text(
      Translate.of(context).translate("reset_password"),
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 28.0,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold),
    );
  }

  // Return "OtpForgotPassword" label
  get _getOtpForgotPasswordLabel {
    return Text(
      _isFirst
          ? Translate.of(context)
              .translate("password_reset_by_verification_code")
          : Translate.of(context)
              .translate("enter_the_verification_code_you_received"),
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w500),
      maxLines: 3,
    );
  }

  // Return "VirifyBy" label
  get _getVirifyBy {
    if (!_hideResendButton) {
      return Text(
        Translate.of(context).translate(_isFirst
            ? "select_how_to_verify_the_phone_number"
            : "select_how_to_re_verify_the_phone_number"),
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w500),
        maxLines: 3,
      );
    }
    return Text(
      Translate.of(context)
          .translate("you_cannot_resend_until_the_resend_timer_expires"),
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w300),
      maxLines: 3,
    );
  }

  // Returns "Resend" button
  get _getResendButton {
    return Column(
      children: [
        InkWell(
          child: Container(
              height: 32,
              width: 230,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(32)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isFirst
                        ? Translate.of(context).translate("send_by_sms")
                        : Translate.of(context).translate("resend_by_sms"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
                    Icons.sms,
                    color: Color(0xff018afc),
                  ),
                ],
              )),
          onTap: () async {
            var secondsForAllowResendOtpForgotPassword =
                await UserRepository.sendVerifiyCodeForgotPassword(
              countryCode: widget.countryCode,
              phoneNumber: widget.phoneNumber,
              confirmType: "sms",
            );
            if (secondsForAllowResendOtpForgotPassword != null) {
              time = (secondsForAllowResendOtpForgotPassword).toInt();
              initController();
              setState(() {
                _startCountdown();
                if (_isFirst == true) {
                  _isFirst = false;
                }
              });
            }
          },
        ),
        const SizedBox(
          height: 16,
        ),
        InkWell(
          child: Container(
              height: 32,
              width: 230,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(32)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isFirst
                        ? Translate.of(context).translate("send_by_whatsapp")
                        : Translate.of(context).translate("resend_by_whatsapp"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Image.asset(Images.whatsapp, width: 40, height: 40),
                ],
              )),
          onTap: () async {
            var secondsForAllowResendOtpForgotPassword =
                await UserRepository.sendVerifiyCodeForgotPassword(
              countryCode: widget.countryCode,
              phoneNumber: widget.phoneNumber,
              confirmType: "whatsapp",
            );
            if (secondsForAllowResendOtpForgotPassword != null) {
              time = (secondsForAllowResendOtpForgotPassword).toInt();
              initController();
              setState(() {
                _startCountdown();
                if (_isFirst == true) {
                  _isFirst = false;
                }
              });
            }
          },
        ),
        const SizedBox(
          height: 16,
        ),
        InkWell(
          child: Container(
              height: 32,
              width: 230,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(32)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isFirst
                        ? Translate.of(context).translate("send_by_call")
                        : Translate.of(context).translate("resend_by_call"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
                    Icons.call,
                    color: Color(0xffed1b24),
                  ),
                ],
              )),
          onTap: () async {
            var secondsForAllowResendOtpForgotPassword =
                await UserRepository.sendVerifiyCodeForgotPassword(
              countryCode: widget.countryCode,
              phoneNumber: widget.phoneNumber,
              confirmType: "call",
            );
            if (secondsForAllowResendOtpForgotPassword != null) {
              time = (secondsForAllowResendOtpForgotPassword).toInt();
              initController();
              setState(() {
                _startCountdown();
                if (_isFirst == true) {
                  _isFirst = false;
                }
              });
            }
          },
        ),
      ],
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: Offstage(
        offstage: !_hideResendButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.access_time,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 5.0,
            ),
            OtpForgotPasswordTimer(
                _controller, 15.0, Theme.of(context).primaryColor)
          ],
        ),
      ),
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const SizedBox(height: 16),
        _getVerificationCodeLabel,
        const SizedBox(height: 16),
        _getOtpForgotPasswordLabel,
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            _getInputField,
            const SizedBox(height: 8),
            Icon(
              Icons.arrow_back,
              textDirection: TextDirection.rtl,
              color: Theme.of(context).dividerColor,
            )
          ],
        ),
        const SizedBox(height: 16),
        _getVirifyBy,
        const SizedBox(height: 16),
        _hideResendButton ? _getTimerText : _getResendButton,
      ],
    ));
  }

  // Return "OTP" input field
  get _getInputField {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16, right: 8, left: 8),
        child: _autoFillTextField(),
      ),
    );
  }

  void initController() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton;
              });
            }
          });
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    initController();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: _getAppbar,
          backgroundColor: const Color.fromARGB(240, 255, 253, 253),
          body: Container(
            width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
            child: _getInputPart,
          ),
        ));
  }

  // Returns "OtpForgotPassword custom text field"
  Widget _autoFillTextField() {
    return PinFieldAutoFill(
      autoFocus: true,
      codeLength: 6,
      decoration: UnderlineDecoration(
        bgColorBuilder:
            PinListenColorBuilder(Colors.green.shade200, Colors.grey.shade200),
        textStyle: const TextStyle(
            fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
        colorBuilder: const FixedColorBuilder(Colors.transparent),
      ),
      currentCode: _currentDigit ?? "",
      onCodeSubmitted: (otp) {},
      onCodeChanged: (otp) async {
        if (otp!.length == 6) {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _currentDigit = otp;
          });
          UserRepository.confirmForgotPassword(
                  countryCode: widget.countryCode,
                  phoneNumber: widget.phoneNumber,
                  otp: otp)
              .then((value) {
            if (value != null) {
              Navigator.pushReplacementNamed(context, Routes.changePassword,
                  arguments: {
                    "token": value,
                    "countryCode": widget.countryCode,
                    "phoneNumber": widget.phoneNumber
                  });
            } else {
              Timer(const Duration(milliseconds: 500), () {
                _currentDigit = null;
                setState(() {});
              });
            }
          });
        } else if (otp.isNotEmpty) {
          setState(() {
            _currentDigit = otp;
          });
        }
      },
    );
  }

  Future<void> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 2.0 : _controller.value);
  }
}

class OtpForgotPasswordTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpForgotPasswordTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration? get duration {
    Duration? duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Text(
            timerString,
            style: TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
