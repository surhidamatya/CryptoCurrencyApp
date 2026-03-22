import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static const String _baseUrl = 'wss://stream.binance.com:9443/stream';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> connect(List<String> symbols) {
    disconnect();

    final streams = symbols
        .map((s) => '${s.toLowerCase()}@trade')
        .join('/');
    final uri = Uri.parse('$_baseUrl?streams=$streams');

    _channel = WebSocketChannel.connect(uri);
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    _channel!.stream.listen(
      (message) {
        if (_controller?.isClosed == false) {
          final decoded = jsonDecode(message as String) as Map<String, dynamic>;
          _controller?.add(decoded);
        }
      },
      onError: (error) => _controller?.addError(error),
      onDone: () => _controller?.close(),
    );

    return _controller!.stream;
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
