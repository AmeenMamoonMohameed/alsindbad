// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:timezone/timezone.dart' as tz;

// import 'blocs/app_bloc.dart';
// import 'configs/image.dart';
// import 'models/model.dart';

// class NotificationService {
//   static final NotificationService _notificationService =
//       NotificationService._internal();

//   NotificationService._internal();

//   factory NotificationService() {
//     return _notificationService;
//   }

//   Future<void> initNotification() async {
//     await AwesomeNotifications().initialize(
//         // set the icon to null if you want to use the default app icon
//         'resource://drawable/res_app_icon',
//         [
//           NotificationChannel(
//               channelGroupKey: 'basic_channel_group',
//               channelKey: 'basic_channel',
//               channelName: 'Basic notifications',
//               channelDescription: 'Notification channel for basic tests',
//               defaultColor: const Color(0xFF9D50DD),
//               ledColor: Colors.white)
//         ],
//         // Channel groups are only visual and are not required
//         channelGroups: [
//           NotificationChannelGroup(
//               channelGroupKey: 'basic_channel_group',
//               channelGroupName: 'Basic group')
//         ],
//         debug: true);
//   }

//   Future<void> showNotification({required notification}) async {
//     ////// هنا  الغاء الباراميترات وجلب البيانات من الاي يب اي
//     AwesomeNotifications().createNotification(
//         content: NotificationContent(
//       id: 10,
//       channelKey: 'basic_channel',
//       title: 'Simple Notification',
//       body: 'Simple body',
//       // actionType: ActionType.Default,
//     ));
//   }
// }
