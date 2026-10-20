import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/db/database.dart';
import '../domain/dose_schedule.dart';
import '../fhir/bundle_writer.dart';
import '../app/format.dart' show formatCode;
import '../fhir/fhir_common.dart' show fmtNumber;

class PdfFonts {
  const PdfFonts(this.regular, this.bold);

  final pw.Font regular;
  final pw.Font bold;

  static Future<PdfFonts> load() async => PdfFonts(
    pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf')),
    pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf')),
  );
}

final _date = DateFormat('dd.MM.yyyy', 'tr');
final _dateTime = DateFormat('dd.MM.yyyy HH:mm', 'tr');

/// Dışa aktarılan verinin yazdırılabilir, Türkçe/İngilizce başlıklı özeti.
Future<Uint8List> buildSummaryPdf(
  ExportData data,
  PdfFonts fonts, {
  DateTime? now,
}) async {
  final created = now ?? DateTime.now();
  final p = data.profile;
  final doc = pw.Document(
    title: 'Sağlık özeti — ${p.firstName} ${p.lastName}'.trim(),
    author: 'Lokman',
  );
  final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);
  const accent = PdfColor.fromInt(0xFF00696B);

  pw.Widget heading(String tr, String en) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 14, bottom: 6),
    padding: const pw.EdgeInsets.only(bottom: 3),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: accent, width: 1)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          tr,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
            color: accent,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          '/ $en',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  pw.Widget table(List<String> headers, List<List<String>> rows) =>
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        border: null,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          ),
        ),
        cellAlignment: pw.Alignment.centerLeft,
      );

  pw.Widget empty() => pw.Text(
    'Kayıt yok / No information',
    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
  );

  String src(String source, String? origin) => source == RecordSource.self
      ? 'Hasta beyanı / Patient reported'
      : (origin ?? '');

  final activeConditions = data.conditions
      .where((c) => c.status != ConditionStatus.resolved)
      .toList();
  final pastConditions = data.conditions
      .where((c) => c.status == ConditionStatus.resolved)
      .toList();

  final content = <pw.Widget>[
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Sağlık özeti / Patient summary',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          _dateTime.format(created),
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Text(
      '${p.firstName} ${p.lastName}'.trim(),
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    ),
    pw.Text(
      [
        if (p.birthDate != null)
          'Doğum tarihi / Date of birth: ${_date.format(p.birthDate!)}',
        if (p.gender != null)
          'Cinsiyet / Sex: ${switch (p.gender) {
            'female' => 'Kadın / Female',
            _ => 'Erkek / Male',
          }}',
        if (p.bloodType != null) 'Kan grubu / Blood type: ${p.bloodType}',
      ].join('   '),
      style: const pw.TextStyle(fontSize: 10),
    ),
    heading('Alerjiler', 'Allergies'),
    if (data.allergies.isEmpty)
      empty()
    else
      table(
        [
          'Madde / Substance',
          'Tepki / Reaction',
          'Şiddet / Severity',
          'Kaynak / Source',
        ],
        [
          for (final a in data.allergies)
            [
              a.substance,
              a.reaction ?? '',
              switch (a.criticality) {
                'high' => 'Ağır / High',
                'low' => 'Hafif / Low',
                _ => '',
              },
              src(a.source, a.originName),
            ],
        ],
      ),
    heading('Devam eden hastalıklar', 'Problem list'),
    if (activeConditions.isEmpty)
      empty()
    else
      table(
        [
          'Hastalık / Condition',
          'Kod / Code',
          'Başlangıç / Onset',
          'Kaynak / Source',
        ],
        [
          for (final c in activeConditions)
            [
              c.name,
              formatCode(c.code, c.codeSystem) ?? '',
              c.onsetDate == null ? '' : _date.format(c.onsetDate!),
              src(c.source, c.originName),
            ],
        ],
      ),
    if (pastConditions.isNotEmpty) ...[
      heading('Geçirilmiş hastalıklar', 'Past illnesses'),
      table(
        [
          'Hastalık / Condition',
          'Kod / Code',
          'Başlangıç / Onset',
          'Bitiş / Resolved',
          'Kaynak / Source',
        ],
        [
          for (final c in pastConditions)
            [
              c.name,
              formatCode(c.code, c.codeSystem) ?? '',
              c.onsetDate == null ? '' : _date.format(c.onsetDate!),
              c.resolvedDate == null ? '' : _date.format(c.resolvedDate!),
              src(c.source, c.originName),
            ],
        ],
      ),
    ],
    heading('İlaçlar', 'Medications'),
    if (data.medications.isEmpty)
      empty()
    else
      table(
        [
          'İlaç / Medication',
          'Doz / Dose',
          'Saatler / Times',
          'Süre / Period',
          'Durum / Status',
        ],
        [
          for (final m in data.medications)
            [
              m.name,
              [m.dose, m.note].nonNulls.where((s) => s.isNotEmpty).join('\n'),
              DoseTime.parseList(m.timesOfDay).join(', '),
              () {
                final last = lastDay(m);
                return '${_date.format(m.startDate)} – '
                    '${last == null ? 'sürekli / ongoing' : _date.format(last)}';
              }(),
              isCurrent(m, created) ? 'Kullanıyor / Active' : 'Bitti / Ended',
            ],
        ],
      ),
    heading('Aşılar', 'Immunizations'),
    if (data.immunizations.isEmpty)
      empty()
    else
      table(
        ['Aşı / Vaccine', 'Tarih / Date', 'Doz / Dose', 'Kaynak / Source'],
        [
          for (final i in data.immunizations)
            [
              i.vaccineName,
              _date.format(i.date),
              i.doseNumber?.toString() ?? '',
              src(i.source, i.originName),
            ],
        ],
      ),
    if (data.dueVaccines.isNotEmpty) ...[
      heading('Planlanan aşılar', 'Planned immunizations'),
      table(
        ['Aşı / Vaccine', 'Tarih / Due date', 'Doz / Dose', 'Durum / Status'],
        [
          for (final d in data.dueVaccines)
            [
              d.vaccineName,
              _date.format(d.dueDate),
              d.doseNumber?.toString() ?? '',
              d.done ? 'Yapıldı / Done' : 'Bekliyor / Due',
            ],
        ],
      ),
    ],
    if (data.observations.isNotEmpty) ...[
      heading('Ölçümler', 'Measurements'),
      table(
        [
          'Ölçüm / Measurement',
          'Değer / Value',
          'Tarih / Date',
          'Kaynak / Source',
        ],
        [
          for (final o in [
            ...data.observations,
          ]..sort((a, b) => b.effectiveAt.compareTo(a.effectiveAt)))
            [
              o.name,
              o.value == null
                  ? (o.note ?? '')
                  : '${fmtNumber(o.value!)}${o.value2 != null ? '/${fmtNumber(o.value2!)}' : ''} ${o.unit}',
              _dateTime.format(o.effectiveAt),
              src(o.source, o.originName),
            ],
        ],
      ),
    ],
    if (data.encounters.isNotEmpty) ...[
      heading('Muayeneler', 'Encounters'),
      for (final e in [
        ...data.encounters,
      ]..sort((a, b) => b.date.compareTo(a.date)))
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                [
                  _date.format(e.date),
                  e.location ?? e.originName,
                  e.practitioner,
                  if (e.source == RecordSource.self)
                    'Hasta beyanı / Patient reported',
                ].nonNulls.join(' — '),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              if (e.complaint != null)
                pw.Text(
                  'Şikayet / Complaint: ${e.complaint}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if (e.findings != null)
                pw.Text(
                  'Bulgular / Findings: ${e.findings}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              for (final d in data.diagnoses.where(
                (d) => d.encounterId == e.id,
              ))
                pw.Text(
                  'Tanı / Diagnosis: ${d.name}'
                  '${switch (formatCode(d.code, d.codeSystem)) {
                    final code? => ' ($code)',
                    _ => '',
                  }}'
                  '${d.verification == 'provisional' ? ' — ön tanı / provisional' : ''}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if (e.plan != null)
                pw.Text(
                  'Öneriler / Recommendations: ${e.plan}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if (e.note != null)
                pw.Text(
                  'Hasta notu / Patient note: ${e.note}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
        ),
    ],
    if (data.appointments.isNotEmpty) ...[
      heading('Randevular', 'Appointments'),
      table(
        [
          'Tarih / Date',
          'Konu / Description',
          'Hekim / Practitioner',
          'Yer / Location',
        ],
        [
          for (final a in data.appointments)
            [
              _dateTime.format(a.start),
              a.title,
              a.practitioner ?? '',
              a.location ?? '',
            ],
        ],
      ),
    ],
  ];

  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Lokman ile oluşturuldu. Kayıtların bir kısmı hasta beyanıdır. / '
            'Created with Lokman. Some records are patient reported.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
          pw.Text(
            '${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
      build: (_) => content,
    ),
  );
  return doc.save();
}
