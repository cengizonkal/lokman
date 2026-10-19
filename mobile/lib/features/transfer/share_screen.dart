import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../data/repository.dart';
import '../../fhir/bundle_reader.dart';
import '../../fhir/bundle_writer.dart';
import '../../pdf/summary_pdf.dart';
import '../../widgets/common.dart';
import '../profiles/profiles_screen.dart';
import 'import_flow.dart';
import 'qr_scan_screen.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Sağlık dosyasını seçin',
    );
    if (file == null || !context.mounted) return;
    final String text;
    try {
      text = utf8.decode(await file.readAsBytes());
    } catch (_) {
      if (context.mounted) {
        showMessage(
          context,
          'Dosya okunamadı. Doğru dosyayı seçtiğinizden emin olun.',
        );
      }
      return;
    }
    if (context.mounted) await runImport(context, ref, text);
  }

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final text = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (text != null && context.mounted) await runImport(context, ref, text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(importHistoryProvider).value ?? const [];
    final profiles = {
      for (final p in ref.watch(profilesProvider).value ?? const <Profile>[])
        p.id: p,
    };
    final lastExport = ref.watch(lastFullExportProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaş'),
        actions: const [ProfileButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _BigCard(
            icon: Icons.download_rounded,
            title: 'Klinikten kayıt al',
            text:
                'Doktorunuzun verdiği QR kodu okutun ya da size gönderilen '
                'sağlık dosyasını açın. Muayene, ilaç, aşı ve diğer kayıtlar '
                'telefonunuza gelir.',
            children: [
              FilledButton.icon(
                onPressed: () => _scan(context, ref),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR kod okut'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _pickFile(context, ref),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Dosya seç'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BigCard(
            icon: Icons.upload_rounded,
            title: 'Kayıtlarımı paylaş ya da yedekle',
            text:
                'Kayıtlarınızı başka bir doktora, hastaneye ya da yurt dışındaki '
                'bir kuruma götürün. Sağlık dosyası ve okunabilir PDF özeti '
                'birlikte hazırlanır.'
                '${lastExport == null ? '' : '\n\nSon yedek: ${formatDay(lastExport)}'}',
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ExportScreen())),
                icon: const Icon(Icons.ios_share),
                label: const Text('Paylaş / yedekle'),
              ),
            ],
          ),
          if (history.isNotEmpty) ...[
            const SectionTitle('Son aktarımlar'),
            for (final h in history.take(10))
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.history),
                title: Text(h.originName ?? 'Sağlık dosyası'),
                subtitle: Text(
                  [
                    formatDayTime(h.importedAt),
                    if (profiles[h.profileId] != null)
                      profileName(profiles[h.profileId]!),
                    _summary(h.summary),
                  ].where((s) => s.isNotEmpty).join(' · '),
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            'Lokman bir hesap ya da sunucu kullanmaz. Dosya yalnızca sizin '
            'seçtiğiniz kişiye ya da uygulamaya gider.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _summary(String json) {
    try {
      final map = (jsonDecode(json) as Map).cast<String, dynamic>();
      return describeCounts({
        for (final k in RecordKind.values)
          if (map[k.name] is int) k: map[k.name] as int,
      });
    } catch (_) {
      return '';
    }
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String text;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Dışa aktarım: kimin, hangi kayıtları → sağlık dosyası + PDF → paylaş.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _profileId;
  final Set<RecordKind> _kinds = {...RecordKind.values};
  bool _busy = false;

  static const _groups = [
    ('İlaçlar', [RecordKind.medication]),
    ('Aşılar', [RecordKind.immunization, RecordKind.dueVaccine]),
    ('Alerjiler', [RecordKind.allergy]),
    ('Kronik hastalıklar', [RecordKind.condition]),
    ('Ölçümler', [RecordKind.observation]),
    ('Randevular', [RecordKind.appointment]),
    ('Muayeneler ve tanılar', [RecordKind.encounter, RecordKind.diagnosis]),
  ];

  bool get _all => _kinds.length == RecordKind.values.length;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(repositoryProvider);
      final profileId = _profileId ?? ref.read(currentProfileProvider)!.id;
      final data = await ExportData.load(repo.db, profileId, kinds: _kinds);
      final bundle = buildBundle(data, appId: await repo.appId());
      final pdf = await buildSummaryPdf(data, await PdfFonts.load());

      final dir = Directory(
        '${(await getTemporaryDirectory()).path}/lokman-export',
      );
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      dir.createSync(recursive: true);
      final stamp = DateTime.now();
      final base =
          'lokman-${_slug(data.profile.firstName)}-'
          '${stamp.year}${stamp.month.toString().padLeft(2, '0')}'
          '${stamp.day.toString().padLeft(2, '0')}';
      final jsonFile = File('${dir.path}/$base.json')
        ..writeAsStringSync(encodeBundle(bundle));
      final pdfFile = File('${dir.path}/$base.pdf')..writeAsBytesSync(pdf);

      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'Sağlık kayıtları',
          subject: 'Sağlık kayıtları — ${profileName(data.profile)}',
          files: [
            XFile(jsonFile.path, mimeType: 'application/fhir+json'),
            XFile(pdfFile.path, mimeType: 'application/pdf'),
          ],
        ),
      );
      if (_all && result.status == ShareResultStatus.success) {
        await repo.setSetting(
          SettingKeys.lastFullExport,
          DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      if (mounted) showMessage(context, 'Dosyalar hazırlanamadı: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _slug(String s) {
    final n = s
        .toLowerCase()
        .replaceAll(RegExp('[çÇ]'), 'c')
        .replaceAll(RegExp('[ğĞ]'), 'g')
        .replaceAll(RegExp('[ıİI]'), 'i')
        .replaceAll(RegExp('[öÖ]'), 'o')
        .replaceAll(RegExp('[şŞ]'), 's')
        .replaceAll(RegExp('[üÜ]'), 'u')
        .replaceAll(RegExp('[^a-z0-9]+'), '-');
    return n.isEmpty ? 'profil' : n;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final selected = _profileId ?? ref.watch(currentProfileProvider)?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Paylaş / yedekle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (profiles.length > 1) ...[
            Text('Kimin kayıtları?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in profiles)
                  ChoiceChip(
                    avatar: ProfileAvatar(p, radius: 12),
                    label: Text(p.firstName),
                    selected: p.id == selected,
                    onSelected: (_) => setState(() => _profileId = p.id),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          Text('Hangi kayıtlar?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Tüm kayıtlar'),
            subtitle: const Text('Yedek için tümünü seçin'),
            value: _all,
            onChanged: (v) => setState(() {
              _kinds.clear();
              if (v) _kinds.addAll(RecordKind.values);
            }),
          ),
          if (!_all)
            for (final (label, kinds) in _groups)
              CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(label),
                value: kinds.every(_kinds.contains),
                onChanged: (v) => setState(
                  () => v == true
                      ? _kinds.addAll(kinds)
                      : _kinds.removeAll(kinds),
                ),
              ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'İki dosya hazırlanır: sağlık dosyası (.json, başka bir '
                      'Lokman ya da sağlık sistemi okuyabilir) ve PDF özet '
                      '(herkes okuyabilir). Dosyalar şifrelenmez; yalnızca '
                      'güvendiğiniz kişi ve kurumlarla paylaşın. İlaç '
                      '“aldım/atladım” kayıtları paylaşılmaz.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _busy || _kinds.isEmpty || selected == null
              ? null
              : _export,
          icon: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share),
          label: Text(_busy ? 'Hazırlanıyor…' : 'Dosyaları hazırla ve paylaş'),
        ),
      ),
    );
  }
}
