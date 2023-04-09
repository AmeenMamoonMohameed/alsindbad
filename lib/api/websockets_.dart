import 'dart:async';
import 'package:akarak/blocs/app_bloc.dart';
import 'package:akarak/configs/application.dart';
import 'package:akarak/models/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'json.dart';

class Websocket {
  late WebSocket channel;
  late String serverHostname;
  late String serverPort;

  Websocket();

  Future<void> connectToServer() async {
    // try {
    //   final socket = await Socket.connect('akarak-001-site5.gtempurl.com', 80);
    //   print('Connected to server');

    //   socket.write('Hello, server!');

    //   socket.listen(
    //     (data) {
    //       print('Received data: ${String.fromCharCodes(data)}');
    //     },
    //     onDone: () {
    //       print('Disconnected from server');
    //       socket.destroy();
    //     },
    //   );
    // } catch (e) {
    //   print('Error: $e');
    // }
    // channel = IOWebSocketChannel.connect(
    //   Uri.parse(r'ws://199.102.48.30:80/socket'),
    //   // Uri.parse('ws://10.0.2.2:5000/socket'),
    //   headers: {
    //     'Origin': 'ws://199.102.48.30',
    //     // 'Origin': 'ws://10.0.2.2:5000',
    //     'Authorization': 'bearer ${AppBloc.userCubit.state?.token}'
    //   },
    // );
    channel = await WebSocket.connect(
      'ws://199.102.48.30/socket',
      // 'ws://10.0.2.2:5000/socket',
      headers: {
        'Origin': 'ws://199.102.48.30',
        // 'Origin': 'ws://10.0.2.2:5000',
        'Authorization': 'bearer ${AppBloc.userCubit.state?.token}'
      },
    );
    print('connect to server');
  }

  void disconnectFromServer() {
    channel.close(status.goingAway);
    print('disconnect to server');
  }

  void listenForMessages(void Function(dynamic message) onMessageReceived) {
    // channel.listen(
    //   onMessageReceived,
    //   onDone: () {
    //     // channel = IOWebSocketChannel.connect(
    //     //   // Uri.parse('ws://199.102.48.30:443/socket'),
    //     //   Uri.parse('ws://199.102.48.30:443/socket'),
    //     //   headers: {
    //     //     'Origin': 'ws://199.102.48.30',
    //     //     'Authorization': 'bearer ${AppBloc.userCubit.state?.token}'
    //     //   },
    //     // );

    //     debugPrint('ws channel closed');
    //   },
    //   onError: (error) {
    //     debugPrint('ws error $error');
    //   },
    // );
    print('now listening for messages');
  }

  void sendMessage(String message) {
    print('sending a message: $message');
    channel.add(message);
    // channel.sink.add(Json.encodeMessageJSON(message));
  }
}
