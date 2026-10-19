import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../fhir/bundle_reader.dart';
import '../../fhir/importer.dart';
import '../../widgets/common.dart';

const kindLabels = {
  RecordKind.medication: 'ilaç',
  RecordKind.immunization: 'aşı',
  RecordKind.dueVaccine: 'planlanan aşı',
  RecordKind.allergy: 'alerji',
  RecordKind.condition: 'kronik hastalık',
  RecordKind.observation: 'ölçüm',
  RecordKind.appointment: 'randevu',
  RecordKind.encounter: 'muayene',
  RecordKind.diagnosis: 'tanı',
};

String describeCounts(Map<RecordKind, int> counts) => [
  for (final k in RecordKind.values)
    if ((counts[k] ?? 0) > 0) '${counts[k]} ${kindLabels[k]}',
].join(', ');

/// Dosya ya da QR'dan gelen sağlık dosyasını içe aktarır: ayrıştırır, kime
/// ait olduğunu sorar (gerekirse), kaydeder ve sonucu gösterir.
Future<void> runImport(BuildContext context, WidgetRef ref, String text) async {
  final importer = ref.read(importerProvider);
  final ParsedBundle bundle;
  try {
    bundle = await importer.parse(text);
  } on BundleFormatException catch (e) {
    if (context.mounted) await _error(context, e.message);
    return;
  }
  if (!context.mounted) return;
  if (bundle.records.isEmpty) {
    await _error(context, 'Dosyada aktarılacak sağlık kaydı bulunamadı.');
    return;
  }

  final match = await importer.match(bundle.patient);
  if (!context.mounted) return;
  String? profileId;
  if (match.exact != null) {
    final ok = await confirm(
      context,
      title: '${profileName(match.exact!)} profiline aktarılsın mı?',
      message:
          '${bundle.organizationName ?? 'Dosya'}: '
          '${describeCounts(bundle.counts)}.\n\nDaha önce aktarılan kayıtlar '
          'güncellenir, çoğalmaz.',
      action: 'Aktar',
      destructive: false,
    );
    if (!ok) return;
    profileId = match.exact!.id;
  } else {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _WhoseFile(bundle: bundle, match: match),
    );
    if (choice == null) return;
    profileId = choice == _newProfile
        ? await importer.createProfileFrom(bundle.patient)
        : choice;
  }

  final result = await importer.apply(bundle, profileId);
  await selectProfile(ref, profileId);
  await rescheduleNotifications(ref);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.check_circle, size: 48),
      title: const Text('Aktarım tamamlandı'),
      content: Text(
        [
          describeCounts(result.counts),
          if (result.updated > 0 && result.added == 0)
            'Kayıtların hepsi zaten vardı; güncellendi.'
          else if (result.updated > 0)
            '${result.added} yeni kayıt eklendi, ${result.updated} kayıt '
                'güncellendi.',
        ].join('\n\n'),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}

Future<void> _error(BuildContext context, String message) => showDialog(
  context: context,
  builder: (context) => AlertDialog(
    icon: const Icon(Icons.error_outline, size: 48),
    title: const Text('Aktarılamadı'),
    content: Text(message),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Tamam'),
      ),
    ],
  ),
);

const _newProfile = '__new__';

class _WhoseFile extends ConsumerStatefulWidget {
  const _WhoseFile({required this.bundle, required this.match});

  final ParsedBundle bundle;
  final ProfileMatch match;

  @override
  ConsumerState<_WhoseFile> createState() => _WhoseFileState();
}

class _WhoseFileState extends ConsumerState<_WhoseFile> {
  late String _choice = widget.match.suggestion?.id ?? _newProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final patient = widget.bundle.patient;
    final who = patient == null
        ? null
        : [
            patient.fullName,
            if (patient.birthDate != null) formatDay(patient.birthDate!),
          ].join(', ');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bu dosya kime ait?', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              [
                if (who != null) 'Dosyadaki kişi: $who',
                '${widget.bundle.organizationName ?? 'Dosya'}: '
                    '${describeCounts(widget.bundle.counts)}',
              ].join('\n'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: RadioGroup<String>(
                groupValue: _choice,
                onChanged: (v) => setState(() => _choice = v ?? _choice),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in profiles)
                      RadioListTile(
                        value: p.id,
                        title: Text(profileName(p)),
                        subtitle: p.id == widget.match.suggestion?.id
                            ? const Text('Önerilen')
                            : null,
                      ),
                    RadioListTile(
                      value: _newProfile,
                      title: Text(
                        'Yeni profil oluştur'
                        '${patient == null ? '' : ': ${patient.fullName}'}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context, _choice),
              child: const Text('Aktar'),
            ),
          ],
        ),
      ),
    );
  }
}
