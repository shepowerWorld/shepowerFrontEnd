import 'package:Shepower/Chatroom/socket.service.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();

    // Initialize the socket service
    final socketService = SocketService();
    socketService.initializeSocket(ApiConfig.socket);

    socketService.listenForMessages((data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  @override
  void dispose() {
    SocketService().dispose();
    super.dispose();
  }

  void sendMessage(String message) {
    SocketService().sendMessage(message);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
