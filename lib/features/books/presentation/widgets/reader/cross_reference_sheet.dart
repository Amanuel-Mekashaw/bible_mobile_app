import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kenat/kenat.dart';

import '../../../../../core/services/repository_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/models/book_index_entry.dart';
import '../../../data/repositories/cross_reference_repository.dart';

class CrossReferenceSheet extends ConsumerStatefulWidget {
  const CrossReferenceSheet({
    super.key,
    required this.sourceEntry,
    required this.sourceChapter,
    required this.sourceVerse,
    required this.isDark,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    required this.bodyFont,
    required this.useGeez,
    required this.isAmharic,
    required this.onNavigate,
  });

  final BookIndexEntry sourceEntry;
  final int sourceChapter;
  final int sourceVerse;
  final bool isDark;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final String bodyFont;
  final bool useGeez;
  final bool isAmharic;
  final void Function(BookIndexEntry targetEntry, int targetChapter, int targetVerse) onNavigate;

  @override
  ConsumerState<CrossReferenceSheet> createState() => _CrossReferenceSheetState();
}

class _CrossReferenceSheetState extends ConsumerState<CrossReferenceSheet> {
  List<BookIndexEntry>? _bookIndex;
  final Map<int, String> _previewCache = {};

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final repo = BibleRepositoryProvider.of(context);
    final idx = await repo.loadIndex();
    if (mounted) {
      setState(() => _bookIndex = idx);
    }
  }

  String _formatNumber(int n) => widget.useGeez ? toGeez(n) : '$n';

  String _formatReference(BookIndexEntry entry, CrossReference ref) {
    final name = widget.isAmharic ? entry.bookNameAm : entry.bookNameEn;
    final ch = _formatNumber(ref.toChapterStart);
    final vStart = _formatNumber(ref.toVerseStart);
    final colon = widget.isAmharic ? '፥' : ':';

    if (ref.isRange) {
      final vEnd = _formatNumber(ref.toVerseEnd!);
      return '$name $ch$colon$vStart-$vEnd';
    }
    return '$name $ch$colon$vStart';
  }

  Future<String?> _loadVersePreview(BookIndexEntry targetEntry, CrossReference ref) async {
    final cacheKey = ref.toBook * 1000000 + ref.toChapterStart * 1000 + ref.toVerseStart;
    if (_previewCache.containsKey(cacheKey)) {
      return _previewCache[cacheKey];
    }

    try {
      final repo = BibleRepositoryProvider.of(context);
      final book = await repo.loadBook(targetEntry);
      final ch = book.chapters.cast<dynamic>().firstWhere(
            (c) => c.chapterNumber == ref.toChapterStart,
            orElse: () => null,
          );
      if (ch == null) return null;

      final verses = ch.allVerses as List<dynamic>;
      String preview;
      if (ref.isRange) {
        final sub = verses.where(
          (v) => v.verseNumber >= ref.toVerseStart && v.verseNumber <= ref.toVerseEnd!,
        );
        if (sub.isEmpty) return null;
        preview = sub.map((v) => '${v.verseNumber}. ${v.text}').join(' ');
      } else {
        final found = verses.cast<dynamic>().firstWhere(
              (v) => v.verseNumber == ref.toVerseStart,
              orElse: () => null,
            );
        if (found == null) return null;
        preview = found.text as String;
      }

      _previewCache[cacheKey] = preview;
      return preview;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceName = widget.isAmharic
        ? widget.sourceEntry.bookNameAm
        : widget.sourceEntry.bookNameEn;
    final sourceCh = _formatNumber(widget.sourceChapter);
    final sourceV = _formatNumber(widget.sourceVerse);
    final colon = widget.isAmharic ? '፥' : ':';
    final sourceBadge = '$sourceName $sourceCh$colon$sourceV';

    final refKey = (
      bookNumber: widget.sourceEntry.bookNumber,
      chapter: widget.sourceChapter,
      verse: widget.sourceVerse,
    );
    final refsAsync = ref.watch(verseCrossReferencesProvider(refKey));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: widget.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.mutedColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    sourceBadge,
                    style: TextStyle(
                      fontFamily: AppTypography.nokiaPureheadline,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isAmharic ? 'አመሳክሮሽ' : 'Cross References',
                  style: TextStyle(
                    fontFamily: AppTypography.shiromeda,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: widget.mutedColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: widget.mutedColor.withValues(alpha: 0.15),
          ),

          // Body
          Expanded(
            child: refsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: widget.accentColor,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.isAmharic
                        ? 'አመሳክሮሽ መጫን አልተቻለም'
                        : 'Failed to load cross references',
                    style: TextStyle(color: widget.mutedColor),
                  ),
                ),
              ),
              data: (references) {
                if (references.isEmpty || _bookIndex == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 48,
                            color: widget.mutedColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isAmharic
                                ? 'ለዚህ ጥቅስ ምንም አመሳክሮሽ አልተገኘም'
                                : 'No cross references found for this verse',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: references.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final refItem = references[idx];
                    final targetEntry = _bookIndex!.where(
                          (b) => b.bookNumber == refItem.toBook,
                        ).firstOrNull;

                    if (targetEntry == null) return const SizedBox.shrink();

                    final refTitle = _formatReference(targetEntry, refItem);

                    return Material(
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.parchment.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNavigate(
                            targetEntry,
                            refItem.toChapterStart,
                            refItem.toVerseStart,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      refTitle,
                                      style: TextStyle(
                                        fontFamily: AppTypography.shiromeda,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: widget.accentColor,
                                      ),
                                    ),
                                  ),
                                  if (refItem.votes > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.accentColor.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.thumb_up_alt_outlined,
                                            size: 11,
                                            color: widget.mutedColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${refItem.votes}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: widget.mutedColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: widget.mutedColor.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FutureBuilder<String?>(
                                future: _loadVersePreview(targetEntry, refItem),
                                builder: (context, snapshot) {
                                  final text = snapshot.data;
                                  if (text == null || text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: widget.bodyFont,
                                      fontSize: 13,
                                      height: 1.5,
                                      color: widget.textColor.withValues(alpha: 0.85),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
