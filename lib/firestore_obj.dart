import 'package:build/build.dart';
import 'package:firestore_obj/src/main.dart';
import 'package:source_gen/source_gen.dart';

Builder converters(BuilderOptions options) => SharedPartBuilder([MainGenerator()], 'converters');
