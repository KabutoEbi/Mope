import 'package:flutter/material.dart';
import 'ConversationsScreen.dart';

class ChatScreen extends StatelessWidget {
	const ChatScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Mope'),
				backgroundColor: const Color(0xFF161B26),
				// logout button removed as requested
			),
			body: const ConversationsScreen(),
		);
	}
}
