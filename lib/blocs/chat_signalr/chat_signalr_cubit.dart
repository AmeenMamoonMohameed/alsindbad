import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/io_client.dart';
import 'package:signalr_core/signalr_core.dart';
import '../../api/network_connectivity.dart';
import '../../configs/application.dart';
import '../../models/model_chat.dart';
import '../../repository/repository.dart';
import '../app_bloc.dart';
import '../bloc.dart';

class ChatSignalRCubit extends Cubit<ChatSignalRState> {
  static const url = 'http://akarak-001-site5.gtempurl.com/signalRHub';
  // static const url = 'http://10.0.2.2:5000/signalRHub';
  HubConnection? hubConnection;
  Future<void> Function(List? args)? _pingNotificationHandler;
  Future<void> Function(List? args)? _receiveMessageHandler;
  Future<void> Function(List? args)? _receiveReadStatusMessageHandler;
  Future<void> Function(List? args)? _receiveDeliveredStatusMessageHandler;
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  // String string = '';

  ChatSignalRCubit() : super(ChatSignalRState.reconnecting) {
    // checkConnectionProcess();
  }

  bool emitConnectivity() {
    bool isConnectivity = false;
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      print('source $_source');
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          // string =
          //     _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          isConnectivity = true;
          break;
        case ConnectivityResult.wifi:
          // string =
          //     _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          isConnectivity = true;

          break;
        case ConnectivityResult.none:
        default:
          // string = 'Offline';
          isConnectivity = false;
      }
      // setState(() {});
      if (!isConnectivity) {
        emit(ChatSignalRState.close);
      } else {
        emit(ChatSignalRState.reconnecting);
      }
    });
    return isConnectivity;
  }

  Future<void> startAsync({bool isFirst = false}) async {
    if (hubConnection == null) return;
    if (isFirst == true) {
      await hubConnection!.start();
    }
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        try {
          // timer.cancel();
          if (hubConnection != null) {
            if (!await AppBloc.applicationCubit.checkInternet()) {
              emit(ChatSignalRState.close);
            } else if (hubConnection?.state == HubConnectionState.connected &&
                state != ChatSignalRState.reconnected) {
              emit(ChatSignalRState.reconnected);
            } else {
              if ((hubConnection?.state == HubConnectionState.reconnecting ||
                  hubConnection?.state == HubConnectionState.disconnecting)) {
                // await hubConnection!.stop();
                await build();
              }
              if (hubConnection?.state != HubConnectionState.connected &&
                  hubConnection?.state != HubConnectionState.connecting &&
                  hubConnection?.state != HubConnectionState.reconnecting &&
                  hubConnection?.state != HubConnectionState.disconnecting) {
                await hubConnection!.start();
              }
            }
          }
        } catch (exception) {
          emit(ChatSignalRState.close);
        }
      },
    );
  }

  Future<void> build(
      {Future<void> Function(List? args)? receiveNotificationFunc,
      Future<void> Function(List? args)? receiveMessageFunc,
      Future<void> Function(List? args)? receiveReadStatusMessageFunc,
      Future<void> Function(List? args)?
          receiveDeliveredStatusMessageFunc}) async {
    _pingNotificationHandler =
        receiveNotificationFunc ?? _pingNotificationHandler;
    _receiveMessageHandler = receiveMessageFunc ?? _receiveMessageHandler;
    _receiveReadStatusMessageHandler =
        receiveReadStatusMessageFunc ?? _receiveReadStatusMessageHandler;
    _receiveDeliveredStatusMessageHandler = receiveDeliveredStatusMessageFunc ??
        _receiveDeliveredStatusMessageHandler;

    if (AppBloc.userCubit.state == null) return;
    if (hubConnection != null && receiveMessageFunc != null) {
      await startAsync();
      return;
    }
    hubConnection = HubConnectionBuilder()
        .withUrl(
      url,
      HttpConnectionOptions(
          client: IOClient(
              HttpClient()..badCertificateCallback = (x, y, z) => true),
          logging: (level, message) async {
            if (message.contains('HubConnection connected successfully')) {
            } else if (message
                    .contains('HttpConnection connected successfully') &&
                state != ChatSignalRState.reconnected) {
              emit(ChatSignalRState.reconnected);
            } else if (message.contains('Starting HubConnection') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'ignored because the connection is already in the disconnecting state.') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'ignored because the connection is already in the disconnecting state.') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'Connection stopped during reconnect delay. Done reconnecting') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message
                    .contains('An onreconnecting callback called with error') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'Connection left the reconnecting state in onreconnecting callback. Done reconnecting') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains('Stopping HubConnection') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'Exception: Server timeout elapsed without receiving a message from the server') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains(
                    'Exception: Cannot send until the transport is connected') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains('Stopping polling') &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            } else if (message.contains('Connection disconnected')) {
              emit(ChatSignalRState.reconnecting);
              // await startAsync();
            }
            // else if (message.contains('HttpConnection.stopConnection(null) ') &&
            //     state != ChatSignalRState.reconnecting) {
            //   emit(ChatSignalRState.reconnecting);
            // }
            else if (level == LogLevel.error &&
                state != ChatSignalRState.reconnecting) {
              emit(ChatSignalRState.reconnecting);
            }
            // debugPrint("");
            print(message);
          },
          accessTokenFactory: () async {
            return "${AppBloc.userCubit.state?.token}";
          },
          // skipNegotiation: true,

          transport: HttpTransportType.longPolling),
      // transport: HttpTransportType.longPolling),
    )
        .withAutomaticReconnect([0, 3000])
        // .withAutomaticReconnect([0, 3000, 5000, 10000, 15000, 30000])
        // .withHubProtocol(JsonHubProtocol())
        .build();
    ////
    if (hubConnection == null) return;
    hubConnection!.on('ReceiveNotification',
        _pingNotificationHandler ?? _pingNotificationHandler!);
    hubConnection!
        .on('ReceiveMessage', receiveMessageFunc ?? _receiveMessageHandler!);
    hubConnection!.on('ReceiveReadStatusMessage',
        receiveReadStatusMessageFunc ?? _receiveReadStatusMessageHandler!);
    hubConnection!.on(
        'ReceiveDeliveredStatusMessage',
        receiveDeliveredStatusMessageFunc ??
            _receiveDeliveredStatusMessageHandler!);
    // hubConnection!.serverTimeoutInMilliseconds = 60000;
    hubConnection!.serverTimeoutInMilliseconds = 30000;
    hubConnection!.keepAliveIntervalInMilliseconds = 15000;
    hubConnection!.onreconnecting((exception) {
      emit(ChatSignalRState.reconnecting);
    });
    hubConnection!.onreconnected((exception) async {
      emit(ChatSignalRState.reconnected);
    });
    hubConnection!.onclose((exception) async {
      // debugPrint(exception);
      emit(ChatSignalRState.close);
    });
    if (!Application.isStartedSignalR) {
      await startAsync(isFirst: true);
      Application.isStartedSignalR = true;
    }
  }

  Future<void> sendMessage(String sender, int chatId, String receiver,
      int msgId, String remoteId, String userName, String message) async {
    if (hubConnection == null) return;

    if (hubConnection!.state == HubConnectionState.disconnected) {
      await hubConnection!.start();
    }

    var newMsg = ChatModel(
        id: msgId,
        chatId: chatId,
        remoteId: remoteId,
        fromUserId: sender,
        contactId: receiver,
        message: message,
        createdDate: null);
    await hubConnection!
        .invoke('SendMessageAsync', args: [newMsg.toJson(), userName]);
    // await hubConnection!.invoke('SendMessage', args: [userName, message]);
  }

  Future<void> notifySendDeliveredStatusForAll(List<String> users) async {
    if (hubConnection == null) return;
    if (hubConnection!.state == HubConnectionState.disconnected) {
      //await startAsync();
      await hubConnection!.start();
    }

    await hubConnection!
        .invoke('SendDeliveredStatusForUsersAsync', args: [users]);
  }

  Future<void> notifySendReadStatus(String fromUserId) async {
    if (hubConnection == null) return;
    if (hubConnection!.state == HubConnectionState.disconnected) {
      await hubConnection!.start();
    }

    await hubConnection!.invoke('SendReadStatusAsync', args: [fromUserId]);
  }

  Future<void> notifySendDeliveredStatus(String fromUserId) async {
    if (hubConnection == null) return;
    if (hubConnection!.state == HubConnectionState.disconnected) {
      await hubConnection!.start();
    }

    await hubConnection!.invoke('SendDeliveredStatusAsync', args: [fromUserId]);
  }

  Future<void> notifyReceiptDeliveredStatus() async {
    if (hubConnection == null) return;
    if (hubConnection!.state == HubConnectionState.disconnected) {
      await hubConnection!.start();
    }

    await hubConnection!
        .invoke('ReceiptStatusAsync', args: ["SendDeliveredStatus"]);
  }

  Future<void> notifyReceiptReadStatus() async {
    if (hubConnection == null) return;
    if (hubConnection!.state == HubConnectionState.disconnected) {
      await hubConnection!.start();
    }

    await hubConnection!.invoke('ReceiptStatusAsync', args: ["SendReadStatus"]);
  }

  void dispose() {
    if (hubConnection == null) return;
    hubConnection!.off('ReceiveReadStatusMessage');
    hubConnection!.off('ReceiveDeliveredStatusMessage');
    hubConnection!.stop();
    hubConnection = null;
  }
}
