import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:serdes_json/serdes_json.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:source_gen/source_gen.dart';

import 'models.dart';
import 'serdes_generator.dart';

class SerdesJsonGenerator extends GeneratorForAnnotation<SerdesJson> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Remove the JsonSerializable annotation from `$name`.',
        element: element,
      );
    }

    final classElement = element;
    final convertToSnakeCase = annotation.read('convertToSnakeCase').literalValue as bool;
    final generateToJson = annotation.read('toJson').literalValue as bool;
    final generateFromJson = annotation.read('fromJson').literalValue as bool;
    final generateToStringJson = annotation.read('toStringJson').literalValue as bool;
    final generateFromStringJson = annotation.read('fromStringJson').literalValue as bool;
    final endsWith = annotation.read('endsWith').literalValue as String;

    var name = classElement.name;

    if (endsWith.isEmpty) {
      throw StateError('endWith can\'t be empty');
    }

    if (name.endsWith(endsWith)) {
      name = name.substring(0, name.length - endsWith.length);
    } else {
      throw StateError('Class name should end with "$endsWith"');
    }

    final fields = classElement.fields.map(
      (field) => Field(
        field.name,
        parseType(field.type.toString()),
      ),
    );

    return SerdesGenerator(
      shouldConvertToSnakeCase: convertToSnakeCase,
      shouldGenerateToJson: generateToJson,
      shouldGenerateFromJson: generateFromJson,
      shouldGenerateToStringJson: generateToStringJson,
      shoudlGenerateFromStringJson: generateFromStringJson,
    ).generateClass(classElement.name, name, fields);
  }
}
