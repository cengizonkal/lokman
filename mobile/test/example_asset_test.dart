import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  test('uygulamadaki örnek dosya depodaki örnekle aynı', () {
    expect(
      File('assets/examples/klinik-cikti-ayse.json').readAsStringSync(),
      exampleBundle(),
      reason:
          'fhir/examples dosyasını mobile/assets/examples altına kopyalayın',
    );
  });
}
