// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_obj/annotation.dart';

part 'main.g.dart';

@FirestoreObject('users')
class User {
  @DocumentId()
  String id;
  String name;

  User({required this.name, required this.id});
}

@FirestoreObject('units')
class Unit {
  @DocumentId()
  String id;
  String name;

  @Reference('User', nullable: true)
  UserRef? user;
  @Reference('User')
  List<UserRef> users;

  Unit({required this.name, this.user, required this.id, required this.users});
}
