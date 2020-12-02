import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gtmusicplayer/generated/l10n.dart';
import 'package:gtmusicplayer/platform_spec/platform_util.dart';
import 'package:gtmusicplayer/utils/folder_model.dart';
import 'package:gtmusicplayer/utils/player.dart';
import 'package:gtmusicplayer/utils/preferences.dart';
import 'package:path/path.dart' as pt;

class FolderScreen extends StatefulWidget {
  final FolderData currentFolderData;

  const FolderScreen({Key key, this.currentFolderData}) : super(key: key);

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  Widget finalContent(BuildContext context, List<FolderData> folders) {
    assert(folders.length > 0, "the length of the folder least one");
    print(folders);
    return Container(
      child: ListView(
        children: [
          for (final folderData in folders)
            Tooltip(
              message: "player is starting...",
              child: FileView(
                folder: folderData,
                onClick: (fs, [bool value]) {
                  if (fs is FolderData)
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => FolderScreen(
                              currentFolderData: fs,
                            )));
                },
                onLongTapOrRightClick: (folderOrAudio) async {
                  /// todo: show option {play, playNext, createPlayList}
                  /// for now we play the selected folder.
                  await Player().add(folderOrAudio);
                  Pref.of(context).showDockPlayer();
                },
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Process
    if (widget.currentFolderData != null)
      return Scaffold(
          appBar: AppBar(
            title: Text(pt.dirname(widget.currentFolderData.absolutePath)),
          ),
          body: finalContent(context, [widget.currentFolderData]));
    return FutureBuilder<List<FolderData>>(
      future: Pref.of(context)?.getAllSavedFolder,
      builder: (ctx, snapShot) {
        if (!snapShot.hasData || snapShot.data.length == 0)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton.icon(
                onPressed: () => addFolder(context),
                icon: Icon(Icons.add),
                label: Text(
                  S.of(context).addFolder,
                  style: Theme.of(context).textTheme.headline4,
                ),
              )
            ],
          );
        return finalContent(context, snapShot.data);
      },
    );
  }

  void addFolder(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.grey.withOpacity(0.1),
      barrierColor: Colors.grey.withOpacity(0.1),
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          ModalRoute.of(context).completed.then((_) {
            ShowFolder._mapExpand.clear();
          });
          return Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                boxShadow: [BoxShadow(color: Colors.grey.shade100, offset: Offset(0, -2), blurRadius: 5)],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("Folders"),
                      onPressed: () {
                        //todo: toggleView
                      },
                    ),
                    FlatButton(
                      child: Text("Settings"),
                      onPressed: () {
                        //todo: toggleView
                      },
                    )
                  ],
                ),
                Expanded(
                  child: ShowFolder(scrollController: scrollController),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          S.of(context).cancel,
                          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.deepOrange.shade900),
                        )),
                    FlatButton(
                        onPressed: () {
                          Pref.of(parentContext).setSelectedFolders([
                            for (final key in ShowFolder._mapExpand.keys)
                              if (ShowFolder._mapExpand[key][1]) key
                          ]);
                          Navigator.of(ctx).pop();
                        },
                        child: Text(S.of(context).save)),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ShowFolder extends StatelessWidget {
  static List<StorageDevice> _savedStorage;

  final ScrollController scrollController;
  static final _mapExpand = <String, Map<int, bool>>{};

  Future<List<StorageDevice>> get storage async {
    if (_savedStorage == null) _savedStorage = await PUtils().listStorage;
    return _savedStorage;
  }

  Widget showDir(Directory dir, {double oldSpace = 0, double spaceUnit = 10, bool showHidden}) {
    assert(oldSpace >= 0 && spaceUnit >= 5);
    _mapExpand[dir.path] ??= {0: false, 1: false};
    showHidden ??= false;
//    if(fse is File){
//      MiniPlayer().getAudioProp(mediaPath)
//    }

    final mode = dir.statSync().modeString();
    final fse = mode[mode.length - 3] != "r" ? [] : dir.listSync();
    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _mapExpand[dir.isAbsolute ? dir.path : dir.absolute.path][1]
                  ? null
                  : _mapExpand[dir.isAbsolute ? dir.path : dir.absolute.path][0] =
                      !_mapExpand[dir.isAbsolute ? dir.path : dir.absolute.path][0]),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: oldSpace,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                          onTap: () => setState(() => _mapExpand[dir.path][1] = !_mapExpand[dir.path][1]),
                          child: _mapExpand[dir.path][1] ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.folder),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(pt.basename(dir.path)),
                    )
                  ],
                ),
              ),
            ),
            if (_mapExpand[dir.isAbsolute ? dir.path : dir.absolute.path][0] &&
                !_mapExpand[dir.isAbsolute ? dir.path : dir.absolute.path][1])
              for (final fs in fse)
                if (fs is Directory && (showHidden || pt.basename(fs.path)[0] != '.'))
                  showDir(fs, oldSpace: oldSpace + spaceUnit, spaceUnit: spaceUnit)
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StorageDevice>>(
      future: storage,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return ListView(
          controller: scrollController,
          children: [
            for (final dir in snapshot.data)
              if (dir != null) showDir(Directory(dir.rootPath))
          ],
        );
      },
    );
  }

  ShowFolder({this.scrollController});
}

class FileView extends StatelessWidget {
  final FolderData folder;
  final AudioData audio;

//  final bool //rightToLeft;
  final int currentSpace;
  final int spaceUnit;

//  final bool extend;
  final bool selectable;
  final bool childOnly;

//  final bool showAudioFile;
  final void Function(dynamic fs, [bool value]) onClick;
  final void Function(dynamic fs) onLongTapOrRightClick;

  const FileView(
      {Key key,
      this.folder,
      this.audio,
      @required this.onClick,
      this.onLongTapOrRightClick,
//      bool //rightToLeft,
      int currentSpace,
      int spaceUnit,
//      bool extend,
      bool selectable,
//      bool showAudioFile,
      bool childOnly})
      : assert((folder == null && audio != null) || (folder != null && audio == null),
            "both `folder` and `audio` params can't be null or not null"),
        //rightToLeft = //rightToLeft ?? false,
        currentSpace = currentSpace ?? 0,
        spaceUnit = spaceUnit ?? 10,
//        extend = extend ?? false,
        selectable = selectable ?? false,
        childOnly = childOnly ?? false,
//        showAudioFile = showAudioFile ?? true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onSecondaryTap: () => onLongTapOrRightClick?.call(folder ?? audio),
            onLongPress: () => onLongTapOrRightClick?.call(folder ?? audio),
            child: headerItem(context)),
        if (folder != null) ...childItems(),
      ],
    );
  }

  String get absolutePath {
    if (folder != null) return folder.absolutePath;
    return pt.join(audio.parentPath, audio.name);
  }

  Widget headerItem(BuildContext context) {
    if (childOnly) return Container();
    if (selectable) {
      return Row(
        children: [
          SizedBox(
            width: currentSpace.toDouble(),
          ),
          Expanded(
            child: CheckboxListTile(
              value: false,
              onChanged: (bool value) => this.onClick?.call(folder ?? audio, value),
              title: Text(pt.basename(absolutePath), style: Theme.of(context).textTheme.subtitle2),
              secondary: (folder != null) ? Icon(Icons.folder) : (audio != null) ? Icon(Icons.audiotrack) : Container(),
              subtitle: audio == null
                  ? LimitedBox(maxWidth: 0.0, maxHeight: 0.0)
                  : Row(
                      children: [
                        Text(audio.duration),
                      ],
                    ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        SizedBox(
          width: currentSpace.toDouble(),
        ),
        Expanded(
          child: ListTile(
            onTap: () => this.onClick?.call(folder ?? audio),
            leading: (folder != null) ? Icon(Icons.folder) : (audio != null) ? Icon(Icons.audiotrack) : Container(),
            subtitle: audio == null
                ? LimitedBox(maxWidth: 0.0, maxHeight: 0.0)
                : Row(
                    children: [
                      Text(audio.duration),
                    ],
                  ),
            trailing: audio == null ? LimitedBox(maxWidth: 0.0, maxHeight: 0.0) : Text("${audio.sizeStr}"),
            title: Text(pt.basename(absolutePath), style: Theme.of(context).textTheme.subtitle2),
          ),
        ),
      ],
    );
  }

  List<Widget> childItems() {
//    if (!extend) return [];
    final result = [
      for (final fd in folder.childFolders)
        FileView(
          folder: fd,
          onClick: onClick,
          childOnly: childOnly,
          currentSpace: currentSpace + spaceUnit,
          spaceUnit: spaceUnit,
//          extend: extend,
          //rightToLeft: //rightToLeft,
//          showAudioFile: showAudioFile,
          selectable: selectable,
        )
    ];
//    if (!showAudioFile)
    result.addAll([
      for (final ad in folder.childAudios)
        FileView(
          audio: ad,
          onClick: onClick,
          childOnly: childOnly,
          currentSpace: currentSpace + spaceUnit,
          spaceUnit: spaceUnit,
//            extend: extend,
          //rightToLeft: //rightToLeft,
//            showAudioFile: showAudioFile,
          selectable: selectable,
        )
    ]);
    return result;
  }
}
