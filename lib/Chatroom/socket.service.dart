import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  Socket? _socket;

  void initializeSocket(String serverUrl) {
    _socket = io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();
  }

  void dispose() {
    _socket?.disconnect();
  }

  void sendMessage(String message) {
    if (_socket != null) {
      _socket!.emit('message', message);
    }
  }

  void listenForMessages(Function(String) callback) {
    if (_socket != null) {
      _socket!.on('message', (data) {
        callback(data);
      });
    }
  }
}
