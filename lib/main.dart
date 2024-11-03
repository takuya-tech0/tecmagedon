import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tecmage/widgets/post_list.dart'; // 掲示板のウィジェットをインポート
import 'package:firebase_core/firebase_core.dart'; // Firebaseをインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  int _selectedIndex = 0;

  final TextEditingController _commentController = TextEditingController(); // コメント入力コントローラ

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/sample.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose(); // コメントコントローラを破棄
    super.dispose();
  }

  Future<void> _addComment(String content) async {
    if (content.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('posts').add({
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'author': '@匿名さん',
          'likes': 0,
          'dislikes': 0,
        });
        _commentController.clear();
        FocusScope.of(context).unfocus(); // キーボードを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿が完了しました')),
        );
      } catch (error) {
        print('投稿エラー: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿に失敗しました。ネットワークを確認してください。')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容を入力してください')),
      );
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: const Icon(
                Icons.list,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "高校１年生  物理",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "第１講   物体の位置、速度、加速度",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // 動画プレイヤー部分
            _controller.value.isInitialized
                ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Positioned(
                  bottom: 4,
                  left: 12,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isPlaying ? _controller.pause() : _controller.play();
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        iconSize: 24,
                      ),
                      Expanded(
                        child: Slider(
                          value: _controller.value.position.inSeconds.toDouble(),
                          max: _controller.value.duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _controller.seekTo(Duration(seconds: value.toInt()));
                            });
                          },
                          activeColor: Colors.red,
                          inactiveColor: Colors.white,
                        ),
                      ),
                      Text(
                        "${formatDuration(_controller.value.position)} / ${formatDuration(_controller.value.duration)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : const CircularProgressIndicator(),
            // タブバー
            const TabBar(
              indicatorColor: Colors.purple,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: 14), // 選択時のテキストサイズ
              unselectedLabelStyle: TextStyle(fontSize: 12), // 未選択時のテキストサイズ
              tabs: [
                Tab(text: "テキスト"),
                Tab(text: "掲示板"),
                Tab(text: "AIチャット"),
                Tab(text: "メモ"),
              ],
            ),
            // タブごとの内容を表示
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: SingleChildScrollView(child: Image.asset('assets/images/text_sample.png'))),
                  Column(
                    children: [
                      Expanded(child: PostList()), // 掲示板ウィジェット
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
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'コメントする...',
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
                              onPressed: () => _addComment(_commentController.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Center(child: Text("AIチャットの内容")),
                  Center(child: Text("メモの内容")),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28,),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 28,),
              label: '学習プラン',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book, size: 28,),
              label: '講座一覧',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark_outlined, size: 28,),
              label: '後で確認',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28,),
              label: 'マイページ',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 10), // 選択時のテキストサイズ
          unselectedLabelStyle: const TextStyle(fontSize: 10), // 未選択時のテキストサイズ
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFE8DFFA),
        ),
      ),
    );
  }
}
