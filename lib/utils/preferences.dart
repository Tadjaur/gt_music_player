import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gtmusicplayer/utils/folder_model.dart';
import 'package:hive/hive.dart';
import 'package:mini_player/mini_player.dart';
import 'package:path/path.dart' as p;

import '../global_utils.dart';
import 'player.dart';

enum Dock {
  top,
  bottom,
//  left,
//  right // todo: update this later to add full smart look on desktop app.
}

class Pref extends InheritedWidget {
  Pref({
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: _Pref(child: child)) {
    data..that = (super.child as _Pref).state;
  }

  final data = _PreferencesData();

  @override
  bool updateShouldNotify(Pref old) => shouldUpdate(old);

  shouldUpdate(Pref old) {
    return this.data != old.data;
  }

  static _PreferencesData of(BuildContext context) {
    final temp = context.dependOnInheritedWidgetOfExactType<Pref>();
    return temp.data;
  }
}

class _Pref extends StatefulWidget {
  final Widget child;
  final _PrefState state = _PrefState();

  _Pref({Key key, this.child}) : super(key: key);

  @override
  _PrefState createState() => state;
}

class _PrefState extends State<_Pref> {
  final topDockView = TopDockView();
  final bottomDockView = BottomDockView();

  final savedVariable = <String, dynamic>{};
  final releaseVariable = <String, void Function()>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final func in releaseVariable.values) func?.call();
    releaseVariable.clear();
    savedVariable.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [topDockView, Expanded(child: widget.child), bottomDockView],
    );
  }

  void createLoadingState(UpdateStatus updateStatus, String varName, {Dock where}) {
    where ??= Dock.bottom; // to avoid hard null affectation on where param;
    assert(varName != null && varName.isNotEmpty);
    final streamCtrl = StreamController<UpdateStatus>.broadcast();
    savedVariable[varName] = streamCtrl;
    releaseVariable[varName] = () => streamCtrl.close();
    streamCtrl.add(updateStatus);
    Widget oldWidget = Container();
    final view = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: LinearProgressIndicator(),
          ),
          Expanded(
            child: StreamBuilder<UpdateStatus>(
                stream: streamCtrl.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    oldWidget = Text(
                      "${snapshot.data.load}/${snapshot.data.toLoad}  ${snapshot.data.fileLoaded}",
                      style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                      overflow: TextOverflow.ellipsis,
                    );
                  return oldWidget;
                }),
          ),
        ],
      ),
    );
    switch (where) {
      case Dock.top:
        topDockView.state.setState(() => topDockView.state.child = view);
        break;
      case Dock.bottom:
        bottomDockView.state.setState(() => bottomDockView.state.child = view);
        break;
    }
  }

  void updateLoadingState(UpdateStatus updateStatus, String varName, {Dock where}) {
    where ??= Dock.bottom; // to avoid hard null affectation on where param;
    assert(varName != null && varName != "");
    final aux = savedVariable[varName];
    if (aux == null) return createLoadingState(updateStatus, varName, where: where);
    if (aux is StreamController) return aux.add(updateStatus);
    assert(false, "Something brokend here");
  }

  void stopLoadingState(String varName, {Dock where}) {
    releaseVariable[varName]();
    releaseVariable.remove(varName);
    savedVariable.remove(varName);
    switch (where) {
      case Dock.top:
        topDockView.state.setState(() => topDockView.state.child = Container());
        break;
      case Dock.bottom:
        bottomDockView.state.setState(() => bottomDockView.state.child = Container());
        break;
    }
  }

  void reload() {
    setState(() {});
  }
}

class BottomDockView extends StatefulWidget {
  final state = _BottomDockViewState();

  @override
  _BottomDockViewState createState() => _BottomDockViewState();
}

class _BottomDockViewState extends State<BottomDockView> {
  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class TopDockView extends StatefulWidget {
  final state = _TopDockViewState();

  @override
  _TopDockViewState createState() => state;
}

class _TopDockViewState extends State<TopDockView> {
  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return child;
  }

  rebuild() => setState(() {});
}

class _PreferencesData {
  Box _box;
  List<FolderData> _listFolder;
  _PrefState that;

  int boxChange = -1;

  Box get box => _box;

  _PreferencesData({_PrefState prefState}) {
    that = prefState;
    initBox();
  }

  Future<List<FolderData>> get getAllSavedFolder async {
    if (_listFolder != null) return _listFolder;
    await done;
    return (_box.get(PreferenceKeys.BOX_KEY_FOLDERS) as List).cast<FolderData>();
  }

  ///todo : remove all folder that doesn't contain audio

  Future<void> get done async {
    if (_box != null) return;
    while (_box == null) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  @override
  bool operator ==(other) => other is _PreferencesData && other.boxChange != boxChange;

  @override
  int get hashCode => super.hashCode;

  Future<void> initBox() async {
    this._box = await Hive.openBox(PreferenceKeys.DEFAULT_BOX);
    this._box.watch().listen((event) {
      print("change");
      boxChange++;
      that?.reload();
    });
  }

  Future<void> setSelectedFolders(Iterable<String> paths) async {
    paths ??= [];
    await done;
    final loadStatus = UpdateStatus();
    final foldersData = <FolderData>[];
    for (final path in paths) {
      if (path == null) continue;
      final response = await _generateData(Directory(path), updateStatus: loadStatus);
      if (response == null) continue;
      foldersData.add(response);
    }
    Fn.log("\ndone\n", "\nStart box update\n");
    await _box.put(PreferenceKeys.BOX_KEY_FOLDERS, foldersData);
    Fn.log("\nall done\n");
    that?.stopLoadingState("loadingAudioMsg", where: Dock.top);
  }

  Future<FolderData> _generateData(Directory dir, {UpdateStatus updateStatus}) async {
    if (!dir.existsSync()) return null;
    final futureChildDirs = <Future<FolderData>>[];
    final parent = FolderData(
      childFolders: <FolderData>[],
      childAudios: <AudioData>[],
      absolutePath: dir.isAbsolute ? dir.path : dir.absolute.path,
    );
    for (final fse in dir.listSync()) {
      if (fse is Directory && dir.listSync().length > 0) {
//        parent.childFolders.add(await _generateData(fse, updateStatus: updateStatus));
        futureChildDirs.add(_generateData(fse, updateStatus: updateStatus));
      } else if (fse is File) {
        if ([".mkv", ".mp4", ".mp3", ".flac", ".ogg", ".aiff", ".wav", ".mp2", ".mp1", ".webm", ".m4a"]
            .contains(p.extension(fse.path).toLowerCase())) {
          try {
            updateStatus.toLoad += 1;
            final prop = await MiniPlayer().getAudioProp(fse.path);
            if (prop != null) {
              parent.childAudios.add(AudioData(
                  name: p.basename(fse.path),
                  length: prop.length,
                  bitRate: prop.bitrate,
                  sampleRate: prop.sampleRate,
                  channels: prop.channels,
                  size: fse.statSync().size,
                  parentPath: parent.absolutePath));
            } else {
              Fn.log("Null received");
            }
            updateStatus.load += 1;
            updateStatus.fileLoaded = fse.path;
            that?.updateLoadingState(updateStatus, "loadingAudioMsg", where: Dock.top);
          } catch (e) {
            Fn.log(AUDIO_ERROR: e);
          }
        }
      }
    }
    for (final future in futureChildDirs) {
      final temp = await future;
      if (temp != null) parent.childFolders.add(temp);
    }
    return (parent.childAudios.length > 0 || parent.childFolders.length > 0) ? parent : null;
  }

  void showDockPlayer() {
    that.topDockView.state.child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FlatButton.icon(
            onPressed: () {
              Fn.log(info: Player().prev);
            },
            icon: Icon(Icons.skip_previous),
            label: Text("prev")),
        FlatButton.icon(
            onPressed: () {
              Fn.log(info: Player().pause);
            },
            icon: Icon(Icons.pause),
            label: Text("Pause")),
        FlatButton.icon(
            onPressed: () {
              Fn.log(info: Player().play);
            },
            icon: Icon(Icons.play_arrow),
            label: Text("Play")),
        FlatButton.icon(
            onPressed: () {
              Fn.log(info: Player().next);
            },
            icon: Icon(Icons.skip_next),
            label: Text("Next"))
      ],
    );
    that.topDockView.state.rebuild();
  }
}

mixin PreferenceKeys {
  static const String DEFAULT_BOX = "defaultBox";
  static const String BOX_KEY_FOLDERS = "selectedFolder";
  static const String BOX_KEY_FOLDERS_PATH = "selectedFolderPath";
}

class UpdateStatus {
  int load = 0;
  int toLoad = 0;
  String fileLoaded;
}

extension TS on TextStyle {
  TextStyle updateSize(double amount) {
    if (amount == null) amount = 0;
    return this.copyWith(fontSize: this.fontSize + amount);
  }
}

extension AS on AudioData {
  String get sizeStr {
    final result = "";
    final kb = this.size ~/ 1024;
    if (kb < 1024) return "${kb}KB";
    final mb = kb ~/ 1024;
    if (mb < 1024) return "${mb}MB";
    final gb = mb ~/ 1024;
    return "${gb}GB";
  }

  String get duration {
    final min = this.length ~/ 60;
    if (min < 60) return "${min}m ${this.length % 60}s";
    final h = min ~/ 60;
    if (h < 24) return "${h}h ${min % 60}m ${this.length % 60}s";
    final d = h ~/ 24;
    return "${d}d ${h % 24}h ${min % 60}m ${this.length % 60}s";
  }
}
