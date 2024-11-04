import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReplyList extends StatelessWidget {
  final String postId;

  const ReplyList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final replies = snapshot.data!.docs;
        return ListView.builder(
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            final data = reply.data() as Map<String, dynamic>;
            final content = data['content'] ?? '';
            final author = data['author'] ?? '@返信さん';
            final timestamp = data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate()
                : null;
            final likes = data['likes'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(left: 54.0, top: 8.0), // インデント調整
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // アイコンとテキストを上揃え
                children: [
                  Align(
                    alignment: Alignment.topCenter, // アイコンを上に揃える
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // 名前とタイムスタンプを上揃え
                          children: [
                            Text(
                              author,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(timestamp),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(content, style: const TextStyle(fontSize: 12)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up_outlined, size: 14),
                              onPressed: () {
                                // いいね処理を追加
                              },
                            ),
                            Text(likes.toString(), style: const TextStyle(fontSize: 12)),
                            IconButton(
                              icon: const Icon(Icons.thumb_down_outlined, size: 14),
                              onPressed: () {
                                // バッド処理を追加
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 7) {
      return DateFormat('yyyy/MM/dd').format(timestamp);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}日前';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}