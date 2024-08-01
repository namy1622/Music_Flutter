import 'package:app_music_flutter/data/repository/repository.dart';
import 'package:app_music_flutter/ui/home/home.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MusicApp());


// Future<void> main() async {
//   // kiểm tra đã lấy dl từ internet thành công chưa
//   var repository = DefaultRepository();
//   var songs = await repository.loadData(); // trả về 1 Future --> await
//
//   if (songs != null) {
//     for (var song in songs) {
//       debugPrint(song.toString()); // in ra kết quả lấy từ internet (console)
//     }
//   }
// }
// //-------------------------------------------------------------
//
// class MusicApp extends StatelessWidget {
//   const MusicApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
