import 'package:flutter/material.dart';
import 'package:gtmusicplayer/platform_spec/platform_util.dart';
import 'package:gtmusicplayer/screen/home.dart';
import 'package:gtmusicplayer/utils/preferences.dart';

import 'generated/l10n.dart';
import 'global_utils.dart';

class _AppService {
  AppLifecycleState _currentState;
  void Function(void Function()) _changeState;

  // ignore: non_constant_identifier_names
  AppLifecycleState get AppState => _currentState;

  void globalRebuild() {
    _changeState?.call(() {});
  }
}

// ignore: non_constant_identifier_names
final AppService = _AppService();

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    AppService._changeState = setState;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppService._changeState = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppService._currentState = state;
  }

  @override
  Widget build(BuildContext context) {
    PUtils().listStorage.then((value) => Fn.log(value: value));
    return MaterialApp(
      title: 'GT Music Player',
      localizationsDelegates: [S.delegate],
      color: Colors.blueGrey.shade200,
      theme: ThemeData(
        fontFamily: "Comfortaa",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.blueGrey.shade200,
        dialogBackgroundColor: Colors.blueGrey.shade200,
      ),
      home: Pref(child: HomeScreen()),
    );
  }
}
