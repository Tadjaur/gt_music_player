import 'package:gtmusicplayer/global_utils.dart';
import 'package:gtmusicplayer/utils/folder_model.dart';
import 'package:mini_player/mini_player.dart';
import 'package:path/path.dart';

class Player {
  static Player _instance;

  factory Player() {
    if (_instance == null) _instance = Player._();
    return _instance;
  }

  Player._() : _miniPlayer = MiniPlayer();

  final MiniPlayer _miniPlayer;
  final playlist = <AudioData>[];
  bool isPlaying = false;
  bool wasInit = false;

  Future<bool> get next async {
    if (wasInit) {
      return _miniPlayer.sendEvent(AudioEvent.next);
    }
    return false;
  }

  Future<bool> get prev async {
    if (wasInit) {
      return _miniPlayer.sendEvent(AudioEvent.previous);
    }
    return false;
  }

  Future<bool> get pause async {
    if (wasInit) {
      return _miniPlayer.sendEvent(AudioEvent.pause);
    }
    return false;
  }

  Future<bool> get play async {
    if (wasInit) {
      return _miniPlayer.sendEvent(AudioEvent.play);
    }
    return false;
  }

  /// Add the current file or folder to the playlist and star playing if none previous playlist exist
  Future<bool> add(dynamic folderOrAudioData) async {
    assert(folderOrAudioData is FolderData || folderOrAudioData is AudioData);
    final playlist = <AudioData>[];
    if (folderOrAudioData is AudioData)
      playlist.add(folderOrAudioData);
    else if (folderOrAudioData is FolderData) {
      List<AudioData> Function(FolderData) recursiveClosure;
      recursiveClosure = (fd) {
        final result = <AudioData>[];
//        if (fd.childFolders.length > 0) {
//          result.addAll([for (final cfd in fd.childFolders) ...recursiveClosure(cfd)]);
//        }
        result.addAll([for (final cad in fd.childAudios) cad]);
        return result;
      };
      playlist.addAll(recursiveClosure(folderOrAudioData));
    }
//    if (isPlaying)
//      _miniPlayer.playNext(pathOfAudio(playlist));
//    else {
    final done = await _miniPlayer.init(pathOfAudio(playlist));
    Fn.log(_miniPlayerInit: done);
    wasInit = done;
    if (done) return await _miniPlayer.sendEvent(AudioEvent.play).then((done) => isPlaying = done);
//    }
    this.playlist.addAll(playlist);
    return false;
  }

  List<String> pathOfAudio(List<AudioData> playlist) {
    return [for (final audioData in playlist) join(audioData.parentPath, audioData.name)];
  }
}
