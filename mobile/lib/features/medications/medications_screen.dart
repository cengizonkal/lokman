import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/dose_schedule.dart';
import '../../widgets/common.dart';
import '../profiles/profiles_screen.dart';
import 'medication_wizard.dart';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final meds = profile == null
        ? const <Medication>[]
        : ref.watch(medicationsProvider(profile.id)).value ?? const [];
    final events = profile == null
        ? const <DoseEvent>[]
        : ref.watch(doseEventsProvider(profile.id)).value ?? const [];
    final now = DateTime.now();
    final current = meds.where((m) => isCurrent(m, now)).toList();
    final past = meds.where((m) => !isCurrent(m, now)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlaçlar'),
        actions: const [ProfileButton()],
      ),
      floatingActionButton: meds.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openMedicationWizard(context),
              icon: const Icon(Icons.add),
              label: const Text('İlaç ekle'),
            ),
      body: meds.isEmpty
          ? EmptyState(
              icon: Icons.medication_outlined,
              title: 'İlaç listeniz boş',
              message:
                  'Kullandığınız ilaçları ekleyin; saati gelince size '
                  'hatırlatalım. Klinikten aktarılan reçeteler de burada görünür.',
              actionLabel: 'İlaç ekle',
              onAction: () => openMedicationWizard(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              children: [
                SectionTitle('Kullandıklarım (${current.length})'),
                if (current.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Şu an kullandığınız ilaç yok.'),
                  ),
                for (final m in current)
                  _MedicationCard(medication: m, events: events, now: now),
                if (past.isNotEmpty) ...[
                  SectionTitle('Bitenler (${past.length})'),
                  for (final m in past)
                    _MedicationCard(medication: m, events: events, now: now),
                ],
              ],
            ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.medication,
    required this.events,
    required this.now,
  });

  final Medication medication;
  final List<DoseEvent> events;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = medication;
    final times = DoseTime.parseList(m.timesOfDay);
    final last = lastDay(m);
    final active = isCurrent(m, now);
    final rate = active
        ? adherence(
            m,
            events.where((e) => e.medicationId == m.id).toList(),
            now,
          )
        : null;
    final String period;
    if (!active) {
      period = last == null ? 'Bitti' : 'Bitti · ${formatDay(last)}';
    } else if (last == null) {
      period = 'Sürekli';
    } else {
      final left = last.difference(dateOnly(now)).inDays + 1;
      period = m.startDate.isAfter(now)
          ? '${formatDay(m.startDate)} başlayacak'
          : '$left gün kaldı';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: active ? null : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    Text(period, style: theme.textTheme.labelLarge),
                  ],
                ),
                if (m.dose.isNotEmpty || m.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        m.dose,
                        m.note,
                      ].nonNulls.where((s) => s.isNotEmpty).join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (times.isEmpty)
                      const Chip(
                        avatar: Icon(Icons.schedule, size: 18),
                        label: Text('Gerektiğinde'),
                        visualDensity: VisualDensity.compact,
                      ),
                    for (final t in times)
                      Chip(
                        avatar: const Icon(Icons.alarm, size: 18),
                        label: Text(t.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    SourceBadge(source: m.source, originName: m.originName),
                  ],
                ),
                if (rate != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Düzenli kullanım %${(rate * 100).round()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _MedicationSheet(medication: medication),
  );
}

class _MedicationSheet extends ConsumerWidget {
  const _MedicationSheet({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = medication;
    final repo = ref.read(repositoryProvider);
    final active = isCurrent(m, DateTime.now());
    final last = lastDay(m);
    final times = DoseTime.parseList(m.timesOfDay);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: SourceBadge(source: m.source, originName: m.originName),
            ),
            const SizedBox(height: 8),
            InfoRow('Doz', m.dose),
            InfoRow(
              'Saatler',
              times.isEmpty ? 'Gerektiğinde' : times.join(', '),
            ),
            InfoRow('Başlangıç', formatDay(m.startDate)),
            InfoRow('Bitiş', last == null ? 'Sürekli' : formatDay(last)),
            InfoRow('Not', m.note),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pop(context);
                openMedicationWizard(context, edit: m);
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                m.source == RecordSource.clinic
                    ? 'Saatleri ve dozu düzenle'
                    : 'Düzenle',
              ),
            ),
            if (active) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await confirm(
                    context,
                    title: 'İlacı bıraktınız mı?',
                    message:
                        '${m.name} “Bitenler” listesine taşınır ve hatırlatmalar '
                        'durur.',
                    action: 'Bıraktım',
                    destructive: false,
                  );
                  if (!ok) return;
                  await repo.stopMedication(m);
                  await rescheduleNotifications(ref);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Kullanmayı bıraktım'),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: 'İlaç silinsin mi?',
                  message: '${m.name} ve aldım/atladım kayıtları silinir.',
                );
                if (!ok) return;
                await repo.deleteRecord(repo.db.medications, m.id);
                await rescheduleNotifications(ref);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Sil'),
            ),
          ],
        ),
      ),
    );
  }
}
