import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Dummy data for UI — only name and unread count are relevant for the list
  List<Map<String, String>> get _conversations => const [
        {'id': '1', 'name': 'Alice', 'unread': '2'},
        {'id': '2', 'name': 'Bob', 'unread': '0'},
        {'id': '3', 'name': 'Charlie', 'unread': '5'},
      ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final convo = _conversations[index];
        final unread = convo['unread'] ?? '0';
        return ListTile(
          title: Text(convo['name']!, style: const TextStyle(color: Colors.white)),
          trailing: unread != '0'
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                  child: Text(unread, style: const TextStyle(color: Colors.white, fontSize: 12)),
                )
              : const SizedBox.shrink(),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(conversationId: convo['id']!, displayName: convo['name']!),
            ));
          },
        );
      },
    );
  }
}
