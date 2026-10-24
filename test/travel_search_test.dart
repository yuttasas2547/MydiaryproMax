import 'package:flutter_test/flutter_test.dart';
import 'package:rediary4/travel_widgets.dart';

void main() {
  group('matchesTravelSearch', () {
    test('matches a word in any trip field', () {
      expect(
        matchesTravelSearch([
          'ญี่ปุ่น',
          'โตเกียวและเกียวโต',
          'ตื่นเต้น',
        ], 'เกียวโต'),
        isTrue,
      );
    });

    test('ignores letter case and surrounding spaces', () {
      expect(matchesTravelSearch(['Japan'], '  JAPAN  '), isTrue);
    });

    test('matches all trips when the query is empty', () {
      expect(matchesTravelSearch(['ญี่ปุ่น', null], '  '), isTrue);
    });

    test('does not match when the query is absent', () {
      expect(matchesTravelSearch(['ญี่ปุ่น', 'โตเกียว'], 'ปารีส'), isFalse);
    });
  });
}
