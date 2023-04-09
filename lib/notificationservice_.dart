// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:workmanager/workmanager.dart';
// // import 'package:workmanager/workmanager.dart';

// import 'blocs/app_bloc.dart';
// import 'configs/image.dart';
// import 'models/model.dart';

// class NotificationService {
//   static final NotificationService _notificationService =
//       NotificationService._internal();

//   factory NotificationService() {
//     return _notificationService;
//   }

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._internal();
//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');

//     DarwinInitializationSettings initializationSettingsIOS =
//         const DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );

//     InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     // Workmanager().executeTask((task, inputData) async {
//     //   var listNotifications = await AppBloc.initCubit.onLoadNotifications();
//     //   for (var item in listNotifications) {
//     //     showNotification(notification: item);
//     //   }
//     //   return Future.value(true);
//     // });
//   }

//   Future<void> Scheduleotification_(
//       {required NotificationModel notification}) async {
//     await flutterLocalNotificationsPlugin.periodicallyShow(
//       notification.id,
//       notification.title,
//       notification.description,
//       RepeatInterval.everyMinute,
//       const NotificationDetails(
//         android: AndroidNotificationDetails('main_channel', 'Main Channel',
//             channelDescription: 'Main channel notifications',
//             importance: Importance.max,
//             priority: Priority.max,
//             icon: '@mipmap/ic_launcher'),
//         iOS: DarwinNotificationDetails(
//           sound: 'default.wav',
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//     );
//   }

//   Future<void> showNotification(
//       {required NotificationModel notification}) async {
//     ////// هنا  الغاء الباراميترات وجلب البيانات من الاي يب اي
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       notification.id,
//       notification.title,
//       notification.description,
//       tz.TZDateTime.now(tz.local)
//           .add(Duration(seconds: notification.temporarilyUntil?.second ?? 0)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails('main_channel', 'Main Channel',
//             channelDescription: 'Main channel notifications',
//             importance: Importance.max,
//             priority: Priority.max,
//             icon: '@mipmap/ic_launcher'),
//         iOS: DarwinNotificationDetails(
//           sound: 'default.wav',
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true,
//     );
//   }

//   Future<void> cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
// }
