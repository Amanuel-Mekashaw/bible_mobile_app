# Attributions & Data Sources

This project brings together ancient biblical texts, lexical references, and cross-reference datasets to serve the 81-book canon of the **Ethiopian Orthodox Tewahedo Church (EOTC)**. We gratefully acknowledge and credit the following open-source initiatives, scholars, digitized manuscript archives, and repositories whose contributions made this offline study edition possible.

---

## 1. Cross-Reference Dataset

### **Treasury of Scripture Knowledge (TSK) / OpenScriptures**
- **Repository**: [`openscriptures/cross-references`](https://github.com/openscriptures/cross-references)
- **Source Compilation**: Originally compiled by Thomas Scott and John Canne, and expanded by R. A. Torrey (*The Treasury of Scripture Knowledge*).
- **Description**: Over 340,000 comprehensive scripture-to-scripture cross-reference links establishing semantic and theological connections across the biblical text.
- **Project Adaptation**: The raw Protestant 66-book reference IDs were harmonized, filtered, and re-mapped to align accurately with the 81-book Ethiopian Orthodox canon, ensuring bidirectional verse linking and eliminating indicator false positives for verses without active connections.
- **License**: Public Domain.

---

## 2. Original Biblical Languages & Interlinear Corpora

### **A. Protestant Canon Interlinear (Hebrew OT & Greek NT)**
- **Repository**: [`tahmmee/interlinear_bibledata`](https://github.com/tahmmee/interlinear_bibledata)
- **Primary Source Texts**:
  - **Old Testament**: Westminster Leningrad Codex (WLC) Hebrew Masoretic Text.
  - **New Testament**: Scrivener's Textus Receptus (1894) and Westcott-Hort (1881) Greek New Testament.
- **Description**: Word-by-word tokenized, vocalized text with embedded Strong's Concordance numbering (`H...` for Hebrew, `G...` for Greek), English glosses, and grammatical order.
- **License**: MIT / Public Domain sources.

---

### **B. Septuagint (LXX) Greek Deuterocanonical Corpus**
- **Repository**: [`eliranwong/LXX-Rahlfs-1935`](https://github.com/eliranwong/LXX-Rahlfs-1935)
- **Curator & Maintainer**: Eliran Wong
- **Foundational Source**: Derived from the **Computer Assisted Tools for Septuagint Studies (CATSS)** project conducted at the University of Pennsylvania, directed by Prof. Robert A. Kraft and Prof. Emanuel Tov.
- **Underlying Text**: Alfred Rahlfs' landmark critical edition (*Septuaginta: id est Vetus Testamentum Graece iuxta LXX interpretes*, 1935).
- **Books Integrated into EOTC Canon**:
  1. **1 Esdras / 2nd Ezra** (መጽሐፈ ዕዝራ ካልእ) — Book 20 (`LXX 165 / 1Esdr`)
  2. **Book of Tobit** (መጽሐፈ ጦቢት) — Book 21 (`LXX 170 / TobBA`)
  3. **Book of Judith** (መጽሐፈ ዮዲት) — Book 22 (`LXX 180 / Jdt`)
  4. **Wisdom of Solomon** (መጽሐፈ ጥበብ) — Book 31 (`LXX 270 / Wis`)
  5. **Sirach / Ecclesiasticus** (መጽሐፈ ሲራክ) — Book 34 (`LXX 280 / Sir`)
  6. **Book of Baruch** (መጽሐፈ ባሮክ) — Book 37 (`LXX 320 / Bar`)
  7. **Epistle of Jeremiah** (ተረፈ ኤርምያስ) — Book 39 (`LXX 315 / EpJer`)
- **Key Feature**: Each word contains morphological tags and standard Strong's Greek numbers (`G...`), allowing seamless integration with our offline Strong's lexicon and word-study sheet.
- **License**: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International ([CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)).

---

### **C. Classical Ge'ez Canonical Corpus**
- **Repository**: [`cpradmin/ethiopian-bible`](https://github.com/cpradmin/ethiopian-bible)
- **Maintainer**: `cpradmin` & Ethiopian Digital Heritage Contributors
- **Description**: Digitized Classical Ge'ez (*ግእዝ*) canonical texts preserved uniquely in the manuscript tradition of the Ethiopian Orthodox Tewahedo Church.
- **Books Integrated into EOTC Canon**:
  1. **Book of Jubilees** (መጽሐፈ ኩፋሌ) — Book 15 (`chapters/Jub`)
  2. **1 Enoch** (መጽሐፈ ሄኖክ) — Book 16 (`chapters/1En`)
  3. **Apocalypse of Ezra / 4 Ezra** (መጽሐፈ ዕዝራ ሱቱኤል) — Book 19 (`chapters/ApEz`)
  4. **1 Meqabyan** (መጽሐፈ መቃብያን ቀዳማዊ) — Book 24 (`chapters/1Meq`)
  5. **2 Meqabyan** (መጽሐፈ መቃብያን ካልእ) — Book 25 (`chapters/2Meq`)
  6. **3 Meqabyan** (መጽሐፈ መቃብያን ሣልስ) — Book 26 (`chapters/3Meq`)
  7. **Book of Admonition / Teachings** (መጽሐፈ ተግሣጽ) — Book 30 (`chapters/Teach`)
  8. **4 Baruch / Paralipomena of Jeremiah** (ተረፈ ባሮክ) — Book 40 (`chapters/4Bar`)
- **Key Feature**: Provides authentic Ethiopic letterings (*ፊደል*), academic Romanized phonological transliterations, and contextual translation references for ancient Semitic study.
- **License**: MIT License / Open Ethiopic Literary Heritage.

---

## 3. Lexicons & Strong's Dictionaries

### **OpenScriptures Strong's Greek & Hebrew Dictionaries**
- **Repository**: [`openscriptures/strongs`](https://github.com/openscriptures/strongs)
- **Source Compilation**: Dr. James Strong's Exhaustive Concordance of the Bible (1890), modernized and digitized by the OpenScriptures project with lexical updates, phonetic pronunciations, and root derivations.
- **Datasets Used**:
  - `strongs-greek-dictionary.js`: 5,523 Greek lexical entries covering Biblical and Septuagint Greek lemmas.
  - `strongs-hebrew-dictionary.js`: 8,674 Hebrew and Aramaic lexical entries with vocalization and King James Version translation glosses.
- **License**: Public Domain / Creative Commons Attribution-ShareAlike ([CC BY-SA](https://creativecommons.org/licenses/by-sa/4.0/)).

---

## 4. Theological Clarifications & Amharic Lexical Alignments

### **Ethiopian Orthodox Theological Clarifications**
- **Developed for**: EOTC Open Source Bible Project
- **Purpose**: Clarifying nuances between Hebrew, Greek, and modern Amharic biblical terminology to resolve doctrinal and semantic confusions that often arise in contemporary translations.
- **Coverage**:
  - **Greek Nuances**: Disambiguation of *Logos* (ቃል / መለኮታዊ አሳብ - John 1), *Agape* vs. *Phileo* (መለኮታዊ መስዋዕታዊ ፍቅር vs. የወንድማማች ፍቅር), *Metanoia* (የልብና የአእምሮ ለውጥ ከስሜታዊ ጸጸት የተለየ), *Pneuma* (መንፈስ / ሕያው እስትንፋስ), *Charis* (መለኮታዊ ጸጋ / ነጻ ስጦታ), *Dikaiosyne* (ጽድቅና ቅድስና), *Hades* vs. *Gehenna* (የሙታን ማረፊያ/መቃብር vs. የዘላለም ቅጣት).
  - **Hebrew Nuances**: Disambiguation of *Elohim* (አምላክ ፈጣሪ) vs. *YHWH* (ዘላለማዊው የቃል ኪዳን ስም), *Bara* (ከምንም ወደ መኖር የማምጣት መለኮታዊ ሥራ), *Hesed* (የኪዳን ጽኑ ፍቅርና ምሕረት), *Ruach* (ሕይወት ሰጪ እስትንፋስና መንፈስ ቅዱስ), *Berit* (ጽኑ ቃል ኪዳን), *Sheol* (የሙታን ዓለም).
  - **Classical Ge'ez Roots**: Direct Ethiopic root glosses connecting ancient Ge'ez terms (*ቃለ*, *በረከት*, *ጽድቅ*, *ኪዳን*, *መንፈስ*, *ቅዱስ*, *ወልድ*, *አብ*, *ጥበብ*) to their contextual Amharic equivalents.

---

## Summary of Combined Coverage

| Category | Source Repositories | Books Covered | Total Verses | Total Words |
| :--- | :--- | :--- | :--- | :--- |
| **Old Testament (Masoretic)** | `tahmmee/interlinear_bibledata` | 39 Books | 23,086 | 306,478 |
| **New Testament (Greek)** | `tahmmee/interlinear_bibledata` | 27 Books | 7,945 | 138,025 |
| **Greek Septuagint (LXX)** | `eliranwong/LXX-Rahlfs-1935` | 7 Books | 3,038 | 53,201 |
| **Classical Ge'ez (Ancient)** | `cpradmin/ethiopian-bible` | 8 Books | 4,269 | 73,937 |
| **Cross References** | `openscriptures/cross-references` | All 81 Books | 340,000+ links | — |
| **Combined EOTC Canon** | **All Above Sources** | **All 81 Books** | **38,338 Verses** | **571,641 Words** |
