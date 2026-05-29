import 'package:flutter/material.dart';
import 'ChatListScreen.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mope'),
        backgroundColor: const Color(0xFF161B26),
        // logout button removed as requested
      ),
      body: const ChatListScreen(),
    );
  }
}
