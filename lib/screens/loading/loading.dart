import 'package:flutter/material.dart';
import 'package:akarak/configs/config.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<int, Color> color = {
    50: const Color.fromRGBO(4, 131, 184, .1),
    100: const Color.fromRGBO(4, 131, 184, .2),
    200: const Color.fromRGBO(4, 131, 184, .3),
    300: const Color.fromRGBO(4, 131, 184, .4),
    400: const Color.fromRGBO(4, 131, 184, .5),
    500: const Color.fromRGBO(4, 131, 184, .6),
    600: const Color.fromRGBO(4, 131, 184, .7),
    700: const Color.fromRGBO(4, 131, 184, .8),
    800: const Color.fromRGBO(4, 131, 184, .9),
    900: const Color.fromRGBO(4, 131, 184, 1),
  };

  @override
  Widget build(BuildContext context) {
    // MaterialColor myColor = MaterialColor(0xFF880E4F, color);

    return Scaffold(
      // backgroundColor: myColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff94ACCC),
                  Color(0xff2D5198),
                  Color(0xff2D5198),
                ],
                begin: Alignment(-0.7, 12),
                end: Alignment(1, -2),
              ),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(Images.logo, width: 200, height: 200),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 300),
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        ],
      ),
    );
  }
}
