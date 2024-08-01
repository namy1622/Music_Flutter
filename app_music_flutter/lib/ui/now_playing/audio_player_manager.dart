import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = "";

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));

    if(isNewSong){ // neéu là bài hát mới thì mới phát từ đầu( conf nếu bài hát đang phát thì phát tiếp)
      player.setUrl(songUrl);
    }
  }

  void updateSongUrl(String url){
      songUrl = url;
      prepare();
  }

  void dispose(){
    player.dispose();
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, this.total});

  final Duration progress; // thời lượng tiến trình của bài hát
  final Duration buffered; // thời lượng đã được tải
  final Duration? total; // tôngr thời lượng bài hát
}

// Duration là lớp đại diện cho 1 khoảng thời gian, dùng hiên rthij khoange thời gian khác nhau( số ngyaf, phút, giây,
