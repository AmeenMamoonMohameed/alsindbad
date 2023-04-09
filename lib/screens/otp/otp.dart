import 'dart:async';
import 'package:flutter/material.dart';
import 'package:akarak/utils/utils.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../configs/image.dart';
import '../../configs/routes.dart';
import '../../repository/user_repository.dart';

class Otp extends StatefulWidget {
  final String userId;
  final String? routeName;

  const Otp({Key? key, required this.userId, this.routeName}) : super(key: key);

  @override
  _OtpState createState() {
    return _OtpState();
  }
}

class _OtpState extends State<Otp> with TickerProviderStateMixin {
  // Constants
  late int time = 60;
  late AnimationController _controller;

  // Variables
  late Size _screenSize;
  late int? _currentDigit;
  late int? _firstDigit;
  late int? _secondDigit;
  late int? _thirdDigit;
  late int? _fourthDigit;
  late int? _fifthDigit;
  late int? _sixthDigit;

  late Timer timer;
  late int totalTimeInSeconds;
  late bool _hideResendButton = false;
  late bool _isFirst = true;

  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  _OtpState() {
    _currentDigit = null;
    _firstDigit = null;
    _secondDigit = null;
    _thirdDigit = null;
    _fourthDigit = null;
    _fifthDigit = null;
    _sixthDigit = null;
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
      Translate.of(context).translate("confirm_phone_number"),
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 28.0,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold),
    );
  }

  // Return "Otp" label
  get _getOtpLabel {
    return Text(
      _isFirst
          ? Translate.of(context)
              .translate("confirm_your_phone_number_with_the_verification_code")
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
            var secondsForAllowResendOtp =
                await UserRepository.sendVerificationPhoneNumber(
                    userId: widget.userId, confirmType: "sms");
            if (secondsForAllowResendOtp != null) {
              time = (secondsForAllowResendOtp).toInt();
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
            var secondsForAllowResendOtp =
                await UserRepository.sendVerificationPhoneNumber(
                    userId: widget.userId, confirmType: "whatsapp");
            if (secondsForAllowResendOtp != null) {
              time = (secondsForAllowResendOtp).toInt();
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
            var secondsForAllowResendOtp =
                await UserRepository.sendVerificationPhoneNumber(
                    userId: widget.userId, confirmType: "call");
            if (secondsForAllowResendOtp != null) {
              time = (secondsForAllowResendOtp).toInt();
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
            OtpTimer(_controller, 15.0, Theme.of(context).primaryColor)
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
        _getOtpLabel,
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
        // _getOtpKeyboard
      ],
    ));
  }

  // Return "OTP" input field
  get _getInputField {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16, right: 8, left: 8),
        child: _autoFillTextField(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   textDirection: TextDirection.ltr,
        //   children: <Widget>[
        //     _otpTextField(_firstDigit),
        //     _otpTextField(_secondDigit),
        //     _otpTextField(_thirdDigit),
        //     // const SizedBox(width: 8),
        //     _otpTextField(_fourthDigit),
        //     _otpTextField(_fifthDigit),
        //     _otpTextField(_sixthDigit),
        //   ],
        // ),
      ),
    );
  }

// Returns "Otp" keyboard
  get _getOtpKeyboard {
    return Container(
        height: _screenSize.width - 80,
        child: Column(
          children: <Widget>[
            const Divider(height: 5),
            Expanded(
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            const Divider(height: 5),
            Expanded(
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            const Divider(height: 5),
            Expanded(
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            const Divider(height: 5),
            Expanded(
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardActionButton(
                      label: Icon(
                        Icons.backspace,
                        textDirection: TextDirection.ltr,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixthDigit != null) {
                            _sixthDigit = null;
                          } else if (_fifthDigit != null) {
                            _fifthDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  const VerticalDivider(width: 5),
                  _otpKeyboardActionButton(
                      label: Icon(
                        Icons.clear_all_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          clearOtp();
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  // Returns "Otp custom text field"
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
      currentCode: _currentDigit?.toString() ?? "",
      onCodeSubmitted: (otp) {},
      onCodeChanged: (code) async {
        if (code!.length == 6) {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _currentDigit = int.tryParse(code);
          });
          var isConfirmed = await UserRepository.confirmPhoneNumber(
              userId: widget.userId, otp: code);
          if (isConfirmed) {
            if (widget.routeName == null || widget.routeName!.isEmpty) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, widget.routeName!,
                  arguments: Routes.account);
            }
          } else {
            Timer(const Duration(milliseconds: 500), () {
              _currentDigit = null;
              setState(() {});
            });
          }
        }
      },
    );
    // return PinFieldAutoFill(
    //   autoFocus: true,
    //   codeLength: 6,
    //   decoration: UnderlineDecoration(
    //     lineHeight: 2,
    //     lineStrokeCap: StrokeCap.square,
    //     bgColorBuilder:
    //         PinListenColorBuilder(Colors.green.shade200, Colors.grey.shade200),
    //     colorBuilder: const FixedColorBuilder(Colors.transparent),
    //   ),
    // );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int? digit) {
    return Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: Text(
        digit != null ? digit.toString() : "",
        style: TextStyle(
          fontSize: 30.0,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: Theme.of(context).colorScheme.secondary,
      ))),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton(
      {required String label, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          height: 80.0,
          width: 80.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton(
      {required Widget label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 80.0,
        width: 80.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  Future<void> _setCurrentDigit(int i) async {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fifthDigit == null) {
        _fifthDigit = _currentDigit;
      } else if (_sixthDigit == null) {
        _sixthDigit = _currentDigit;
      }
    });
    if (_sixthDigit != null) {
      var otp = _firstDigit.toString() +
          _secondDigit.toString() +
          _thirdDigit.toString() +
          _fourthDigit.toString() +
          _fifthDigit.toString() +
          _sixthDigit.toString();
      // Verify your otp by here. API call
      // var userId = await UserRepository.loadRegUserId();
      var isConfirmed = await UserRepository.confirmPhoneNumber(
          userId: widget.userId, otp: otp);
      if (isConfirmed) {
        if (widget.routeName == null || widget.routeName!.isEmpty) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, widget.routeName!,
              arguments: Routes.account);
        }
      } else {
        Timer(const Duration(milliseconds: 500), () {
          clearOtp();
        });
      }
    }
  }

  Future<void> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 2.0 : _controller.value);
  }

  void clearOtp() {
    _sixthDigit = null;
    _fifthDigit = null;
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

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
