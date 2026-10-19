import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bibleflutter/core/annotations/annotation_models.dart';
import 'package:bibleflutter/core/theme/app_typography.dart';
import 'package:bibleflutter/features/books/data/models/book.dart';
import 'package:bibleflutter/features/books/data/repositories/cross_reference_repository.dart';
import 'package:bibleflutter/features/books/presentation/widgets/reader/chapter_page.dart';
import 'package:bibleflutter/features/books/presentation/widgets/reader/constants.dart';

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

    test('readerFonts and readerFontNames include Noto Sans Ethiopic', () {
      expect(readerFonts.contains(AppTypography.notoSansEthiopic), isTrue);
      expect(readerFontNames.contains('ኖቶ ሳንስ'), isTrue);
      expect(readerFonts.length, readerFontNames.length);
    });

    testWidgets('Only verses in crossRefVerseNums render the asterisk indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionView(
              section: const Section(
                title: '',
                verses: [
                  Verse(verseNumber: 1, text: 'Verse with ref'),
                  Verse(verseNumber: 2, text: 'Verse without ref'),
                ],
              ),
              secIdx: 0,
              chapter: const Chapter(chapterNumber: 1, sections: []),
              fontSize: 16,
              fontFamily: 'Shiromeda',
              titleFontFamily: 'Shiromeda',
              textColor: Colors.black,
              accentColor: Colors.amber,
              isDark: false,
              useGeez: false,
              isSelectedFn: (_, _, _) => false,
              onVerseTap: (_) {},
              verseKeyFn: (_, _, _) => '',
              annotations: ChapterAnnotations.empty,
              crossRefVerseNums: const {1}, // Only verse 1 has ref
            ),
          ),
        ),
      );

      // Verify that '*' appears exactly once (for verse 1, NOT for verse 2)
      final asteriskFinder = find.text('*');
      expect(asteriskFinder, findsOneWidget);
    });
  });
}
