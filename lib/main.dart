import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
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
    super.dispose();
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
      length: 4, // タブの数を指定
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
                  size: 28
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
                    fontSize: 10
                ),
              ),
              SizedBox(height: 4,),
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
                        iconSize: 24, // アイコンのサイズを指定して高さを調整
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
                          fontSize: 12, // サイズを小さく設定
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
              tabs: [
                Tab(text: "テキスト"),
                Tab(text: "掲示板"),
                Tab(text: "AIチャット"),
                Tab(text: "メモ"),
              ],
            ),
            // タブごとの内容を表示
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text("テキストの内容")),
                  Center(child: Text("掲示板の内容")),
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
          backgroundColor: const Color(0xFFE8DFFA),  // フッターの背景色
        ),
      ),
    );
  }
}
