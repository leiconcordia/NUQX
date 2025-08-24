// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;

  IO.Socket? _socket;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'https://www.nu-mnl-nuqx.it.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/server/socket.io/')
          .enableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) => print('✅ CONNECTED'))
      ..onConnectError((e) => print('❌ Connect error: $e'))
      ..onError((e) => print('❌ Socket error: $e'))
      ..onDisconnect((_) => print('📡 DISCONNECTED'));
  }

  void joinDepartment(String dept) {
    connect(); // make sure it’s open
    _socket!.emit('join-department', dept);
    print('📡 JOINED room $dept');
  }

  void emit(String event, Map data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) fn) => _socket?.on(event, fn);
  void off(String event) => _socket?.off(event);
}