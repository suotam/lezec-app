import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_routes/domain/grade_conversion.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';

RouteGrade grade(GradingSystem system, String value) =>
    RouteGrade(system: system, value: value);

void main() {
  group('convertGrade', () {
    test('converts between route systems from table anchors', () {
      expect(
        convertGrade(grade(GradingSystem.french, '6b+'), GradingSystem.uiaa),
        'VII',
      );
      expect(
        convertGrade(
          grade(GradingSystem.czechSandstone, 'VIIb'),
          GradingSystem.french,
        ),
        '5c',
      );
      expect(
        convertGrade(grade(GradingSystem.uiaa, 'IX'), GradingSystem.french),
        '7c',
      );
      expect(
        convertGrade(grade(GradingSystem.french, '8a'), GradingSystem.yds),
        '5.13a',
      );
    });

    test('converts between boulder systems', () {
      expect(
        convertGrade(
          grade(GradingSystem.fontainebleau, '6C'),
          GradingSystem.vScale,
        ),
        'V5',
      );
      expect(
        convertGrade(
          grade(GradingSystem.vScale, 'V8'),
          GradingSystem.fontainebleau,
        ),
        '7B',
      );
    });

    test('refuses cross-category conversion', () {
      expect(
        convertGrade(
          grade(GradingSystem.fontainebleau, '7A'),
          GradingSystem.uiaa,
        ),
        isNull,
      );
      expect(
        convertGrade(grade(GradingSystem.french, '7a'), GradingSystem.vScale),
        isNull,
      );
    });

    test('same system returns null (nothing to convert)', () {
      expect(
        convertGrade(grade(GradingSystem.french, '6a'), GradingSystem.french),
        isNull,
      );
    });

    test('values between anchors snap to the nearest row', () {
      // Saxon VIIIa sits in the table; VII- (UIAA) does too — pick one
      // that is genuinely off-table for UIAA:
      expect(
        convertGrade(grade(GradingSystem.uiaa, 'VIIIa'), GradingSystem.french),
        isNotNull,
      );
    });

    test('garbage grades convert to nothing', () {
      expect(
        convertGrade(grade(GradingSystem.french, '??'), GradingSystem.uiaa),
        isNull,
      );
    });

    test('conversion is roughly symmetric', () {
      final toUiaa = convertGrade(
        grade(GradingSystem.french, '7a'),
        GradingSystem.uiaa,
      );
      final back = convertGrade(
        grade(GradingSystem.uiaa, toUiaa!),
        GradingSystem.french,
      );
      expect(back, '7a');
    });
  });
}
