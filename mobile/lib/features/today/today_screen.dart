import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/dose_schedule.dart';
import '../../widgets/common.dart';
import '../medications/medication_wizard.dart';
import '../profiles/profiles_screen.dart';
import '../records/observation_screens.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugün'),
        actions: const [ProfileButton()],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _TodayBody(profile: profile),
    );
  }
}

class _Dose {
  _Dose(this.medication, this.at, this.event);
  final Medication medication;
  final DateTime at;
  final DoseEvent? event;
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final meds = ref.watch(medicationsProvider(profile.id)).value ?? const [];
    final events = ref.watch(doseEventsProvider(profile.id)).value ?? const [];
    final due = ref.watch(dueVaccinesProvider(profile.id)).value ?? const [];
    final appointments =
        ref.watch(appointmentsProvider(profile.id)).value ?? const [];
    final observations =
        ref.watch(observationsProvider(profile.id)).value ?? const [];
    final lastExport = ref.watch(lastFullExportProvider).value;

    final eventByKey = {
      for (final e in events) '${e.medicationId}|${e.scheduledAt}': e,
    };
    final doses = [
      for (final m in meds)
        for (final at in dosesOn(m, now))
          _Dose(m, at, eventByKey['${m.id}|$at']),
    ]..sort((a, b) => a.at.compareTo(b.at));
    final taken = doses.where((d) => d.event?.status == 'taken').length;

    final soon = now.add(const Duration(days: 30));
    final upcomingVaccines = due
        .where((v) => !v.done && v.dueDate.isBefore(soon))
        .toList();
    final upcomingAppointments = appointments
        .where(
          (a) =>
              a.start.isAfter(now.subtract(const Duration(hours: 1))) &&
              a.start.isBefore(soon),
        )
        .toList();

    final latest = <String, Observation>{};
    for (final o in observations) {
      latest.putIfAbsent(o.typeKey, () => o);
    }

    final hasData =
        meds.isNotEmpty || observations.isNotEmpty || due.isNotEmpty;
    final needsBackup =
        hasData &&
        (lastExport == null || now.difference(lastExport).inDays >= 30);

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          '${_greeting(now)}, ${profile.firstName}',
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          formatWeekday(now),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SectionTitle(
          'Bugünün ilaçları',
          trailing: doses.isEmpty
              ? null
              : Text(
                  '$taken / ${doses.length} alındı',
                  style: theme.textTheme.labelLarge,
                ),
        ),
        if (doses.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: taken / doses.length,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          for (final d in doses) _DoseCard(dose: d, now: now),
        ] else
          _InfoCard(
            icon: Icons.medication_outlined,
            text: meds.isEmpty
                ? 'Henüz ilaç eklemediniz. İlaç ekleyince saati gelince '
                      'hatırlatırız.'
                : 'Bugün için planlı ilaç dozu yok.',
            action: meds.isEmpty ? 'İlaç ekle' : null,
            onAction: () => openMedicationWizard(context),
          ),
        if (upcomingVaccines.isNotEmpty || upcomingAppointments.isNotEmpty) ...[
          const SectionTitle('Yaklaşanlar'),
          for (final a in upcomingAppointments)
            _EventCard(
              icon: Icons.event_available_outlined,
              title: a.title.isEmpty ? 'Randevu' : a.title,
              subtitle: [
                '${relativeDay(a.start, now)}, ${formatTime(a.start)}',
                a.practitioner,
                a.location,
              ].nonNulls.join(' · '),
              onTap: () => context.go('/records/appointments'),
            ),
          for (final v in upcomingVaccines)
            _EventCard(
              icon: Icons.vaccines_outlined,
              title: v.vaccineName,
              subtitle: v.dueDate.isBefore(dateOnly(now))
                  ? 'Gecikti · ${formatDay(v.dueDate)}'
                  : 'Aşı günü: ${relativeDay(v.dueDate, now)}',
              warning: v.dueDate.isBefore(dateOnly(now)),
              onTap: () => context.go('/records/vaccines'),
            ),
        ],
        SectionTitle(
          'Son ölçümler',
          trailing: TextButton.icon(
            onPressed: () => openObservationForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Ölçüm ekle'),
          ),
        ),
        if (latest.isEmpty)
          const _InfoCard(
            icon: Icons.monitor_heart_outlined,
            text:
                'Tansiyon, şeker, kilo gibi ölçümlerinizi kaydedin; '
                'değişimi grafikte görün.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in latest.values)
                _MeasurementTile(observation: o, now: now),
            ],
          ),
        if (needsBackup) ...[
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Verilerinizi yedekleyin'),
              subtitle: Text(
                lastExport == null
                    ? 'Kayıtlar yalnızca bu telefonda. Telefon kaybolursa '
                          'silinmesin diye bir kopyasını saklayın.'
                    : 'Son yedek ${formatDay(lastExport)} tarihinde alındı.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/share'),
            ),
          ),
        ],
      ],
    );
  }

  String _greeting(DateTime now) => switch (now.hour) {
    >= 5 && < 12 => 'Günaydın',
    >= 12 && < 18 => 'İyi günler',
    _ => 'İyi akşamlar',
  };
}

class _DoseCard extends ConsumerWidget {
  const _DoseCard({required this.dose, required this.now});

  final _Dose dose;
  final DateTime now;

  Future<void> _mark(WidgetRef ref, String? status) => ref
      .read(repositoryProvider)
      .markDose(dose.medication.id, dose.at, status);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = dose.event?.status;
    final late = status == null && dose.at.isBefore(now);
    final m = dose.medication;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: status == 'taken'
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    formatTime(dose.at),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: late ? theme.colorScheme.error : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: theme.textTheme.titleMedium),
                        if (m.dose.isNotEmpty || late)
                          Text(
                            [
                              if (m.dose.isNotEmpty) m.dose,
                              if (late) 'Saati geçti',
                            ].join(' · '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: late
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (status == null)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _mark(ref, 'taken'),
                        icon: const Icon(Icons.check),
                        label: const Text('Aldım'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _mark(ref, 'skipped'),
                        child: const Text('Atladım'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      status == 'taken' ? Icons.check_circle : Icons.cancel,
                      color: status == 'taken'
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status == 'taken'
                            ? 'Alındı · ${formatTime(dose.event!.markedAt)}'
                            : 'Atlandı',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _mark(ref, null),
                      child: const Text('Geri al'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(action!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: warning
                ? scheme.errorContainer
                : scheme.tertiaryContainer,
            child: Icon(
              icon,
              color: warning
                  ? scheme.onErrorContainer
                  : scheme.onTertiaryContainer,
            ),
          ),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: warning ? TextStyle(color: scheme.error) : null,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.observation, required this.now});

  final Observation observation;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/records/measurements'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  observation.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  observationValue(observation),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  relativeDay(observation.effectiveAt, now),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
