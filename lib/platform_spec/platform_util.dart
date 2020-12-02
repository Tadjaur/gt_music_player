import 'dart:io' as io;

import 'package:path/path.dart' as pt;
import 'package:path_provider/path_provider.dart' as pp;

class PUtils {
  /// return the home directory with it name on the device
  Map<String, String> get homeDirectory {
    throw UnsupportedError('hw_none message');
  }

  /// return the app storage directory with it name on the device
  Future<io.Directory> get dbStoragePath {
    return io.Platform.isAndroid || io.Platform.isIOS ? _dbStoragePathMobile() : _dbStoragePathDesktop();
  }

  /// return mounted list of storage available on the device
  Future<List<StorageDevice>> get listStorage {
    return io.Platform.isAndroid
        ? _listStorageAndroid()
        : io.Platform.isIOS
            ? _listStorageIos()
            : io.Platform.isWindows
                ? _listStorageWindows()
                : io.Platform.isMacOS ? _listStorageMac() : _listStorageLinux();
  }

  Future<List<StorageDevice>> _listStorageAndroid() async {
    final data = await pp.getExternalStorageDirectories();
    return [
      for (final dir in data) ...[StorageDevice._(rootPath: dir.path)]
    ];
  }

  Future<List<StorageDevice>> _listStorageIos() async {
    final data = await pp.getApplicationDocumentsDirectory();
    return [
      ...[StorageDevice._(rootPath: data.path)]
    ];
  }

  Future<List<StorageDevice>> _listStorageLinux() async {
    final tempPR = await io.Process.run("df", ["-h", "--output=size,used,avail,pcent,target"]);
    final tempFile = io.File(pt.join(io.Directory.systemTemp.path, "process-result.taur"));
    tempFile.writeAsStringSync(tempPR.stdout is String ? tempPR.stdout : "");
    final result2 = await io.Process.run("grep", ["/media/", tempFile.path]);
    return [
      StorageDevice._(rootPath: "/"),
      for (String str in result2.stdout.toString().split("\n")) ...[
        StorageDevice.fromIterable(str.split("\ ")..removeWhere((element) => element.length < 2))
      ]
    ];
  }

  Future<List<StorageDevice>> _listStorageWindows() async {
    return null;
  }

  Future<List<StorageDevice>> _listStorageMac() async {
    return null;
  }

  Future<io.Directory> _dbStoragePathMobile() async {
    return await pp.getApplicationSupportDirectory();
  }

  Future<io.Directory> _dbStoragePathDesktop() async {
    // todo: change the reference to ~/.local/share/myAppName
    return io.Directory(pt.dirname(io.Platform.resolvedExecutable));
  }
}

class StorageDevice {
  String size, used, available, usePercent, rootPath;

  factory StorageDevice.fromIterable(List<String> list) {
    print(list.length);
    print(list);
    if (list.length < 5) return null;
    return StorageDevice._(size: list[0], used: list[1], available: list[2], usePercent: list[3], rootPath: list[4]);
  }

  StorageDevice._({this.size, this.used, this.available, this.usePercent, this.rootPath});

  @override
  String toString() {
    return "{size:$size, used:$used, available:$available, usePercent:$usePercent, rootPath:$rootPath}";
  }
}
