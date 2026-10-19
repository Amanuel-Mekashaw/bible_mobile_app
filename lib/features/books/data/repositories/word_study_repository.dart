import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InterlinearWord {
  final int id;
  final int bookNumber;
  final int chapter;
  final int verse;
  final int wordOrder;
  final String? strongId;
  final String originalText;
  final String transliteration;
  final String englishGloss;
  final String? amharicGloss;

  const InterlinearWord({
    required this.id,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.wordOrder,
    this.strongId,
    required this.originalText,
    required this.transliteration,
    required this.englishGloss,
    this.amharicGloss,
  });

  bool get isHebrew => strongId?.startsWith('H') ?? false;
  bool get isGreek => strongId?.startsWith('G') ?? false;

  factory InterlinearWord.fromMap(Map<String, Object?> map) {
    return InterlinearWord(
      id: (map['id'] as int?) ?? 0,
      bookNumber: (map['book_number'] as int?) ?? 0,
      chapter: (map['chapter'] as int?) ?? 0,
      verse: (map['verse'] as int?) ?? 0,
      wordOrder: (map['word_order'] as int?) ?? 0,
      strongId: map['strong_id'] as String?,
      originalText: (map['original_text'] as String?) ?? '',
      transliteration: (map['transliteration'] as String?) ?? '',
      englishGloss: (map['english_gloss'] as String?) ?? '',
      amharicGloss: map['amharic_gloss'] as String?,
    );
  }
}

class LexiconEntry {
  final String strongId;
  final String language;
  final String lemma;
  final String transliteration;
  final String pronunciation;
  final String englishDefinition;
  final String kjvGlosses;
  final String? amharicGloss;
  final String? amharicDefinition;
  final String? theologicalClarification;

  const LexiconEntry({
    required this.strongId,
    required this.language,
    required this.lemma,
    required this.transliteration,
    required this.pronunciation,
    required this.englishDefinition,
    required this.kjvGlosses,
    this.amharicGloss,
    this.amharicDefinition,
    this.theologicalClarification,
  });

  factory LexiconEntry.fromMap(Map<String, Object?> map) {
    return LexiconEntry(
      strongId: (map['strong_id'] as String?) ?? '',
      language: (map['language'] as String?) ?? '',
      lemma: (map['lemma'] as String?) ?? '',
      transliteration: (map['transliteration'] as String?) ?? '',
      pronunciation: (map['pronunciation'] as String?) ?? '',
      englishDefinition: (map['english_definition'] as String?) ?? '',
      kjvGlosses: (map['kjv_glosses'] as String?) ?? '',
      amharicGloss: map['amharic_gloss'] as String?,
      amharicDefinition: map['amharic_definition'] as String?,
      theologicalClarification: map['theological_clarification'] as String?,
    );
  }
}

class WordStudyRepository {
  static const _assetPath = 'assets/bibledata/original_languages.db';
  static const _dbName = 'original_languages.db';

  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, _dbName);
    final file = File(dbPath);

    final data = await rootBundle.load(_assetPath);
    final assetLength = data.lengthInBytes;
    if (!await file.exists() || await file.length() != assetLength) {
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, readOnly: true);
    return _db!;
  }

  Future<String> getBookLanguage(int bookNumber) async {
    try {
      final db = await _getDb();
      final res = await db.query(
        'books',
        columns: ['language'],
        where: 'book_number = ?',
        whereArgs: [bookNumber],
        limit: 1,
      );
      if (res.isNotEmpty) {
        return (res.first['language'] as String?) ?? (bookNumber >= 55 ? 'greek' : 'hebrew');
      }
      return bookNumber >= 55 ? 'greek' : 'hebrew';
    } catch (e) {
      debugPrint('[WordStudyRepository] getBookLanguage error: $e');
      return bookNumber >= 55 ? 'greek' : 'hebrew';
    }
  }

  Future<bool> hasCorpusForBook(int bookNumber) async {
    try {
      final db = await _getDb();
      final res = await db.query(
        'books',
        columns: ['has_corpus'],
        where: 'book_number = ?',
        whereArgs: [bookNumber],
        limit: 1,
      );
      if (res.isNotEmpty) {
        return (res.first['has_corpus'] as int?) == 1;
      }
      return false;
    } catch (e) {
      debugPrint('[WordStudyRepository] hasCorpusForBook error: $e');
      return false;
    }
  }

  Future<List<InterlinearWord>> getInterlinearWords({
    required int bookNumber,
    required int chapter,
    required int verse,
  }) async {
    try {
      final db = await _getDb();
      final maps = await db.query(
        'interlinear_words',
        where: 'book_number = ? AND chapter = ? AND verse = ?',
        whereArgs: [bookNumber, chapter, verse],
        orderBy: 'word_order ASC',
      );
      return maps.map(InterlinearWord.fromMap).toList();
    } catch (e) {
      debugPrint('[WordStudyRepository] getInterlinearWords error: $e');
      return [];
    }
  }

  Future<LexiconEntry?> getLexiconEntry(String strongId) async {
    try {
      final db = await _getDb();
      final maps = await db.query(
        'lexicon',
        where: 'strong_id = ?',
        whereArgs: [strongId.trim().toUpperCase()],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return LexiconEntry.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('[WordStudyRepository] getLexiconEntry error: $e');
      return null;
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

final wordStudyRepositoryProvider = Provider<WordStudyRepository>((ref) {
  final repo = WordStudyRepository();
  ref.onDispose(repo.close);
  return repo;
});

typedef VerseRefKey = ({int bookNumber, int chapter, int verse});

final verseInterlinearWordsProvider =
    FutureProvider.family<List<InterlinearWord>, VerseRefKey>((ref, key) async {
  final repo = ref.watch(wordStudyRepositoryProvider);
  return repo.getInterlinearWords(
    bookNumber: key.bookNumber,
    chapter: key.chapter,
    verse: key.verse,
  );
});

final lexiconEntryProvider =
    FutureProvider.family<LexiconEntry?, String>((ref, strongId) async {
  final repo = ref.watch(wordStudyRepositoryProvider);
  return repo.getLexiconEntry(strongId);
});

final bookHasCorpusProvider =
    FutureProvider.family<bool, int>((ref, bookNumber) async {
  final repo = ref.watch(wordStudyRepositoryProvider);
  return repo.hasCorpusForBook(bookNumber);
});

final bookLanguageProvider =
    FutureProvider.family<String, int>((ref, bookNumber) async {
  final repo = ref.watch(wordStudyRepositoryProvider);
  return repo.getBookLanguage(bookNumber);
});
