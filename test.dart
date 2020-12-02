import 'dart:io';

import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Person {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  List<String> friends;

  @override
  String toString() {
    return '$name:--> $age';
  }
}

void main() async {
  var path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter(PersonAdapter());

  var box = await Hive.openBox('testBox');

  var person = Person()
    ..name = 'Dave'
    ..age = 22
    ..friends = ['Linda', 'Marc', 'Anne'];

  await box.put('dave', person);
  await box.put('test', "Taur");

  print((box.get('dave') as Person).friends); // D
  print(box.length); // dave: 22
  print(box.keys); // dave: 22
  print(box.path); // dave: 22
  print(box.name); // dave: 22
  print(box.values); // dave: 22
}

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final typeId = 1;

  @override
  Person read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person()
      ..name = fields[0] as String
      ..age = fields[1] as int
      ..friends = (fields[2] as List)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.friends);
  }
}
