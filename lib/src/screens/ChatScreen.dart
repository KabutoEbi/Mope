import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
	final String conversationId;
	final String displayName;

	const ChatScreen({super.key, required this.conversationId, required this.displayName});

	// Dummy messages
	List<Map<String, dynamic>> get _messages => const [
				{'fromMe': false, 'text': 'Hey — are you there?', 'time': '09:00'},
				{'fromMe': true, 'text': 'Yes, I am. Running late.', 'time': '09:02'},
				{'fromMe': false, 'text': 'No problem.', 'time': '09:05'},
			];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(displayName),
				backgroundColor: const Color(0xFF161B26),
			),
			body: Column(
				children: [
					Expanded(
						child: ListView.builder(
							padding: const EdgeInsets.all(12),
							itemCount: _messages.length,
							itemBuilder: (context, index) {
								final msg = _messages[index];
								final alignment = msg['fromMe'] ? CrossAxisAlignment.end : CrossAxisAlignment.start;
								final bgColor = msg['fromMe'] ? const Color(0xFF38BDF8) : const Color(0xFF1F2937);
								final textColor = msg['fromMe'] ? Colors.black : Colors.white;
								return Column(
									crossAxisAlignment: alignment,
									children: [
										Container(
											margin: const EdgeInsets.symmetric(vertical: 6),
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
											decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
											child: Text(msg['text'], style: TextStyle(color: textColor)),
										),
										Text(msg['time'], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
									],
								);
							},
						),
					),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
						decoration: const BoxDecoration(color: Color(0xFF0B0F19)),
						child: Row(
							children: [
								Expanded(
									child: TextField(
										enabled: false,
										decoration: InputDecoration(
											hintText: 'Compose (disabled)',
											hintStyle: const TextStyle(color: Color(0xFF64748B)),
											filled: true,
											fillColor: const Color(0xFF1B2430),
											border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
										),
									),
								),
								const SizedBox(width: 8),
								ElevatedButton(
									onPressed: null,
									style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
									child: const Icon(Icons.send),
								)
							],
						),
					)
				],
			),
		);
	}
}
