import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong; // biến đại diện cho bài hát đang phát
  final List<Song> songs; // danh sách bài hát
  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
// hàm tạo ra 1 instance của NowPlayingPageState , lớp quản lý trangj thái của NowPlayingPage
}

//----------------------------------------------------------
class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager
      _audioPlayerManager; // vịtri hien tai cua bai hát trong danh sách

  late int _selectedItemIndex;

  late Song _song;

  late double _currentAnimationPosition; // biến đại diện cho vòng xoay đĩa nhạc

  bool _isShuffle = false;

  late LoopMode _loopMode; // nằm trong  lớp just audio
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager();

    // kiểm tra nếu là bài hát mới thì -> true dể phát từ ddauf
    if(_audioPlayerManager.songUrl.compareTo(_song.source) != 0){
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare( isNewSong: true); // goi den ham khoi tao
    }
    // nếu đang có bài hát đang phát
    else {
      _audioPlayerManager.prepare(isNewSong: false);
    }
    _selectedItemIndex = widget.songs
        .indexOf(widget.playingSong); // lấy ra vitri(id) của bài hát

    _loopMode = LoopMode.off;
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold(
    //   body: Center(
    //     child: Text('now playing'),
    //   ),
    // );

    final screenWidth = MediaQuery.of(context)
        .size
        .width; // lấy ra độ rộng màn hình của máy hiện tại
    const delta = 64; // khoangr cachs từ mép ảnh đến mép màn hình
    final radius = (screenWidth - delta) / 2; // thiết lập bán kính cong
    return CupertinoPageScaffold(
      // navigationBar : thanh điều hướng trên của trang
      navigationBar: CupertinoNavigationBar(
        // ở đây là CupertinoNavigationBar
        middle: const Text(
          'Now Playing',
        ),
        // trailing : là vị trí cuối(end) của navigationBar
        trailing:
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
      ),
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_song.album),
            // widget là lớp cha, gọi lớp cha để truy cập được bài hát đang phát
            const SizedBox(
              height: 16,
            ),
            const Text('_ ___ _'),
            const SizedBox(
              height: 48,
            ),

            RotationTransition(
              //// hiệu ứng xoay tròn của đĩa nhạc
              turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itunes.png',
                  image: _song.image,
                  width: screenWidth - delta,
                  height: screenWidth - delta,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/itunes.png',
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 64, bottom: 16),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Column(
                      children: [
                        Text(
                          _song.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          _song.artist,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline))
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 10),
              child: _progressBar(),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 10),
              child: _mediaButtons(),
            )
          ],
        )),
      ),
    );
  }

  // StreamBuilder<DurationState> _mediaButtons(){
  //
  // }

  @override
  void dispose() {
    // mỗi khi màn hình hiện tại tắt thì bài hát hiện tại cũng tắt( hủy bài hát hiện tai)
   // _audioPlayerManager.dispose();

    _imageAnimController
        .dispose(); // khi rời màn hình hiện tại thì cũng hủy đĩa xoay

    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36),
          //MediaButtonControl(function: null, icon: Icons.play_arrow, color: Colors.deepPurple, size: 48),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36),
          MediaButtonControl(
              function: _setupRepeatOption,
              icon: _repeatingIcon(),
              color: _getRepeatingColor(),
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;

          // trả về thanh progressBar bài hát đang chạy
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.4),
            progressBarColor: Colors.green,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.green.withOpacity(0.3),
            thumbRadius: 10.0,
          );
        });
  }

  //----------------------------------------
  // hàm để chọn bài hát ngẫu nhiên( trộn bài)
  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  // hàm để đổi màu của button Shuffle
  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

//-----------------------------------------------------
  // hàm chọn bài hát nexr - prev
  // TIẾN BÀI --------
  void _setNextSong() {
    // kiểm tra nếu đang chế độ trộn bài
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt((widget.songs.length));
    } else if (_selectedItemIndex < widget.songs.length) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    // nếu next vượt quá length
    if (_selectedItemIndex > widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    //
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  // LÙI BÀI------
  void _setPrevSong() {
    // kiểm tra nếu đang chế độ trộn bài
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt((widget.songs.length));
    } else if (_selectedItemIndex < 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    // nếu prev vượt quá length
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    //
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  //-----------------------------------------------------
  //--- lặp bài hát--------------------------------
  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  void _setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  //--------------------------------------------------------
  // load bài hát từ internet về
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState =
              snapshot.data; // trạng tháy hiện tại của nut play- pause
          final processingState =
              playState?.processingState; // trạng thái xử lý
          final playing = playState?.playing; // trạng thái đang phát

          // duyệt các trường hợp : đang phát, đang load,...
          if (processingState == ProcessingState.loading // đang load
              ||
              processingState == ProcessingState.buffering) {
            //  đang load, tải dl từ internet
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child:
                  const CircularProgressIndicator(), // hiển thị trạng thái đang load,
            );
          } else if (playing != true) {
            // nếu ko đang phát -> hiển thị nút play
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();

                  // đĩa nhạc xoay
                  _imageAnimController.forward(from: _currentAnimationPosition);
                  _imageAnimController
                      .repeat(); // khi hết 1 vòng thì lặp lại tiếp
                },
                icon: Icons.play_arrow,
                color: null,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            // nếu chưa chạy hết bài hát --> hiển thị nút pause
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.pause();

                  _imageAnimController
                      .stop(); // khi pause thì đĩa xoay cũng stop
                  _currentAnimationPosition = _imageAnimController
                      .value; // luưu lại giá trị vòng xoay hiện tại khi pause
                },
                icon: Icons.pause,
                color: null,
                size: 48);
          } else {
            //  tuự động reset bài hát về time 0

            if (processingState == ProcessingState.completed) {
              _imageAnimController.stop();
              _currentAnimationPosition = 0.0;
            }
            return MediaButtonControl(
                function: () {
                  // khi replay lại thì giá trị đĩa cho = 0 để chạy từ đầu
                  //_currentAnimationPosition = 0.0;
                  _imageAnimController.forward(from: _currentAnimationPosition);

                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: null,
                size: 48);
          }
        });
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
//----------------------------------------------------------------
