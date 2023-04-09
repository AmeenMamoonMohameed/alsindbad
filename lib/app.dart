// import 'package:workmanager/workmanager.dart';

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_eval/flutter_eval.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

import 'notificationservice_.dart';
import 'widgets/widget.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:akarak/app_container.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/screens/screen.dart';
import 'package:akarak/utils/utils.dart';

import 'first_time.dart';
import 'repository/location_repository.dart';
import 'package:timezone/data/latest.dart' as tz;

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late Runtime runtime;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    // final compiler = Compiler();
    // compiler.addPlugin(flutterEvalPlugin);

    // final program = compiler.compile({
    //   'example': {
    //     'main.dart': '''
    //       import 'package:flutter/material.dart';

    //       class HomePage extends StatelessWidget {
    //         HomePage( this.number);
    //         final int number;

    //         @override
    //         Widget build(BuildContext context) {
    //           return Padding(
    //             padding: EdgeInsets.all(2.3 * 5),
    //             child: Container(
    //               color: Colors.green,
    //               child: Text('Current amount: ' + number.toString())
    //             )
    //           );
    //         }
    //       }
    //     '''
    //   }
    // });

    // final file = File('assets/program.evc');
    // file.writeAsBytesSync(program.write());
    // print('Wrote out.evc to: ' + file.absolute.uri.path);

    // runtime = Runtime.ofProgram(program);
    // runtime.addPlugin(flutterEvalPlugin);
    // runtime.setup();
  }

  @override
  void dispose() {
    AppBloc.dispose();
    super.dispose();
  }

  void onSetup(BuildContext context) async {
    await Preferences.setPreferences();
    if (LocationRepository.loadCountry() == null) {
      AppBloc.applicationCubit.onBeforeSetup();
    } else {
      AppBloc.applicationCubit.onSetup();
    }
  }

  void showFloatingFlushbar(
      {@required BuildContext? context,
      @required String? message,
      @required bool? isError}) {
    Flushbar? flush;
    flush = Flushbar<bool>(
      title: "Hey User",
      // message: message,
      messageText: Container(
        color: const Color(0xFF5EA4FF),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context!).size.height * 0.2,
          minHeight: 1,
        ),
        child: Expanded(
          flex: 1,
          child: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.vertical, //.horizontal
            child: Text(
              message ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
      backgroundColor: isError! ? Colors.red : Colors.blueAccent,
      // duration: const Duration(seconds: 3),
      duration: const Duration(hours: 1),
      margin: const EdgeInsets.all(20),
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      mainButton: TextButton(
        onPressed: () {
          flush!.dismiss(true); // result = true
        },
        child: const Text(
          "ADD",
          style: TextStyle(color: Colors.amber),
        ),
      ),
    ) // <bool> is the type of the result passed to dismiss() and collected by show().then((result){})
      ..show(context).then((result) {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   return (runtime.executeLib(
  //           'package:example/main.dart', 'HomePage.', [$int(55)]) as $Value)
  //       .$value;
  // }

  @override
  Widget build(BuildContext context) {
    onSetup(context);
    try {
      // if (AwesomeNotifications().isBroadcast) {
      // AwesomeNotifications().setListeners(
      //     onActionReceivedMethod: (receivedAction) async {
      //   // Navigator.of(context).pushNamed('/NotificationPage', arguments: {
      //   //   // your page params. I recommend you to pass the
      //   //   // entire *receivedNotification* object
      //   //   'id': receivedNotification.id
      //   // });
      // });
      // }
    } catch (exception) {}

    return MultiBlocProvider(
      providers: AppBloc.providers,
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, lang) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, theme) {
              return MaterialApp(
                navigatorKey: App.navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: theme.lightTheme,
                darkTheme: theme.darkTheme,
                onGenerateRoute: Routes.generateRoute,
                locale: lang,
                localizationsDelegates: const [
                  Translate.delegate,
                  CountryLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLanguage.supportLanguage,
                home: Scaffold(
                  drawer: Application.mainDrawer,
                  key: Application.scaffoldKey,
                  body: BlocListener<MessageCubit, String?>(
                    listener: (context, message) {
                      if (message != null) {
                        final snackBar = SnackBar(
                          content: Text(
                            Translate.of(context).translate(message),
                          ),
                        );
                        // showFloatingFlushbar(
                        //     context: context, message: message, isError: false);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: BlocBuilder<ApplicationCubit, ApplicationState>(
                      builder: (context, application) {
                        if (application == ApplicationState.completed) {
                          return const AppContainer();
                        }
                        // return const AppContainer();
                        if (application == ApplicationState.intro) {
                          return const Intro();
                        }
                        if (application == ApplicationState.firstTime) {
                          return const FirstTime();
                        }
                        return const SplashScreen();
                      },
                    ),
                  ),
                ),
                builder: (context, child) {
                  final data = MediaQuery.of(context).copyWith(
                    textScaleFactor: theme.textScaleFactor,
                  );
                  return MediaQuery(
                    data: data,
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
