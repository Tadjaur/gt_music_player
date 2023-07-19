import 'package:hive/hive.dart';
import 'package:meta/meta.dart' show required;

@HiveType(typeId: FolderData._typeId)
class FolderData {
  static const _typeId = 1;

  @HiveField(0)
  final String absolutePath;

  @HiveField(1)
  final List<FolderData> childFolders;

  @HiveField(2)
  final List<AudioData> childAudios;

  FolderData(
      {@required this.absolutePath, @required List<FolderData> childFolders, @required List<AudioData> childAudios})
      : assert(absolutePath != null || absolutePath.isNotEmpty),
        assert(childFolders != null || childAudios != null, "the folder must not be empty"),
        childFolders = childFolders ?? [],
        childAudios = childAudios ?? [];

  @override
  String toString() {
    return 'Folder:: $absolutePath';
  }
}

class FolderDataAdapter extends TypeAdapter<FolderData> {
  @override
  FolderData read(BinaryReader reader) {
    var fields = <int, dynamic>{
      for (var i = 0; i < 3; i++) reader.readByte(): reader.read(),
    };
    return FolderData(
        absolutePath: fields[0] as String,
        childFolders: (fields[1] as List)?.cast<FolderData>(),
        childAudios: (fields[2] as List)?.cast<AudioData>());
  }

  @override
  int get typeId => FolderData._typeId;

  @override
  void write(BinaryWriter writer, FolderData obj) {
    writer
      ..writeByte(0)
      ..write(obj.absolutePath)
      ..writeByte(1)
      ..write(obj.childFolders)
      ..writeByte(2)
      ..write(obj.childAudios);
  }
}

@HiveType(typeId: AudioData._typeId)
class AudioData {
  static const _typeId = 2;
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int length;
  @HiveField(2)
  final int bitRate;
  @HiveField(3)
  final int sampleRate;
  @HiveField(4)
  final int channels;
  @HiveField(5)
  final int size;
  @HiveField(6)
  final String parentPath;

  AudioData(
      {@required this.name,
      @required this.length,
      @required this.bitRate,
      @required this.sampleRate,
      @required this.channels,
      @required this.size,
      @required this.parentPath})
      : assert(name != null &&
            length != null &&
            bitRate != null &&
            sampleRate != null &&
            channels != null &&
            size != null &&
            parentPath != null);

  @override
  String toString() {
    return 'Audio:: $name - length: $length - simpleRate: $sampleRate - bitRate: $bitRate - size: $size';
  }
}

class AudioDataAdapter extends TypeAdapter<AudioData> {
  @override
  AudioData read(BinaryReader reader) {
    var fields = <int, dynamic>{
      for (var i = 0; i < 7; i++) reader.readByte(): reader.read(),
    };
    return AudioData(
        name: fields[0] as String,
        length: fields[1] as int,
        bitRate: fields[2] as int,
        sampleRate: fields[3] as int,
        channels: fields[4] as int,
        size: fields[5] as int,
        parentPath: fields[6] as String);
  }

  @override
  int get typeId => AudioData._typeId;

  @override
  void write(BinaryWriter writer, AudioData obj) {
    writer
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.length)
      ..writeByte(2)
      ..write(obj.bitRate)
      ..writeByte(3)
      ..write(obj.sampleRate)
      ..writeByte(4)
      ..write(obj.channels)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.parentPath);
  }
}

/// todo: add PlayList class that extend FolderData or that take the reference of main sub folder or audio;
