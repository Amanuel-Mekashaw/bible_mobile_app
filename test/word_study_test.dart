import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bibleflutter/features/books/data/models/book_index_entry.dart';
import 'package:bibleflutter/features/books/data/repositories/word_study_repository.dart';
import 'package:bibleflutter/features/books/presentation/widgets/reader/word_study_sheet.dart';

void main() {
  group('WordStudy models test', () {
    test('InterlinearWord parses Greek map correctly', () {
      final map = {
        'id': 100,
        'book_number': 58,
        'chapter': 1,
        'verse': 1,
        'word_order': 1,
        'strong_id': 'G3056',
        'original_text': 'λόγος',
        'transliteration': 'lógos',
        'english_gloss': 'Word',
        'amharic_gloss': 'ቃል',
      };

      final word = InterlinearWord.fromMap(map);
      expect(word.id, 100);
      expect(word.bookNumber, 58);
      expect(word.chapter, 1);
      expect(word.verse, 1);
      expect(word.wordOrder, 1);
      expect(word.strongId, 'G3056');
      expect(word.originalText, 'λόγος');
      expect(word.transliteration, 'lógos');
      expect(word.englishGloss, 'Word');
      expect(word.amharicGloss, 'ቃል');
      expect(word.isGreek, isTrue);
      expect(word.isHebrew, isFalse);
    });

    test('InterlinearWord parses Hebrew map correctly', () {
      final map = {
        'id': 1,
        'book_number': 1,
        'chapter': 1,
        'verse': 1,
        'word_order': 1,
        'strong_id': 'H7225',
        'original_text': 'רֵאשִׁית',
        'transliteration': 'rêʼshîyth',
        'english_gloss': 'In the beginning',
        'amharic_gloss': 'መጀመሪያ',
      };

      final word = InterlinearWord.fromMap(map);
      expect(word.strongId, 'H7225');
      expect(word.isHebrew, isTrue);
      expect(word.isGreek, isFalse);
    });

    test('LexiconEntry parses correctly with theological clarification', () {
      final map = {
        'strong_id': 'G3056',
        'language': 'greek',
        'lemma': 'λόγος',
        'transliteration': 'lógos',
        'pronunciation': "lo'-gos",
        'english_definition': 'something said; Divine Expression',
        'kjv_glosses': 'word, speech, matter',
        'amharic_gloss': 'ቃል / አሳብ',
        'amharic_definition': 'መለኮታዊ አሳብ፣ ቃል፣ ምክር',
        'theological_clarification': 'Logos: የተገለጠው መለኮታዊ ቃል',
      };

      final entry = LexiconEntry.fromMap(map);
      expect(entry.strongId, 'G3056');
      expect(entry.language, 'greek');
      expect(entry.lemma, 'λόγος');
      expect(entry.theologicalClarification, 'Logos: የተገለጠው መለኮታዊ ቃል');
      expect(entry.amharicGloss, 'ቃል / አሳብ');
    });
  });

  group('WordStudySheet widget test', () {
    testWidgets('Renders empty state when words list is empty (e.g. Deuterocanonical)', (tester) async {
      const entry = BookIndexEntry(
        bookNumber: 40,
        bookNameAm: 'ጦቢት',
        bookNameEn: 'Tobit',
        bookShortNameAm: 'ጦቢ',
        bookShortNameEn: 'Tob',
        testament: 'old',
        filename: 'tobit.json',
        chapterCount: 14,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            verseInterlinearWordsProvider((
              bookNumber: 40,
              chapter: 1,
              verse: 1,
            )).overrideWith((ref) => Future.value([])),
            bookLanguageProvider(40).overrideWith((ref) => Future.value('geez')),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WordStudySheet(
                sourceEntry: entry,
                sourceChapter: 1,
                sourceVerse: 1,
                isDark: false,
                surfaceColor: Colors.white,
                textColor: Colors.black,
                mutedColor: Colors.grey,
                accentColor: Colors.amber,
                bodyFont: 'Shiromeda',
                useGeez: false,
                isAmharic: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('የመጀመሪያ ቋንቋ ጥናት አልተገኘም'), findsOneWidget);
    });

    testWidgets('Renders interlinear words and theological clarification', (tester) async {
      const entry = BookIndexEntry(
        bookNumber: 58,
        bookNameAm: 'ዮሐንስ',
        bookNameEn: 'John',
        bookShortNameAm: 'ዮሐ',
        bookShortNameEn: 'Jn',
        testament: 'new',
        filename: 'john.json',
        chapterCount: 21,
      );

      const mockWord = InterlinearWord(
        id: 1,
        bookNumber: 58,
        chapter: 1,
        verse: 1,
        wordOrder: 1,
        strongId: 'G3056',
        originalText: 'λόγος',
        transliteration: 'lógos',
        englishGloss: 'Word',
        amharicGloss: 'ቃል',
      );

      const mockLexicon = LexiconEntry(
        strongId: 'G3056',
        language: 'greek',
        lemma: 'λόγος',
        transliteration: 'lógos',
        pronunciation: "lo'-gos",
        englishDefinition: 'the Divine Expression',
        kjvGlosses: 'word, say, preaching',
        theologicalClarification: 'Logos: የተገለጠው መለኮታዊ ቃል',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            verseInterlinearWordsProvider((
              bookNumber: 58,
              chapter: 1,
              verse: 1,
            )).overrideWith((ref) => Future.value([mockWord])),
            lexiconEntryProvider('G3056').overrideWith((ref) => Future.value(mockLexicon)),
            bookLanguageProvider(58).overrideWith((ref) => Future.value('greek')),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WordStudySheet(
                sourceEntry: entry,
                sourceChapter: 1,
                sourceVerse: 1,
                isDark: false,
                surfaceColor: Colors.white,
                textColor: Colors.black,
                mutedColor: Colors.grey,
                accentColor: Colors.amber,
                bodyFont: 'Shiromeda',
                useGeez: false,
                isAmharic: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify original script and English gloss appear
      expect(find.text('λόγος'), findsWidgets);
      expect(find.text('Word'), findsOneWidget);
      expect(find.text('G3056'), findsOneWidget);
      expect(find.text('ሥነ-መለኮታዊ ማብራሪያ'), findsOneWidget);
      expect(find.text('Logos: የተገለጠው መለኮታዊ ቃል'), findsOneWidget);
    });

    testWidgets('Renders Classical Ge\'ez word study card without Strongs', (tester) async {
      const entry = BookIndexEntry(
        bookNumber: 16,
        bookNameAm: 'ሄኖክ',
        bookNameEn: 'Enoch',
        bookShortNameAm: 'ሄኖ',
        bookShortNameEn: 'En',
        testament: 'old',
        filename: 'enoch.json',
        chapterCount: 108,
      );

      const mockGeezWord = InterlinearWord(
        id: 1,
        bookNumber: 16,
        chapter: 1,
        verse: 1,
        wordOrder: 1,
        strongId: null,
        originalText: 'ቃለ',
        transliteration: 'qalä',
        englishGloss: 'words',
        amharicGloss: 'ቃል',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            verseInterlinearWordsProvider((
              bookNumber: 16,
              chapter: 1,
              verse: 1,
            )).overrideWith((ref) => Future.value([mockGeezWord])),
            bookLanguageProvider(16).overrideWith((ref) => Future.value('geez')),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WordStudySheet(
                sourceEntry: entry,
                sourceChapter: 1,
                sourceVerse: 1,
                isDark: false,
                surfaceColor: Colors.white,
                textColor: Colors.black,
                mutedColor: Colors.grey,
                accentColor: Colors.amber,
                bodyFont: 'Shiromeda',
                useGeez: false,
                isAmharic: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ቃለ'), findsWidgets);
      expect(find.text('qalä'), findsWidgets);
      expect(find.text('ግእዝ (የቀደምት አበው)'), findsOneWidget);
      expect(find.text('ግእዝ (ጥንታዊ ጽሑፍ)'), findsOneWidget);
    });
  });
}
