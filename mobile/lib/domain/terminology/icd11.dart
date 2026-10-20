/// ICD-11 MMS kataloğu: uygulamanın içine gömülü terminoloji paketini okur ve
/// Türkçe arama yapar. Paket `terminology/build.py` ile üretilir; uygulama
/// çalışırken internete çıkmaz, paket yalnızca uygulama güncellemesiyle
/// yenilenir (bkz. docs/TERMINOLOJI.md).
library;

import 'dart:typed_data';

/// Uygulamaya gömülü terminoloji paketi dosyaları. Sürüm adı dosya adında
/// geçer; `terminology/build.py` buradaki [release] ile aynı olmasını kontrol
/// eder.
abstract final class Icd11Asset {
  static const release = '2025-01';
  static const catalog = 'assets/terminology/icd11-mms-$release.tsv';
  static const icd10Map = 'assets/terminology/icd10-icd11-$release.tsv';
}

/// Türkçe harfleri sadeleştiren eşleme. `terminology/build.py` içindeki
/// `FOLD` ile birebir aynı olmalı: paketteki arama metni orada üretiliyor.
const _fold = {
  'ç': 'c',
  'Ç': 'c',
  'ğ': 'g',
  'Ğ': 'g',
  'ı': 'i',
  'İ': 'i',
  'ö': 'o',
  'Ö': 'o',
  'ş': 's',
  'Ş': 's',
  'ü': 'u',
  'Ü': 'u',
  'â': 'a',
  'Â': 'a',
  'ê': 'e',
  'î': 'i',
  'Î': 'i',
  'ô': 'o',
  'û': 'u',
  'Û': 'u',
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'à': 'a',
  'è': 'e',
  'ä': 'a',
  'ë': 'e',
  'ï': 'i',
  'ñ': 'n',
  'å': 'a',
  'æ': 'a',
  'ø': 'o',
  'œ': 'o',
  'ß': 's',
};

/// Küçük harfli, Türkçe harfleri sadeleştirilmiş arama metni. Nokta silinir
/// (`BA00.0` → `ba000`), harf ve rakam dışındaki her şey boşluğa döner.
String normalizeTerm(String input) {
  final out = StringBuffer();
  var space = false;
  for (final rune in input.runes) {
    var ch = String.fromCharCode(rune);
    ch = _fold[ch] ?? ch;
    ch = ch.toLowerCase();
    ch = _fold[ch] ?? ch;
    final unit = ch.length == 1 ? ch.codeUnitAt(0) : -1;
    final alnum =
        unit >= 0 &&
        ((unit >= 0x61 && unit <= 0x7a) || (unit >= 0x30 && unit <= 0x39));
    if (alnum) {
      if (space && out.isNotEmpty) out.write(' ');
      space = false;
      out.write(ch);
    } else if (ch != '.') {
      space = true;
    }
  }
  return out.toString();
}

/// Katalogdaki bir kategori (ICD-11 MMS "stem" kodu).
class Icd11Concept {
  const Icd11Concept({
    required this.code,
    required this.titleTr,
    required this.titleEn,
    required this.chapter,
    required this.icd10,
    required this.residual,
  });

  /// ICD-11 MMS kodu, ör. `BA00`, `5A11`, `FA80.9`.
  final String code;
  final String titleTr;

  /// İngilizce ad; Türkçesiyle aynıysa (ya da Türkçesi yoksa) boş.
  final String titleEn;
  final String chapter;

  /// WHO eşleme tablosundaki ICD-10 karşılığı; aralık (`J09-J18`) ya da bölüm
  /// (`IX`) olabilir, bunlar ICD-10 kodu değildir. Yoksa boş.
  final String icd10;

  /// "Diğer" / "tanımlanmamış" kategorisi mi (aramada geriye atılır).
  final bool residual;

  /// Kullanıcıya gösterilen ad.
  String get title => titleTr;

  @override
  String toString() => '$code $titleTr';
}

/// Aramada bulunan satır ve sıralama ölçütleri.
class _Hit {
  _Hit(this.line, this.tier, this.flags, this.titleLength);
  final int line;
  int tier;

  /// Satırın işaretleri: `r` kalıntı kategori, `s` tanı olmayan bölüm.
  final String flags;
  final int titleLength;

  int get secondary => flags.contains('s') ? 1 : 0;
  int get residual => flags.contains('r') ? 1 : 0;
}

/// Pakete gömülü ICD-11 MMS kategorileri.
///
/// Paket iki ayrı metin olarak tutulur: [_terms] yalnızca arama karşılıklarını
/// taşır ve saf ASCII'dir (Dart bunu tek baytlık dizge olarak tutar, tarama
/// iki katından fazla hızlanır), [_rows] ise gösterilecek alanları taşır.
/// İki metnin satırları aynı sırada; [_termStarts] ve [_rowStarts] hizalıdır.
class Icd11Catalog {
  Icd11Catalog._(
    this._terms,
    this._termStarts,
    this._rows,
    this._rowStarts,
    this._icd10Map,
    this.release,
    this.sourceVersion,
    this.chapters,
  );

  /// Satır satır arama karşılıkları; karşılıklar `|` ile ayrılır.
  final String _terms;
  final Uint32List _termStarts;

  /// Satır satır `kod<TAB>Türkçe ad<TAB>İngilizce ad<TAB>bölüm<TAB>ICD-10<TAB>kalıntı`.
  final String _rows;
  final Uint32List _rowStarts;

  /// `ICD-10 kodu<TAB>ICD-11 kodu` satırları; boş olabilir.
  final String _icd10Map;

  /// Paketin ICD-11 sürümü, ör. `2025-01`.
  final String release;

  /// WHO dosyasının sürüm damgası.
  final String sourceVersion;

  /// Bölüm numarası → bölüm adı.
  final Map<String, String> chapters;

  int get length => _termStarts.length;

  /// Paket metnini ayrıştırır. [icd10Map] verilirse ICD-10 koduyla arama ve
  /// dışarıdan gelen ICD-10 kodunun karşılığını bulma çalışır.
  static Icd11Catalog parse(String text, {String icd10Map = ''}) {
    final terms = StringBuffer();
    final rows = StringBuffer();
    final termStarts = <int>[];
    final rowStarts = <int>[];
    final chapters = <String, String>{};
    var termLength = 0;
    var rowLength = 0;
    var release = '';
    var sourceVersion = '';

    var i = 0;
    while (i < text.length) {
      var end = text.indexOf('\n', i);
      if (end < 0) end = text.length;
      if (end > i) {
        if (text.codeUnitAt(i) == 0x23) {
          final parts = text.substring(i, end).split('\t');
          if (parts.first == '#lokman-terminoloji' && parts.length >= 5) {
            release = parts[2];
            sourceVersion = parts[4];
          } else if (parts.first == '#bolum' && parts.length >= 3) {
            chapters[parts[1]] = parts[2];
          }
        } else {
          final tab = text.indexOf('\t', i);
          if (tab >= 0 && tab < end) {
            termStarts.add(termLength);
            terms
              ..write(text.substring(i, tab))
              ..write('\n');
            termLength += tab - i + 1;
            rowStarts.add(rowLength);
            rows
              ..write(text.substring(tab + 1, end))
              ..write('\n');
            rowLength += end - tab;
          }
        }
      }
      i = end + 1;
    }

    return Icd11Catalog._(
      terms.toString(),
      Uint32List.fromList(termStarts),
      rows.toString(),
      Uint32List.fromList(rowStarts),
      icd10Map,
      release,
      sourceVersion,
      chapters,
    );
  }

  /// [query] ile eşleşen kategoriler, en uygunu başta.
  ///
  /// Sıralama: tam eşleşme → baştan eşleşme → kelime başı → içinde geçen;
  /// eşitlikte "diğer / tanımlanmamış" kategoriler ve uzun adlar geriye gider.
  /// Sorgu bir ICD-10 kodu gibi görünüyorsa karşılığı en başa eklenir.
  List<Icd11Concept> search(String query, {int limit = 25}) {
    final q = normalizeTerm(query);
    if (q.length < 2) return const [];

    final hits = <_Hit>[];
    var from = 0;
    while (hits.length < _maxHits) {
      final at = _terms.indexOf(q, from);
      if (at < 0) break;
      final line = _lineAt(_termStarts, at);
      final lineStart = _termStarts[line];
      final lineEnd = line + 1 < _termStarts.length
          ? _termStarts[line + 1] - 1
          : _terms.length;
      var tier = _tier(at, q.length, lineStart, lineEnd);
      // Aynı satırda başka karşılıklar da eşleşebilir; en iyi dereceyi tut.
      var next = at + q.length;
      while (tier > 1 && next < lineEnd) {
        final again = _terms.indexOf(q, next);
        if (again < 0 || again >= lineEnd) break;
        final other = _tier(again, q.length, lineStart, lineEnd);
        if (other < tier) tier = other;
        next = again + q.length;
      }
      hits.add(_Hit(line, tier, _flags(line), _titleLength(line)));
      from = lineEnd + 1;
    }

    hits.sort((a, b) {
      final t = a.tier.compareTo(b.tier);
      if (t != 0) return t;
      // Tanının kendisi olmayan bölümler (dış nedenler, sağlık hizmetiyle
      // temas) ve "diğer / tanımlanmamış" kategoriler geriye gider.
      final s = a.secondary.compareTo(b.secondary);
      if (s != 0) return s;
      final r = a.residual.compareTo(b.residual);
      if (r != 0) return r;
      final l = a.titleLength.compareTo(b.titleLength);
      if (l != 0) return l;
      return a.line.compareTo(b.line);
    });

    final result = <Icd11Concept>[];
    final seen = <String>{};
    final mapped = byIcd10(query);
    if (mapped != null) {
      result.add(mapped);
      seen.add(mapped.code);
    }
    for (final hit in hits) {
      if (result.length >= limit) break;
      final concept = _concept(hit.line);
      if (seen.add(concept.code)) result.add(concept);
    }
    return result;
  }

  /// Verilen ICD-11 koduna karşılık gelen kategori.
  Icd11Concept? byCode(String code) {
    final wanted = code.trim().toUpperCase();
    if (wanted.isEmpty) return null;
    if (_rows.startsWith('$wanted\t')) return _concept(0);
    final at = _rows.indexOf('\n$wanted\t');
    if (at < 0) return null;
    return _concept(_lineAt(_rowStarts, at + 1));
  }

  /// Adı, İngilizce adı ya da bir eş anlamlısı [term]'e birebir eşit olan
  /// kategori. Birden çok kategori eşleşirse `null` döner: hangisi olduğundan
  /// emin olunamayan kayda kod yazılmaz.
  Icd11Concept? byExactTerm(String term) {
    final q = normalizeTerm(term);
    if (q.isEmpty) return null;
    Icd11Concept? found;
    for (final pattern in ['\n$q\n', '\n$q|', '|$q|', '|$q\n']) {
      var from = 0;
      while (true) {
        final at = _terms.indexOf(pattern, from);
        if (at < 0) break;
        from = at + 1;
        final concept = _concept(_lineAt(_termStarts, at + 1));
        if (found == null) {
          found = concept;
        } else if (found.code != concept.code) {
          return null;
        }
      }
    }
    // İlk satır `\n` ile başlamadığı için ayrıca denenir.
    if (_terms.startsWith('$q|') || _terms.startsWith('$q\n')) {
      final first = _concept(0);
      if (found != null && found.code != first.code) return null;
      found = first;
    }
    return found;
  }

  /// WHO eşleme tablosuna göre bir ICD-10 kodunun ICD-11 karşılığı.
  Icd11Concept? byIcd10(String icd10) {
    if (_icd10Map.isEmpty) return null;
    // Dosyada kodlar noktalı yazılı: `N18.1`. Sorguyu her iki biçimde dener.
    for (final candidate in _icd10Candidates(icd10)) {
      final at = _icd10Map.indexOf('\n$candidate\t');
      if (at < 0) continue;
      var end = _icd10Map.indexOf('\n', at + 1);
      if (end < 0) end = _icd10Map.length;
      return byCode(_icd10Map.substring(at + 1, end).split('\t')[1]);
    }
    return null;
  }

  String? chapterName(String no) => chapters[no];

  // ------------------------------------------------------------ iç yardımcılar

  static const _maxHits = 2000;

  /// `at` konumundaki eşleşmenin derecesi; küçük olan daha iyi.
  int _tier(int at, int length, int lineStart, int lineEnd) {
    var altStart = lineStart;
    for (var i = at - 1; i >= lineStart; i--) {
      if (_terms.codeUnitAt(i) == 0x7c) {
        altStart = i + 1;
        break;
      }
    }
    var altEnd = _terms.indexOf('|', at);
    if (altEnd < 0 || altEnd > lineEnd) altEnd = lineEnd;
    final end = at + length;
    if (altStart == at && altEnd == end) return 1;
    if (altStart == at) return 2;
    return _terms.codeUnitAt(at - 1) == 0x20 ? 3 : 4;
  }

  /// `offset` konumunun hangi satırda olduğunu bulur (satır başlangıçları
  /// artan sırada olduğu için ikili arama).
  int _lineAt(Uint32List starts, int offset) {
    var low = 0;
    var high = starts.length - 1;
    while (low < high) {
      final mid = (low + high + 1) >> 1;
      if (starts[mid] <= offset) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low;
  }

  int _rowEnd(int line) =>
      line + 1 < _rowStarts.length ? _rowStarts[line + 1] - 1 : _rows.length;

  /// Türkçe adın uzunluğu: kısa ad genel kategori demektir, aramada öne gelir.
  int _titleLength(int line) {
    final start = _rowStarts[line];
    final code = _rows.indexOf('\t', start);
    final title = _rows.indexOf('\t', code + 1);
    return title - code - 1;
  }

  /// Son sütundaki işaretler (`r`, `s`); yoksa boş.
  String _flags(int line) {
    final end = _rowEnd(line);
    final tab = _rows.lastIndexOf('\t', end);
    return tab < _rowStarts[line] ? '' : _rows.substring(tab + 1, end);
  }

  Icd11Concept _concept(int line) {
    final f = _rows.substring(_rowStarts[line], _rowEnd(line)).split('\t');
    return Icd11Concept(
      code: f[0],
      titleTr: f[1],
      titleEn: f[2],
      chapter: f[3],
      icd10: f[4],
      residual: f.length > 5 && f[5].contains('r'),
    );
  }

  /// `I10`, `i10`, `N18.1` gibi yazımları dosyadaki biçime çevirir.
  Iterable<String> _icd10Candidates(String input) {
    final raw = input.trim().toUpperCase().replaceAll(' ', '');
    if (!RegExp(r'^[A-Z]\d{2}(\.?\d{1,2})?$').hasMatch(raw)) return const [];
    if (raw.contains('.')) return [raw];
    if (raw.length <= 3) return [raw];
    return ['${raw.substring(0, 3)}.${raw.substring(3)}', raw];
  }
}
