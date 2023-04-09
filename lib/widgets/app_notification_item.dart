import 'dart:convert';

import 'package:akarak/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/widgets/app_placeholder.dart';

class AppNotificationItem extends StatelessWidget {
  final NotificationModel? item;
  final NotificationType type;

  const AppNotificationItem({
    Key? key,
    this.item,
    this.type = NotificationType.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return AppPlaceholder(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          width: double.infinity,
          height: 100,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
        ),
      );
    }
    if (item!.type == NotificationType.message) {
      return InkWell(
        onTap: () {
          if (item!.url != null && item!.url!.isNotEmpty) {
            Navigator.of(context).pushNamed(item!.url!,
                arguments:
                    item!.arguments != null && item!.arguments!.isNotEmpty
                        ? jsonDecode(item!.arguments!)
                        : null);
          }
        },
        child:
            // Request amount
            Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: item!.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              text: TextSpan(
                                  style: Theme.of(context).textTheme.caption,
                                  children: [
                                    TextSpan(
                                        text: item!.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(
                  item!.timeElapsed,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
        ),
        //  AppPlaceholder(
        //   child: Container(
        //     padding: const EdgeInsets.all(16.0),
        //     margin: const EdgeInsets.symmetric(vertical: 4.0),
        //     width: double.infinity,
        //     height: 100,
        //     decoration: const BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
        //   ),
        // ),
      );
    }
    if (item!.type == NotificationType.customerOrder) {
      return InkWell(
        onTap: () {
          if (item!.url != null && item!.url!.isNotEmpty) {
            Navigator.of(context).pushNamed(item!.url!,
                arguments:
                    item!.arguments != null && item!.arguments!.isNotEmpty
                        ? jsonDecode(item!.arguments!)
                        : null);
          }
        },
        child:
            // Request amount
            Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: 'Sai Sankar Ram',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    TextSpan(
                                      text: ' Requested for ',
                                    ),
                                    TextSpan(
                                      text: '\$45.25',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item!.description.isNotEmpty)
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: RichText(
                                text: TextSpan(
                                    style: Theme.of(context).textTheme.caption,
                                    children: [
                                      TextSpan(
                                          text: item!.description,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Pay',
                                  style: TextStyle(color: Colors.blue[700])),
                            )
                          ],
                        ),
                        Row(
                          children: const <Widget>[
                            Icon(
                              Icons.cancel,
                              size: 14,
                              color: Color(0xffF94D4D),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Decline',
                                  style: TextStyle(color: Color(0xffF94D4D))),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(
                  item!.timeElapsed,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
        ),
        //  AppPlaceholder(
        //   child: Container(
        //     padding: const EdgeInsets.all(16.0),
        //     margin: const EdgeInsets.symmetric(vertical: 4.0),
        //     width: double.infinity,
        //     height: 100,
        //     decoration: const BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
        //   ),
        // ),
      );
    }
    if (item!.type == NotificationType.message) {
      return InkWell(
        onTap: () {
          if (item!.url != null && item!.url!.isNotEmpty) {
            Navigator.of(context).pushNamed(item!.url!,
                arguments:
                    item!.arguments != null && item!.arguments!.isNotEmpty
                        ? jsonDecode(item!.arguments!)
                        : null);
          }
        },
        child:
            // Request amount
            Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/background.jpg',
                    ),
                    maxRadius: 24,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Sai Sankar Ram',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                text: ' Requested for ',
                              ),
                              TextSpan(
                                text: '\$45.25',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ]),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.blue[700],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Pay',
                            style: TextStyle(color: Colors.blue[700])),
                      )
                    ],
                  ),
                  Row(
                    children: const <Widget>[
                      Icon(
                        Icons.cancel,
                        size: 14,
                        color: Color(0xffF94D4D),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Decline',
                            style: TextStyle(color: Color(0xffF94D4D))),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        //  AppPlaceholder(
        //   child: Container(
        //     padding: const EdgeInsets.all(16.0),
        //     margin: const EdgeInsets.symmetric(vertical: 4.0),
        //     width: double.infinity,
        //     height: 100,
        //     decoration: const BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
        //   ),
        // ),
      );
    }
    return Container();
  }
}
