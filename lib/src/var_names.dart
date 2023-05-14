class VarNames {
  final String className;
  final String collectionName;

  VarNames(this.className, this.collectionName);

  String get ref => '${className}Ref';
  String get doc => '${className}Doc';
  String get collectionRef => '${className}CollectionRef';

  String get toFirestoreFunc => '_\$${className}ToFirestore';
  String get fromFirestoreFunc => '_\$${className}FromFirestore';

  String get camelCollectionName => snakeToCamel(collectionName);

  static String snakeToCamel(String s) {
    return s.replaceAllMapped(RegExp(r'_(\w)'), (Match m) => m[1]!.toUpperCase());
  }

  static String camelToSnake(String s) {
    return s.replaceAllMapped(RegExp(r'[A-Z]'), (Match m) => '_${m[0]!.toLowerCase()}');
  }
}
