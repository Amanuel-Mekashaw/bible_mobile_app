import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kenat/kenat.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../data/models/book_index_entry.dart';
import '../../../data/repositories/word_study_repository.dart';

class WordStudySheet extends ConsumerStatefulWidget {
  const WordStudySheet({
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

  @override
  ConsumerState<WordStudySheet> createState() => _WordStudySheetState();
}

class _WordStudySheetState extends ConsumerState<WordStudySheet> {
  InterlinearWord? _selectedWord;

  String _formatNumber(int n) => widget.useGeez ? toGeez(n) : '$n';

  @override
  Widget build(BuildContext context) {
    final bookName = widget.isAmharic ? widget.sourceEntry.bookNameAm : widget.sourceEntry.bookNameEn;
    final chStr = _formatNumber(widget.sourceChapter);
    final vStr = _formatNumber(widget.sourceVerse);
    final colon = widget.isAmharic ? '፥' : ':';
    final sourceBadge = '$bookName $chStr$colon$vStr';

    final isNewTestament = widget.sourceEntry.bookNumber >= 55;
    final languageName = isNewTestament
        ? (widget.isAmharic ? 'ግሪክ (አዲስ ኪዳን)' : 'Greek (NT)')
        : (widget.isAmharic ? 'ዕብራይስጥ (ብሉይ ኪዳን)' : 'Hebrew (OT)');

    final wordsAsync = ref.watch(verseInterlinearWordsProvider((
      bookNumber: widget.sourceEntry.bookNumber,
      chapter: widget.sourceChapter,
      verse: widget.sourceVerse,
    )));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
          const SizedBox(height: 14),

          // Header
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    languageName,
                    style: TextStyle(
                      fontFamily: widget.bodyFont,
                      fontSize: 12,
                      color: widget.mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: widget.mutedColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.isAmharic ? 'የቃላትና የቋንቋ ንጽጽር' : 'Interlinear Word Study',
              style: TextStyle(
                fontFamily: AppTypography.nokiaPureheadline,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: widget.mutedColor.withValues(alpha: 0.15)),

          // Body
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error: $err',
                    style: TextStyle(color: widget.mutedColor),
                  ),
                ),
              ),
              data: (words) {
                if (words.isEmpty) {
                  return _buildDeuterocanonicalEmptyState();
                }

                final selected = _selectedWord ?? words.firstWhere(
                  (w) => (w.strongId?.isNotEmpty ?? false),
                  orElse: () => words.first,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitle instructions
                      Text(
                        widget.isAmharic
                            ? 'በቁጥሩ ውስጥ ያለ ማንኛውንም ቃል በመንካት የመጀመሪያውን ትርጉም ይመልከቱ፦'
                            : 'Tap any word to view its original definition & theological note:',
                        style: TextStyle(
                          fontFamily: widget.bodyFont,
                          fontSize: 12,
                          color: widget.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Interlinear horizontal words carousel/wrap
                      _buildWordChipsList(words, selected),

                      const SizedBox(height: 16),
                      Divider(height: 1, color: widget.mutedColor.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),

                      // Lexicon Detail Card for selected word
                      _buildLexiconDetailCard(selected),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeuterocanonicalEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 40,
                color: widget.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isAmharic
                  ? 'የመጀመሪያ ቋንቋ ጥናት አልተገኘም'
                  : 'Original Language Corpus Not Available',
              style: TextStyle(
                fontFamily: AppTypography.nokiaPureheadline,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.isAmharic
                  ? 'ይህ መጽሐፍ በዕብራይስጥ (ብሉይ) ወይም በግሪክ (አዲስ) የቃላት ዝርዝር ውስጥ አልተካተተም። የቃላት ጥናቱ ለ66ቱ ቀኖናዊ መጻሕፍት የተዘጋጀ ነው።'
                  : 'Original language interlinear data is available for canonical Old (Hebrew) and New (Greek) Testament books.',
              style: TextStyle(
                fontFamily: widget.bodyFont,
                fontSize: 13,
                height: 1.45,
                color: widget.mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordChipsList(List<InterlinearWord> words, InterlinearWord selected) {
    final isHebrew = words.isNotEmpty && words.first.isHebrew;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: isHebrew, // Scroll naturally RTL for Hebrew
      child: Row(
        children: words.map((w) {
          final isSelected = (w.wordOrder == selected.wordOrder);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWord = w;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: const BoxConstraints(minWidth: 70),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.accentColor.withValues(alpha: widget.isDark ? 0.25 : 0.12)
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? widget.accentColor
                      : widget.mutedColor.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Original Script
                  Text(
                    w.originalText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? widget.accentColor : widget.textColor,
                    ),
                    textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  const SizedBox(height: 2),
                  // Transliteration
                  Text(
                    w.transliteration,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: widget.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // English Gloss
                  Text(
                    w.englishGloss.isEmpty ? '—' : w.englishGloss,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor.withValues(alpha: 0.9),
                    ),
                  ),
                  // Amharic Gloss if exists
                  if (w.amharicGloss != null && w.amharicGloss!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        w.amharicGloss!,
                        style: TextStyle(
                          fontFamily: widget.bodyFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.accentColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLexiconDetailCard(InterlinearWord word) {
    if (word.strongId == null || word.strongId!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          widget.isAmharic
              ? 'ለዚህ ቃል የተለየ የስትሮንግ ቁጥር አልተገኘም።'
              : 'No Strong\'s entry assigned for this word particle.',
          style: TextStyle(fontFamily: widget.bodyFont, color: widget.mutedColor),
        ),
      );
    }

    final entryAsync = ref.watch(lexiconEntryProvider(word.strongId!));

    return entryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => Text('Lexicon Error: $e', style: TextStyle(color: widget.mutedColor)),
      data: (entry) {
        if (entry == null) {
          return Text(
            widget.isAmharic ? 'የቃሉ ፍቺ አልተገኘም።' : 'No lexicon definition found.',
            style: TextStyle(color: widget.mutedColor),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.mutedColor.withValues(alpha: 0.18),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Word Top Row: Lemma + Strong ID badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.lemma.isNotEmpty ? entry.lemma : word.originalText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor,
                          ),
                          textDirection: entry.language == 'hebrew' ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        if (entry.transliteration.isNotEmpty)
                          Text(
                            entry.transliteration,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: widget.accentColor,
                            ),
                          ),
                        if (entry.pronunciation.isNotEmpty)
                          Text(
                            entry.pronunciation,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.mutedColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      entry.strongId,
                      style: TextStyle(
                        fontFamily: AppTypography.nokiaPureheadline,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Theological Clarification Banner (if present)
              if (entry.theologicalClarification != null && entry.theologicalClarification!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: widget.isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 6),
                          Text(
                            widget.isAmharic ? 'ሥነ-መለኮታዊ ማብራሪያ' : 'Theological Clarification',
                            style: TextStyle(
                              fontFamily: widget.bodyFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark ? const Color(0xFFF3D270) : const Color(0xFF8C6B00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.theologicalClarification!,
                        style: TextStyle(
                          fontFamily: widget.bodyFont,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Amharic Definition / Gloss
              if (entry.amharicDefinition != null && entry.amharicDefinition!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildSectionHeader(widget.isAmharic ? 'የአማርኛ ትርጉም' : 'Amharic Meaning'),
                const SizedBox(height: 4),
                Text(
                  entry.amharicDefinition!,
                  style: TextStyle(
                    fontFamily: widget.bodyFont,
                    fontSize: 13,
                    height: 1.4,
                    color: widget.textColor,
                  ),
                ),
              ],

              // English Definition
              if (entry.englishDefinition.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildSectionHeader(widget.isAmharic ? 'የመጀመሪያ ቋንቋ ፍቺ' : 'Definition'),
                const SizedBox(height: 4),
                Text(
                  entry.englishDefinition,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: widget.textColor.withValues(alpha: 0.9),
                  ),
                ),
              ],

              // KJV Glosses / Usages
              if (entry.kjvGlosses.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSectionHeader(widget.isAmharic ? 'የትርጉም አጠቃቀም' : 'Translation Usages'),
                const SizedBox(height: 4),
                Text(
                  entry.kjvGlosses,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: widget.mutedColor,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: widget.bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: widget.accentColor,
      ),
    );
  }
}
