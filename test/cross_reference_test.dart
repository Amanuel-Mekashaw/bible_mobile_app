import 'package:flutter_test/flutter_test.dart';
import 'package:bibleflutter/features/books/data/repositories/cross_reference_repository.dart';

void main() {
  group('CrossReference model test', () {
    test('CrossReference parses map correctly', () {
      final map = {
        'from_book': 1,
        'from_chapter': 1,
        'from_verse': 1,
        'to_book': 58,
        'to_chapter_start': 1,
        'to_verse_start': 1,
        'to_chapter_end': 1,
        'to_verse_end': 3,
        'votes': 344,
      };

      final ref = CrossReference.fromMap(map);
      expect(ref.fromBook, 1);
      expect(ref.fromChapter, 1);
      expect(ref.fromVerse, 1);
      expect(ref.toBook, 58);
      expect(ref.toChapterStart, 1);
      expect(ref.toVerseStart, 1);
      expect(ref.toVerseEnd, 3);
      expect(ref.isRange, isTrue);
      expect(ref.votes, 344);
    });

    test('Single verse cross reference is not range', () {
      final map = {
        'from_book': 1,
        'from_chapter': 1,
        'from_verse': 1,
        'to_book': 28,
        'to_chapter_start': 102,
        'to_verse_start': 25,
        'to_chapter_end': 102,
        'to_verse_end': 25,
        'votes': 62,
      };

      final ref = CrossReference.fromMap(map);
      expect(ref.isRange, isFalse);
    });
  });
}
