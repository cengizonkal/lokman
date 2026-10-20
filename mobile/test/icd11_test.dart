import 'package:flutter_test/flutter_test.dart';
import 'package:lokman/domain/terminology/icd11.dart';

import 'test_utils.dart';

void main() {
  late Icd11Catalog catalog;

  setUpAll(() {
    catalog = Icd11Catalog.parse(
      terminologyAsset('icd11-mms-2025-01.tsv'),
      icd10Map: terminologyAsset('icd10-icd11-2025-01.tsv'),
    );
  });

  group('arama metni', () {
    test('Türkçe harfleri sadeleştirir, noktayı atar', () {
      expect(normalizeTerm('Şeker Hastalığı'), 'seker hastaligi');
      expect(normalizeTerm('BA00.0'), 'ba000');
      expect(normalizeTerm('  İNME '), 'inme');
      expect(
        normalizeTerm('Tip 2 diabetes mellitus'),
        'tip 2 diabetes mellitus',
      );
      expect(normalizeTerm('—'), '');
    });
  });

  group('katalog', () {
    test('paket başlığı ve bölümler okunur', () {
      expect(catalog.release, '2025-01');
      expect(catalog.sourceVersion, isNotEmpty);
      expect(catalog.length, greaterThan(17000));
      expect(catalog.chapterName('11'), 'Dolaşım Sistemi Hastalıkları');
      // Uzatma kodları ve ek bölümler pakete girmez.
      expect(catalog.chapters.containsKey('X'), isFalse);
      expect(catalog.chapters.containsKey('V'), isFalse);
      expect(catalog.chapters.containsKey('26'), isFalse);
    });

    test('kodla bulur', () {
      final c = catalog.byCode('BA00')!;
      expect(c.titleTr, 'Esansiyel Hipertansiyon');
      expect(c.titleEn, 'Essential hypertension');
      expect(c.chapter, '11');
      expect(c.icd10, 'I10');
      expect(c.residual, isFalse);
      expect(catalog.byCode('ba00')!.code, 'BA00');
      expect(catalog.byCode('YOK00'), isNull);
    });

    test('resmî Türkçe adla arar', () {
      expect(catalog.search('esansiyel hipertansiyon').first.code, 'BA00');
      expect(catalog.search('tip 2 diabetes').first.code, '5A11');
      expect(catalog.search('romatoid artrit').first.code, 'FA20');
    });

    test('halk dili eş anlamlısıyla arar', () {
      expect(catalog.search('yüksek tansiyon').first.code, 'BA00');
      expect(catalog.search('şeker hastalığı').first.code, '5A11');
      expect(catalog.search('grip').first.code, '1E32');
      expect(catalog.search('zatürre').first.code, 'CA40');
      expect(catalog.search('kalp krizi').first.code, 'BA41');
      expect(catalog.search('verem').first.code, '1B10');
      expect(catalog.search('bel fıtığı').first.code, 'FA80.9');
      expect(catalog.search('basur').first.code, 'DB60');
    });

    test('eş anlamlı, resmî adın yanlış dalını geçer', () {
      // "Hipertansiyon" düz metin olarak önce gebelik ve korku kodlarında
      // geçiyor; eş anlamlı sayesinde esansiyel hipertansiyon başa gelir.
      expect(catalog.search('hipertansiyon').first.code, 'BA00');
      expect(catalog.search('astım').first.code, 'CA23');
    });

    test('ICD-11 koduyla arar', () {
      expect(catalog.search('BA00').first.code, 'BA00');
      expect(catalog.search('5A11').first.code, '5A11');
      expect(catalog.search('ba00.0').first.code, 'BA00.0');
    });

    test('ICD-10 koduyla arar (WHO eşleme tablosu)', () {
      expect(catalog.byIcd10('I10')!.code, 'BA00.Z');
      expect(catalog.byIcd10('N18.1')!.code, 'GB61.0');
      expect(catalog.byIcd10('J45')!.code, startsWith('CA23'));
      expect(catalog.byIcd10('i10')!.code, 'BA00.Z');
      expect(catalog.byIcd10('ZZZ'), isNull);
      expect(catalog.byIcd10('zatürre'), isNull);
      // Arama da ICD-10 kodunu tanır: karşılık en başa eklenir.
      expect(catalog.search('I10').first.code, 'BA00.Z');
    });

    test('"diğer / tanımlanmamış" kategoriler sonuçlarda geriye gider', () {
      final hits = catalog.search('romatoid artrit');
      expect(hits.first.residual, isFalse);
      expect(hits.map((c) => c.code), contains('FA20.Z'));
      expect(hits.indexWhere((c) => c.code == 'FA20.Z'), greaterThan(0));
    });

    test('tanı olmayan bölümler kısmi aramada geriye gider', () {
      // QB25 "Kalp donörü" 24. bölümdedir (sağlık hizmetiyle temas);
      // "kalp" yazan hastaya önce hastalıklar gösterilmeli.
      final hits = catalog.search('kalp', limit: 10);
      expect(hits.first.code, isNot('QB25'));
      // Tam yazılırsa yine bulunur.
      expect(catalog.search('kalp donörü').first.code, 'QB25');
    });

    test('tam karşılık tek kategoriye düşüyorsa bulunur', () {
      expect(catalog.byExactTerm('Astım')!.code, 'CA23');
      expect(catalog.byExactTerm('yüksek tansiyon')!.code, 'BA00');
      expect(catalog.byExactTerm('ESANSİYEL HİPERTANSİYON')!.code, 'BA00');
      expect(catalog.byExactTerm('Essential hypertension')!.code, 'BA00');
      // İlk satır da bulunur (dosya başı ayrı ele alınıyor).
      expect(catalog.byExactTerm('Kolera')!.code, '1A00');
      expect(catalog.byExactTerm('böyle bir hastalık yok'), isNull);
      expect(catalog.byExactTerm(''), isNull);
      // Birden çok kategoriye eşleşen ad: emin olunamaz, kod yazılmaz.
      // ("Demir eksikliği" hem 3A00 anemisinin eş anlamlısı hem 5B5K.0'ın adı.)
      expect(catalog.byExactTerm('demir eksikliği'), isNull);
      expect(catalog.search('demir eksikliği').length, greaterThan(1));
    });

    test('kısa ve boş sorgu sonuç vermez', () {
      expect(catalog.search(''), isEmpty);
      expect(catalog.search('a'), isEmpty);
      expect(catalog.search('   '), isEmpty);
    });

    test('bulunamayan sorgu boş döner', () {
      expect(catalog.search('böyle bir hastalık yok'), isEmpty);
    });

    test('sonuç sayısı sınırlanır ve tekrarsızdır', () {
      final hits = catalog.search('enfeksiyon', limit: 10);
      expect(hits, hasLength(10));
      expect(hits.map((c) => c.code).toSet(), hasLength(10));
    });

    test('her kategoride kod ve Türkçe ad vardır', () {
      // Paket bütünlüğü: ayrıştırma sırasında sütun kayması olmadığını
      // (ör. adın içinde sekme) yakalar.
      for (final code in ['1A00', 'CA23', 'FA80.9', 'RA01', 'MB48.0']) {
        final c = catalog.byCode(code)!;
        expect(c.code, code);
        expect(c.titleTr, isNotEmpty);
        expect(c.chapter, isNotEmpty);
      }
    });
  });
}
