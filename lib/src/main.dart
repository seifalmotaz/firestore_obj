import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:firestore_obj/annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'var_names.dart';

class MainGenerator extends GeneratorForAnnotation<FirestoreObject> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    element as ClassElement;

    final buf = StringBuffer();
    final className = element.name;
    final collectionName = annotation.read('collectionName').stringValue;
    final varNames = VarNames(className, collectionName);

    buf.writeln("typedef ${varNames.doc} = DocumentSnapshot<$className>;");
    buf.writeln("typedef ${varNames.ref} = DocumentReference<$className>;");
    buf.writeln("typedef ${varNames.collectionRef} = CollectionReference<$className>;");

    buf.writeln('');
    buf.writeln('');

    buf.writeln(
        'final ${varNames.collectionRef} ${varNames.camelCollectionName}Collection = FirebaseFirestore.instance');
    buf.writeln('.collection(\'$collectionName\')');
    buf.writeln('.withConverter<$className>(');
    buf.writeln('fromFirestore: ${varNames.fromFirestoreFunc},');
    buf.writeln('toFirestore: ${varNames.toFirestoreFunc},');
    buf.writeln(');');

    buf.writeln('');
    buf.writeln('');

    buf.writeln('Map<String, dynamic> ${varNames.toFirestoreFunc}($className instance, _) => <String, dynamic>{');
    for (final field in element.fields) {
      if (field.isStatic || field.isLate) continue;
      final fieldName = field.name;
      final snakeFieldName = VarNames.camelToSnake(fieldName);
      buf.writeln("'$snakeFieldName': instance.$fieldName,");
    }
    buf.writeln('};');

    buf.writeln('');
    buf.writeln('');

    buf.writeln('$className ${varNames.fromFirestoreFunc}(doc, _) {');
    buf.writeln('final data = doc.data()!;');
    buf.writeln('return $className(');
    for (final field in element.fields) {
      if (field.isStatic || field.isLate) continue;
      final fieldName = field.name;
      final snakeFieldName = VarNames.camelToSnake(fieldName);
      final fieldMetadata = field.metadata;

      final docIdField = fieldMetadata.where((element) => element.element?.displayName == 'DocumentId');
      if (docIdField.isNotEmpty) {
        buf.writeln("$fieldName: doc.id,");
        continue;
      }

      final referenceField = fieldMetadata.where((element) => element.element?.displayName == 'Reference');
      if (referenceField.isNotEmpty) {
        final referenceClassName = referenceField.first.computeConstantValue()!.getField('className')!.toStringValue();
        final canBeNull = referenceField.first.computeConstantValue()!.getField('nullable')?.toBoolValue() ?? false;
        final isList = field.type.isDartCoreList;
        if (isList) {
          buf.writeln("""$fieldName: (data['$fieldName'] as List).cast<DocumentReference${canBeNull ? '?' : ''}>()
              .map<${referenceClassName}Ref>((unit) {
                return unit.withConverter<$referenceClassName>(
                  toFirestore: _\$${referenceClassName}ToFirestore,
                  fromFirestore: _\$${referenceClassName}FromFirestore,
                );
              }).toList(),""");
          continue;
        }
        if (canBeNull) {
          buf.writeln("""$fieldName: data['$snakeFieldName'] == null ?
              null :
              (data['$fieldName'] as DocumentReference)
              .withConverter<$referenceClassName>(
                toFirestore: _\$${referenceClassName}ToFirestore,
                fromFirestore: _\$${referenceClassName}FromFirestore,
              ),""");
        } else {
          buf.writeln("""$fieldName: (data['$fieldName'] as DocumentReference)
              .withConverter<$referenceClassName>(
                toFirestore: _\$${referenceClassName}ToFirestore,
                fromFirestore: _\$${referenceClassName}FromFirestore,
              ),""");
        }
        continue;
      }

      ////////
      buf.writeln("$fieldName: data['$snakeFieldName'],");
    }
    buf.writeln(');');
    buf.writeln('}');

    return buf.toString();
  }
}
