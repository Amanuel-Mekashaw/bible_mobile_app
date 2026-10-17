import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CrossReference {
  final int fromBook;
  final int fromChapter;
  final int fromVerse;
  final int toBook;
  final int toChapterStart;
  final int toVerseStart;
  final int? toChapterEnd;
  final int? toVerseEnd;
  final int votes;

  const CrossReference({
    required this.fromBook,
    required this.fromChapter,
    required this.fromVerse,
    required this.toBook,
    required this.toChapterStart,
    required this.toVerseStart,
    this.toChapterEnd,
    this.toVerseEnd,
    required this.votes,
  });

  bool get isRange =>
      toVerseEnd != null && toVerseEnd != toVerseStart;

  factory CrossReference.fromMap(Map<String, Object?> map) {
    return CrossReference(
      fromBook: map['from_book'] as int,
      fromChapter: map['from_chapter'] as int,
      fromVerse: map['from_verse'] as int,
      toBook: map['to_book'] as int,
      toChapterStart: map['to_chapter_start'] as int,
      toVerseStart: map['to_verse_start'] as int,
      toChapterEnd: map['to_chapter_end'] as int?,
      toVerseEnd: map['to_verse_end'] as int?,
      votes: (map['votes'] as int?) ?? 0,
    );
  }
}

class CrossReferenceRepository {
  static const _assetPath = 'assets/bibledata/cross_refs.db';
  static const _dbName = 'cross_refs.db';

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

    if (!await file.exists()) {
      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, readOnly: true);
    return _db!;
  }

  Future<List<CrossReference>> getReferencesForVerse({
    required int bookNumber,
    required int chapter,
    required int verse,
  }) async {
    try {
      final db = await _getDb();
      final maps = await db.query(
        'cross_refs',
        where: 'from_book = ? AND from_chapter = ? AND from_verse = ?',
        whereArgs: [bookNumber, chapter, verse],
        orderBy: 'votes DESC',
      );
      return maps.map(CrossReference.fromMap).toList();
    } catch (e) {
      debugPrint('[CrossReferenceRepository] error: $e');
      return [];
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

final crossReferenceRepositoryProvider = Provider<CrossReferenceRepository>((ref) {
  final repo = CrossReferenceRepository();
  ref.onDispose(repo.close);
  return repo;
});

typedef VerseRefKey = ({int bookNumber, int chapter, int verse});

final verseCrossReferencesProvider =
    FutureProvider.family<List<CrossReference>, VerseRefKey>((ref, key) async {
  final repo = ref.watch(crossReferenceRepositoryProvider);
  return repo.getReferencesForVerse(
    bookNumber: key.bookNumber,
    chapter: key.chapter,
    verse: key.verse,
  );
});
