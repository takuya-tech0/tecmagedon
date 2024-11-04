import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'reply_page.dart';

class PostItem extends StatefulWidget {
  final QueryDocumentSnapshot post;
  final bool showReplyCount;

  const PostItem({super.key, required this.post, this.showReplyCount = false});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isExpanded = false;

  Future<void> _updateLikes() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(postRef);
      final freshData = freshSnapshot.data() as Map<String, dynamic>;
      final currentLikes = freshData['likes'] ?? 0;
      transaction.update(postRef, {'likes': currentLikes + 1});
    });
  }

  Future<void> _updateDislikes() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(postRef);
      final freshData = freshSnapshot.data() as Map<String, dynamic>;
      final currentDislikes = freshData['dislikes'] ?? 0;
      transaction.update(postRef, {'dislikes': currentDislikes + 1});
    });
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

  @override
  Widget build(BuildContext context) {
    final data = widget.post.data() as Map<String, dynamic>;
    final author = data['author'] ?? '@匿名さん';
    final authorImageUrl = data['authorImageUrl'] ?? '';
    final content = data['content'] ?? '';
    final timestamp = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null;
    final likes = data['likes'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // アイコンと名前を上揃え
        children: [
          Align(
            alignment: Alignment.topCenter, // アイコンを上に揃える
            child: CircleAvatar(
              backgroundImage: authorImageUrl.isNotEmpty ? NetworkImage(authorImageUrl) : null,
              backgroundColor: Colors.grey[200],
              child: authorImageUrl.isEmpty ? const Icon(Icons.person) : null,
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textWidget = Text(
                      content,
                      style: const TextStyle(fontSize: 12),
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      maxLines: _isExpanded ? null : 4,
                    );

                    if (content.length > 100) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textWidget,
                          if (!_isExpanded)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = true;
                                });
                              },
                              child: const Text(
                                '...続きを読む',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    } else {
                      return textWidget;
                    }
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_outlined, size: 14),
                      onPressed: _updateLikes,
                    ),
                    Text(likes.toString(), style: const TextStyle(fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.thumb_down_outlined, size: 14),
                      onPressed: _updateDislikes,
                    ),
                  ],
                ),
                if (widget.showReplyCount)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.post.id)
                        .collection('replies')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final replyCount = snapshot.data!.docs.length;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyPage(post: widget.post),
                            ),
                          );
                        },
                        child: Text(
                          '$replyCount件の返信',
                          style: const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
