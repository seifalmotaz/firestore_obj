import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'annotation.dart';

Builder converters(BuilderOptions options) => SharedPartBuilder([ConvertersGen()], 'converters');

// function to to convert snake case to camel case
String snakeToCamel(String s) {
  return s.replaceAllMapped(RegExp(r'_(\w)'), (Match m) => m[1]!.toUpperCase());
}

// function to to convert camel case to snake case
String camelToSnake(String s) {
  return s.replaceAllMapped(RegExp(r'[A-Z]'), (Match m) => '_${m[0]!.toLowerCase()}');
}

class ConvertersGen extends GeneratorForAnnotation<FirestoreObject> {
  String className = '';
  String collectionName = '';
  String collectionClassName = '';
  //
  String toMapFuncName = '';
  String fromMapFuncName = '';
  //
  String refName = '';
  String collectionRefTypeName = '';
  //
  String docTypeName = '';
  String docRefTypeName = '';

  void naming(ClassElement e, ConstantReader annotation) {
    className = e.name;
    collectionName = annotation.read('collectionName').stringValue;
    collectionClassName = snakeToCamel(collectionName);
    collectionClassName = collectionClassName[0].toUpperCase() + collectionClassName.substring(1);
    //
    toMapFuncName = '_\$${className}ToFirestore';
    fromMapFuncName = '_\$${className}FromFirestore';
    //
    refName = '${collectionClassName[0].toLowerCase() + collectionClassName.substring(1)}Ref';
    collectionRefTypeName = '${collectionClassName}Ref';
    //
    docTypeName = '${className}Doc';
    docRefTypeName = '${className}Ref';
  }

  String writeTypes(ClassElement e, ConstantReader annotation) {
    final buf = StringBuffer();

    buf.writeln("typedef $collectionRefTypeName = CollectionReference<$className>;");
    buf.writeln("typedef $docTypeName = DocumentSnapshot<$className>;");
    buf.writeln("typedef $docRefTypeName = DocumentReference<$className>;");
    return buf.toString();
  }

  String writeToMapFunc(ClassElement e) {
    final buf = StringBuffer();
    buf.writeln('Map<String, dynamic> $toMapFuncName($className instance, _) => <String, dynamic>{');
    for (final field in e.fields) {
      buf.writeln("'${camelToSnake(field.name)}': instance.${field.name},");
    }
    buf.writeln('};');
    return buf.toString();
  }

  String writeFromMapFunc(ClassElement e) {
    final buf = StringBuffer();
    buf.writeln('${e.name} $fromMapFuncName(snapshot, _) => $className(');
    for (final field in e.constructors.first.parameters) {
      String fieldName = camelToSnake(field.name);
      String fieldGetterVar = 'snapshot["$fieldName"]';
      if (field.metadata.isNotEmpty) {
        final annotation = field.metadata.first;
        final annotationElement = annotation.element!;
        fieldGetterVar = 'snapshot["$fieldName"]';
        if (annotationElement.displayName == 'ReferenceList') {
          final className = annotation.computeConstantValue()!.getField('className')!.toStringValue();
          fieldGetterVar = """(snapshot['$fieldName'] as List).cast<DocumentReference>()
              .map<${className}Ref>((unit) {
                return unit.withConverter<$className>(
                  toFirestore: _\$${className}ToFirestore,
                  fromFirestore: _\$${className}FromFirestore,
                );
              }).toList()""";
        } else if (annotation.element!.displayName == 'Reference') {
          var dartObject = annotation.computeConstantValue()!;
          final canBeNull = dartObject.getField('canBeNull')!.toBoolValue()!;
          final className = dartObject.getField('className')!.toStringValue();
          fieldGetterVar =
              """(snapshot['$fieldName'] as DocumentReference${canBeNull ? '?' : ''})${canBeNull ? '?' : ''}.withConverter<$className>(
                toFirestore: _\$${className}ToFirestore,
                fromFirestore: _\$${className}FromFirestore,
              )""";
        }
      }
      if (field.isNamed) {
        buf.writeln('${field.name}: $fieldGetterVar,');
      } else {
        buf.writeln('$fieldGetterVar,');
      }
    }
    buf.writeln(');');
    return buf.toString();
  }

  String writeRef(ClassElement e) {
    final buf = StringBuffer();
    buf.writeln('final $collectionRefTypeName $refName = FirebaseFirestore.instance');
    buf.writeln('.collection(\'$collectionName\')');
    buf.writeln('.withConverter<$className>(');
    buf.writeln('fromFirestore: $fromMapFuncName,');
    buf.writeln('toFirestore: $toMapFuncName,');
    buf.writeln(');');
    return buf.toString();
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    element as ClassElement;
    final buf = StringBuffer();
    naming(element, annotation);
    buf.writeln(writeTypes(element, annotation));
    buf.writeln(writeToMapFunc(element));
    buf.writeln(writeFromMapFunc(element));
    buf.writeln(writeRef(element));
    return buf.toString();
  }
}
