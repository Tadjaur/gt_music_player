import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gtmusicplayer/platform_spec/platform_util.dart';
import 'package:gtmusicplayer/utils/folder_model.dart';
import 'package:hive/hive.dart';

import '../global_utils.dart';

class Pref extends StatelessWidget {
  Pref({@required this.child}) {
    PUtils().dbStoragePath.then((dir) {
      Hive
        ..init(dir.isAbsolute ? dir.path : dir.absolute.path)
        ..registerAdapter(FolderDataAdapter())
        ..registerAdapter(AudioDataAdapter());
    });
    data._hiveInitComplete = true;
  }

  final Widget child;

  static _PreferencesData of(BuildContext context) {
    final temp =
        (context.dependOnInheritedWidgetOfExactType(aspect: _InheritedStateContainer) as _InheritedStateContainer);
    Fn.log(PrefImpl: temp.data);
    Fn.log(PrefImpl_data: temp.data?.data);
    return temp?.data?.data;
  }

  final data = _PreferencesData();

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(data: this, child: child);
  }

  shouldUpdate(Pref oldState) {
    return this.data != oldState.data;
  }
}

class _PreferencesData {
  bool _hiveInitComplete = false;
  Box _box;
  List<FolderData> _listFolder;

  Box get box => _box;

  _PreferencesData() {
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
  bool operator ==(other) => other is! Pref && false;

  @override
  int get hashCode => super.hashCode;

  Future<void> initBox() async {
    while (!_hiveInitComplete) {
      await Future.delayed(Duration(milliseconds: 10));
    }
    this._box = await Hive.openBox(PreferenceKeys.DEFAULT_BOX);
  }
}

mixin PreferenceKeys {
  static const String DEFAULT_BOX = "defaultBox";
  static const String BOX_KEY_FOLDERS = "selectedFolder";
}

class _InheritedStateContainer extends InheritedWidget {
  const _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  })  : assert(child != null && data != null),
        super(key: key, child: child);

  final Pref data;

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => data.shouldUpdate(old.data);
}
