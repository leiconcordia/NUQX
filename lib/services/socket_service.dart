import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'notification_service.dart';

class SocketService {
  SocketService._();
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;

  IO.Socket? _socket;

  static const String _url = 'https://www.nu-mnl-nuqx.it.com';
  static const String _path = '/server/socket.io';


  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(_path)
          .enableForceNew()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        print('✅ Socket connected to $_url$_path');
      })
      ..onConnectError((e) => print('❌ Connect error: $e'))
      ..onError((e) => print('❌ Socket error: $e'))
      ..onDisconnect((_) => print('📡 Socket disconnected'))
      ..on('transactions-updated', (data) => print('🆕 transactions-updated: $data'))
      ..on('queueChanged', (data) => print('🆕 queueChanged: $data'))
      ..on('notification', (data) =>  print('📩 Notification received via WebSocket: $data'));


      // // Call your local notification function
      // NotificationService.showLocalNotification(
      // data['title'] ?? "Notification",
      // data['message'] ?? "",
      // );
      // });

    _socket!.connect();
  }

  void joinDepartment(String department) {
    connect();
    _socket?.once('connect', (_) {
      _socket?.emit('join-department', department);
      print('📡 joined room: $department');
    });
  }


  void joinUser(String email) {
    connect();
    if (_socket?.connected == true) {
      _socket?.emit('join-user', email);
      print('📡 Joined user room: $email');
    } else {
      _socket?.once('connect', (_) {
        _socket?.emit('join-user', email);
        print('📡 Joined user room after connect: $email');
      });
    }
  }


  void emitWhenConnected(String event, dynamic data) {
    connect();

    if (_socket?.connected == true) {
      // Already connected, emit immediately
      _socket?.emit(event, data);
      print('📤 emit $event -> $data');
    } else {
      // Wait until first connection
      _socket?.once('connect', (_) {
        _socket?.emit(event, data);
        print('📤 emit $event after connect -> $data');
      });
    }
  }



  void emit(String event, Map<String, dynamic> data) {
    if (!(_socket?.connected ?? false)) {
      print('⚠️ emit skipped, socket not connected');
      return;
    }
    _socket!.emit(event, data);
    print('📤 emit $event -> $data');
  }

  void on(String event, Function(dynamic) handler) => _socket?.on(event, handler);


  void off(String event) => _socket?.off(event);

  void disconnect() {
    _socket?.disconnect();
    _socket?.close();
    _socket = null;
  }

}
