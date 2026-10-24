import 'package:flutter_test/flutter_test.dart';
import 'package:rediary4/quote.dart';

void main() {
  group('Quote.fromJson', () {
    test('reads quote text and author from API response', () {
      final quote = Quote.fromJson({
        'quote': 'The journey is the destination.',
        'author': 'Dan Eldon',
      });

      expect(quote.text, 'The journey is the destination.');
      expect(quote.author, 'Dan Eldon');
    });

    test('uses safe defaults when optional fields are missing', () {
      final quote = Quote.fromJson({});

      expect(quote.text, isEmpty);
      expect(quote.author, 'ไม่ทราบ');
    });
  });
}
