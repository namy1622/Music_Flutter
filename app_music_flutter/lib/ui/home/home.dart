import 'package:app_music_flutter/ui/discovery/discovery.dart';
import 'package:app_music_flutter/ui/home/viewmodel.dart';
import 'package:app_music_flutter/ui/now_playing/audio_player_manager.dart';
import 'package:app_music_flutter/ui/settings/settings.dart';
import 'package:app_music_flutter/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  // MusicAp là lớp mở rộng của StatelessWiget
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp là rootwidget của ứng dụng, chứa nhiều chức năng: theme, navigation,...
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home:
          MusicHomePage(), // định nghĩa widget hiển thị đầu tiền khi app chạy( ở đây là MusicHomePage
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatelessWidget {
//  const MusicHomePage({super.key});

  final List<Widget> _tabs = [
    // ds cac tab, ds widget được hiển thị khi chuyển đổi giữa các tab
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // navigationBar -> thanh điều hướng trên của trang
      navigationBar: const CupertinoNavigationBar(
        // ở đây là CupertinoNavigationBar
        middle:
            Text('Music App'), // middle: vitri đứng trung tâm thanh điều hướng
      ),

      //child: nội dung của trang
      child: CupertinoTabScaffold(
        // widget dùng để quản lý + hiển thị tab
        tabBar: CupertinoTabBar(
          // thanh tabbar( hiển thị dưới cùng)
          backgroundColor:
              Theme.of(context).colorScheme.onInverseSurface, // màu nền tabbar
          items: const [
            // danh sachs các item ở thanh tabbar
            // mỗi item là 1 BottomNavigationBarItem
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Setting'),
          ],
        ),

        tabBuilder: (BuildContext context, int index) {
          // hàm xây dưng widget cho từng tab dựa trên index
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // khung sườn chính tạo giao diện
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream
        .close(); // mỗi khi sd stream phải close để giải phóng nó
    AudioPlayerManager().dispose();
    super.dispose();
  }

  getBody() {
    bool showLoading = songs.isEmpty; // không rỗng

    if (showLoading) {
      // nếu ds đang rỗng chưa có gì
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center();
  }

  ListView getListView() {
    return ListView.separated(
      // đường ngang phân tách giữa các phần tử
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
            color: Colors.grey,
            thickness: 1, // độ dày
            indent: 24, // cách trái
            endIndent: 24 // cách phải,
            );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    // trả về 1 Item
    return _songItemSection(parent: this, song: songs[index]);
  }

  void observerData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showButtomSheet(){
      showModalBottomSheet(
          context: context,
          builder: (context){
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 400,
                  color: Colors.grey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Model Bottom Sheet'),
                        ElevatedButton(
                            onPressed: ()=> Navigator.pop(context),
                            child: const Text('Close Bottom Sheet')
                        )
                      ],
                    ),
                  ),
              ),
            );
          });
  }

  void navigate(Song song){
    Navigator.push(context,
        CupertinoPageRoute(builder: (context){
          return NowPlaying(
            songs: songs,
            playingSong: song,
          );
        })
    );
  }
}

// class lấy thông tin ảnh tên tiêu đề... bài hát
class _songItemSection extends StatelessWidget {
  final _HomeTabPageState parent;
  final Song song;

  const _songItemSection({required this.parent, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(

      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(14),

        child: FadeInImage.assetNetwork(
          // leading là ảnh cua bai hat,
          placeholder: 'assets/itunes.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showButtomSheet();
        },
      ),

      // sk khi bấm vào từng phần tử (item)
      onTap: (){
        parent.navigate(song);
      },
    );
  }
}
