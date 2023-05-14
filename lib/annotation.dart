class FirestoreObject {
  const FirestoreObject(this.collectionName);

  final String? collectionName;
}

class Reference {
  final String className;
  final bool nullable;
  const Reference(this.className, {this.nullable = false});
}

class ReferenceList {
  final String className;
  const ReferenceList(this.className);
}

class DocumentId {
  const DocumentId();
}
