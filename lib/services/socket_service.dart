import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;

  IO.Socket? _socket;

  //static const String _url = 'http://www.nu-mnl-nuqx.it.com:3001';
  static const String _url = 'http://10.0.2.2:3001'; // your PC's LAN IP
// HTTP for testing
  static const String _path = '/socket.io/';

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
      ..onConnect((_) => print('✅ Socket connected to $_url$_path'))
      ..onConnectError((e) => print('❌ Connect error: $e'))
      ..onError((e) => print('❌ Socket error: $e'))
      ..onDisconnect((_) => print('📡 Socket disconnected'))
      ..on('transactions-updated', (data) => print('🆕 transactions-updated: $data'))
      ..on('queueChanged', (data) => print('🆕 queueChanged: $data'));

    _socket!.connect();
  }

  void joinDepartment(String department) {
    connect();
    _socket?.emit('join-department', department);
    print('📡 joined room: $department');
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
    _socket?.dispose();
    _socket = null;
  }
}
