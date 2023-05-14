// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// MainGenerator
// **************************************************************************

typedef UserDoc = DocumentSnapshot<User>;
typedef UserRef = DocumentReference<User>;
typedef UserCollectionRef = CollectionReference<User>;

final UserCollectionRef usersCollection =
    FirebaseFirestore.instance.collection('users').withConverter<User>(
          fromFirestore: _$UserFromFirestore,
          toFirestore: _$UserToFirestore,
        );

Map<String, dynamic> _$UserToFirestore(User instance, _) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

User _$UserFromFirestore(doc, _) {
  final data = doc.data()!;
  return User(
    id: doc.id,
    name: data['name'],
  );
}

typedef UnitDoc = DocumentSnapshot<Unit>;
typedef UnitRef = DocumentReference<Unit>;
typedef UnitCollectionRef = CollectionReference<Unit>;

final UnitCollectionRef unitsCollection =
    FirebaseFirestore.instance.collection('units').withConverter<Unit>(
          fromFirestore: _$UnitFromFirestore,
          toFirestore: _$UnitToFirestore,
        );

Map<String, dynamic> _$UnitToFirestore(Unit instance, _) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user': instance.user,
      'users': instance.users,
    };

Unit _$UnitFromFirestore(doc, _) {
  final data = doc.data()!;
  return Unit(
    id: doc.id,
    name: data['name'],
    user: data['user'] == null
        ? null
        : (data['user'] as DocumentReference).withConverter<User>(
            toFirestore: _$UserToFirestore,
            fromFirestore: _$UserFromFirestore,
          ),
    users:
        (data['users'] as List).cast<DocumentReference>().map<UserRef>((unit) {
      return unit.withConverter<User>(
        toFirestore: _$UserToFirestore,
        fromFirestore: _$UserFromFirestore,
      );
    }).toList(),
  );
}
