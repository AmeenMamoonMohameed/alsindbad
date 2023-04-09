// import 'dart:io';

// import 'package:dart_eval/dart_eval.dart';
// import 'package:dart_eval/stdlib/core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_eval/flutter_eval.dart';
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(const EvalExample());
// }

// class EvalExample extends StatelessWidget {
//   const EvalExample({Key? key}) : super(key: key);

//   @override
//   initState() {}

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();

//     return directory.path;
//   }

//   Directory findRoot(FileSystemEntity entity) {
//     final Directory parent = entity.parent;
//     if (parent.path == entity.path) return parent;
//     return findRoot(parent);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return RuntimeWidget(
//     //     uri: Uri.parse('asset:assets/program.evc'),
//     //     library: 'package:akarak/main.dart',
//     //     function: 'MyApp',
//     //     args: [$String('Jessica'), null, null]);

//     // final compiler = Compiler();
//     // _localPath.then((value) {
//     //   final program = compiler.compile({
//     //     'akarak': {
//     //       'main.dart': '''
//     //   int main() {
//     //     var count = 0;
//     //     for (var i = 0; i < 1000; i = i + 1) {
//     //       count = count + i;
//     //     }
//     //     return count;
//     //   }
//     // '''
//     //     }
//     //   });
//     //   final bytecode = program.write();
//     //   // final file =
//     //   //     File('E:\\akkar\\1.7\\akarakApp\\source\\assets\\program.evc');

//     //   final file = File('assets/program.evc');
//     //   final ds = bytecode.toString();
//     //   file.writeAsBytesSync(bytecode);
//     // });

//     return const EvalWidget(
//       packages: {
//         'akarak': {
//           'main.dart': '''
//               import 'package:flutter/material.dart';
//               import 'package:akarak/api/api.dart';

//               class MyApp extends StatelessWidget {
//                 const MyApp({super.key});

//                 // This widget is the root of your application.
//                 @override
//                 Widget build(BuildContext context) {
//                   return MaterialApp(
//                     debugShowCheckedModeBanner:false,
//                     title: 'flutter_eval demo',
//                     home: const MyHomePage(title: 'flutter_eval demo home page'),
//                   );
//                 }
//               }

//               class MyHomePage extends StatefulWidget {
//                 const MyHomePage({Key? key, required this.title}) : super(key: key);

//                 final String title;

//                 @override
//                 State<MyHomePage> createState() => _MyHomePageState();
//               }

//               class _MyHomePageState extends State<MyHomePage> {
//                 _MyHomePageState();
//                 int _counter = 0;

//                 void _incrementCounter() {
//                   setState(() {
//                     _counter++;
//                   });
//                 }

//                 @override
//                 Widget build(BuildContext context) {
//                   return Scaffold(
//                     appBar: AppBar(
//                       title: Text(widget.title),
//                     ),
//                     body: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           const Text(
//                             'You have pushed the button this many times:',
//                           ),
//                           Text(
//                             '\$_counter',
//                             style: Theme.of(context).textTheme.headline4,
//                           ),
//                         ],
//                       )
//                     ),
//                     floatingActionButton: FloatingActionButton(
//                       onPressed: _incrementCounter,
//                       tooltip: 'Increment',
//                       child: Icon(Icons.add),
//                     ),
//                   );
//                 }
//               }

//             '''
//         }
//       },

//       /// In debug mode, flutter_eval will continually re-generate a compiled
//       /// EVC bytecode file for the given program, and save it to the specified
//       /// assetPath. During runtime, it will instead load the compiled EVC file.
//       /// To ensure this works, you must add the file path to the assets section of
//       /// your pubspec.yaml file.
//       assetPath: 'assets/program.evc',

//       /// Specify which library (i.e. which file) to use as an entrypoint.
//       library: 'package:akarak/main.dart',

//       /// Specify which function to call as the entrypoint.
//       /// To use a constructor, use "ClassName.constructorName" syntax. In
//       /// this case we are calling a default constructor so the constructor
//       /// name is blank.
//       function: 'MyApp.',

//       /// Specify the arguments to pass to the entrypoint. Generally these
//       /// should be dart_eval [$Value] objects, but when invoking a static or
//       /// top-level function or constructor, [int]s, [double]s, and [bool]s
//       /// should be passed directly.
//       args: [null],
//     );
//   }
// }
