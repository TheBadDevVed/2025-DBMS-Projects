import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String? ownerId;
  final String? carId;
  const ChatScreen({super.key, this.ownerId, this.carId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  String? get _threadId {
    if (_currentUserId == null || widget.ownerId == null) return null;
    final a = _currentUserId!;
    final b = widget.ownerId!;
    final low = a.compareTo(b) <= 0 ? a : b;
    final high = a.compareTo(b) <= 0 ? b : a;
    // Thread key includes car if available to scope per car
    return widget.carId != null && widget.carId!.isNotEmpty
        ? 'car_${widget.carId!}_${low}_$high'
        : 'users_${low}_$high';
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    final uid = _currentUserId;
    final ownerId = widget.ownerId;
    final carId = widget.carId;
    final threadId = _threadId;
    if (uid == null || ownerId == null || threadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start chat. Please sign in.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final db = FirebaseFirestore.instance;
      final threadRef = db.collection('chats').doc(threadId);
      final otherId = ownerId;
      await threadRef.set({
        'participantA': uid,
        'participantB': otherId,
        'participants': [uid, otherId],
        if (carId != null) 'carId': carId,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastSenderId': uid,
        'unread_$uid': 0,
        'unread_$otherId': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await threadRef.collection('messages').add({
        'senderId': uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _textController.clear();
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _markRead() async {
    final uid = _currentUserId;
    final threadId = _threadId;
    if (uid == null || threadId == null) return;
    try {
      await FirebaseFirestore.instance.collection('chats').doc(threadId).set({
        'unread_$uid': 0,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.ownerId != null && widget.carId != null)
        ? 'Chat with Owner'
        : 'Chat';
    final uid = _currentUserId;
    final threadId = _threadId;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          if (uid == null || widget.ownerId == null)
            Expanded(
              child: Center(
                child: Text(
                  'Select a car/owner to start chatting.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(threadId)
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .limit(200)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Mark read whenever we get new data
                  _markRead();
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hi!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.separated(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final d = docs[index].data();
                      final isMine = d['senderId'] == uid;
                      final text = (d['text'] ?? '') as String;
                      final ts = d['createdAt'] as Timestamp?;
                      final time = ts == null
                          ? ''
                          : TimeOfDay.fromDateTime(ts.toDate()).format(context);
                      return Row(
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isMine
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(text),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _sendMessage,
                    child: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline),
                  SizedBox(height: 2),
                  Text('Chat', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
