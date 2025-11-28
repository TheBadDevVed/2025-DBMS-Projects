import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view messages.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: uid)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final d = docs[index].data();
              final participants = (d['participants'] as List<dynamic>? ?? []).cast<String>();
              final otherId = participants.firstWhere((p) => p != uid, orElse: () => 'Unknown');
              final carId = d['carId'] as String?;
              final lastMessage = (d['lastMessage'] ?? '') as String;
              final unreadForMe = (d['unread_$uid'] ?? 0) as int;
              return ListTile(
                leading: CircleAvatar(child: Text(otherId.isNotEmpty ? otherId[0].toUpperCase() : '?')),
                title: Text(otherId),
                subtitle: Text(lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: unreadForMe > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$unreadForMe', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(ownerId: otherId, carId: carId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: _BottomNav(current: 1),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current; // 0 home, 1 chat, 2 add, 3 mycars, 4 reviews
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.home), SizedBox(height: 2), Text('Home', style: TextStyle(fontSize: 10))]),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.chat_bubble_outline), SizedBox(height: 2), Text('Chat', style: TextStyle(fontSize: 10))]),
            ),
          ),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}


