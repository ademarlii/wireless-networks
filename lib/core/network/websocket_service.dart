import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/secure_storage.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onSessionStarted;

  Future<void> connect() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    final uri = Uri.parse('${AppConstants.wsUrl}/ws?token=$token');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'SESSION_TOKEN' && onSessionStarted != null) {
            onSessionStarted!(data);
          }
        },
        onError: (error) {
          print('WebSocket Hatası: $error');
          _reconnect();
        },
        onDone: () {
          print('WebSocket Bağlantısı Koptu');
          _reconnect();
        },
      );
    } catch (e) {
      print('WebSocket Bağlantı Hatası: $e');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
