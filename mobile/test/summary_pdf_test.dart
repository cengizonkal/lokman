import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lokman/data/db/database.dart';
import 'package:lokman/fhir/bundle_writer.dart';
import 'package:lokman/pdf/summary_pdf.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('tr'));

  test('devam eden ve geçirilmiş hastalıklarla PDF özet üretilir', () async {
    final repo = memoryRepo();
    addTearDown(repo.db.close);
    final id = await repo.addProfile(
      ProfilesCompanion.insert(firstName: 'Ali'),
    );
    await repo.save(
      repo.db.conditions,
      ConditionsCompanion.insert(profileId: id, name: 'Astım'),
    );
    await repo.save(
      repo.db.conditions,
      ConditionsCompanion.insert(
        profileId: id,
        name: 'Su çiçeği',
        status: const Value(ConditionStatus.resolved),
        resolvedDate: Value(DateTime(1995, 4, 1)),
      ),
    );

    final pdf = await buildSummaryPdf(
      await ExportData.load(repo.db, id),
      await PdfFonts.load(),
    );
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
  });
}
