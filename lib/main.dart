import 'package:flutter/widgets.dart';
import 'package:gtmusicplayer/app.dart';
import 'package:gtmusicplayer/platform_spec/platform_util.dart';
import 'package:gtmusicplayer/utils/folder_model.dart';
import 'package:hive/hive.dart';

void main() {
  PUtils().dbStoragePath.then((dir) {
    Hive
      ..init(dir.isAbsolute ? dir.path : dir.absolute.path)
      ..registerAdapter(FolderDataAdapter())
      ..registerAdapter(AudioDataAdapter());
    runApp(MyApp());
  });
}
