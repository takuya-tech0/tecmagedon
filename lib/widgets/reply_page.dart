import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_item.dart';
import 'reply_list.dart';

class ReplyPage extends StatefulWidget {
  final QueryDocumentSnapshot post;

  const ReplyPage({super.key, required this.post});

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  final TextEditingController _replyController = TextEditingController();
  int _selectedIndex = 0; // 現在選択されているインデックスを管理

  Future<void> _addReply(String content) async {
    if (content.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id)
            .collection('replies')
            .add({
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'author': '@返信さん',
          'authorImageUrl': '',
          'likes': 0,
        });
        _replyController.clear();
        FocusScope.of(context).unfocus(); // キーボードを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('返信が送信されました')),
        );
      } catch (error) {
        print('返信エラー: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('返信に失敗しました。ネットワークを確認してください。')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容を入力してください')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // 必要に応じて、特定のインデックスに対応するナビゲーションを追加します。
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '返信',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFF2F2F2),
            child: PostItem(post: widget.post, showReplyCount: false),
          ),
          Expanded(
            child: ReplyList(postId: widget.post.id),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: '返信を追加...',
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () => _addReply(_replyController.text),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '学習プラン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '講座一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '教室情報',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFE8DFFA),
      ),
    );
  }
}
