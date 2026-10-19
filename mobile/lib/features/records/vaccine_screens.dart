import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/catalog.dart';
import '../../domain/dose_schedule.dart';
import '../../widgets/common.dart';
import 'record_widgets.dart';

class VaccinesScreen extends ConsumerWidget {
  const VaccinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final done = ref.watch(immunizationsProvider(profile.id)).value ?? const [];
    final due = ref.watch(dueVaccinesProvider(profile.id)).value ?? const [];
    final pending = due.where((d) => !d.done).toList();
    final today = dateOnly(DateTime.now());

    return RecordListPage(
      title: 'Aşılar',
      isEmpty: done.isEmpty && pending.isEmpty,
      emptyIcon: Icons.vaccines_outlined,
      emptyTitle: 'Aşı kaydı yok',
      emptyMessage:
          'Yapılan aşıları ve yapılacak aşıları ekleyin. Aşı günü '
          'yaklaşınca hatırlatırız.',
      addLabel: 'Aşı ekle',
      onAdd: () => openForm(context, const VaccineForm()),
      children: [
        if (pending.isNotEmpty) ...[
          const SectionTitle('Yapılacak aşılar'),
          for (final d in pending)
            RecordCard(
              title: d.vaccineName,
              subtitle: [
                d.dueDate.isBefore(today)
                    ? 'Gecikti: ${formatDay(d.dueDate)}'
                    : 'Aşı günü: ${formatDay(d.dueDate)}',
                if (d.doseNumber != null) '${d.doseNumber}. doz',
              ].join(' · '),
              source: d.source,
              originName: d.originName,
              highlight: d.dueDate.isBefore(today),
              leading: const Icon(Icons.event_outlined),
              onTap: () => _dueSheet(context, ref, d),
            ),
        ],
        if (done.isNotEmpty) ...[
          const SectionTitle('Yapılan aşılar'),
          for (final i in done)
            RecordCard(
              title: i.vaccineName,
              subtitle: [
                formatDay(i.date),
                if (i.doseNumber != null) '${i.doseNumber}. doz',
              ].join(' · '),
              source: i.source,
              originName: i.originName,
              leading: const Icon(Icons.check_circle_outline),
              onTap: () => showRecordSheet(
                context,
                title: i.vaccineName,
                source: i.source,
                originName: i.originName,
                details: [
                  InfoRow('Tarih', formatDay(i.date)),
                  InfoRow('Doz', i.doseNumber?.toString()),
                  InfoRow('Seri (lot) no', i.lotNumber),
                  InfoRow('Not', i.note),
                ],
                onEdit: () => openForm(context, VaccineForm(edit: i)),
                onDelete: () => deleteWithUndo(
                  context,
                  ref,
                  ref.read(databaseProvider).immunizations,
                  i.id,
                  i,
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _dueSheet(BuildContext context, WidgetRef ref, DueVaccine d) {
    final db = ref.read(databaseProvider);
    showRecordSheet(
      context,
      title: d.vaccineName,
      source: d.source,
      originName: d.originName,
      details: [
        InfoRow('Aşı günü', formatDay(d.dueDate)),
        InfoRow('Doz', d.doseNumber?.toString()),
        InfoRow('Not', d.note),
      ],
      actions: [
        FilledButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            final repo = ref.read(repositoryProvider);
            await repo.save(db.immunizationDue, d.copyWith(done: true));
            await repo.save(
              db.immunizations,
              ImmunizationsCompanion.insert(
                profileId: d.profileId,
                vaccineName: d.vaccineName,
                vaccineCode: Value(d.vaccineCode),
                date: DateTime.now(),
                doseNumber: Value(d.doseNumber),
              ),
            );
            await rescheduleNotifications(ref);
            if (context.mounted) {
              showMessage(
                context,
                '${d.vaccineName} yapıldı olarak kaydedildi.',
              );
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Bugün yapıldı'),
        ),
        const SizedBox(height: 8),
      ],
      onEdit: () => openForm(context, VaccineForm(editDue: d)),
      onDelete: () => deleteWithUndo(context, ref, db.immunizationDue, d.id, d),
    );
  }
}

class VaccineForm extends ConsumerStatefulWidget {
  const VaccineForm({super.key, this.edit, this.editDue});

  final Immunization? edit;
  final DueVaccine? editDue;

  @override
  ConsumerState<VaccineForm> createState() => _VaccineFormState();
}

class _VaccineFormState extends ConsumerState<VaccineForm> {
  late final _name = TextEditingController(
    text: widget.edit?.vaccineName ?? widget.editDue?.vaccineName ?? '',
  );
  late final _dose = TextEditingController(
    text:
        (widget.edit?.doseNumber ?? widget.editDue?.doseNumber)?.toString() ??
        '',
  );
  late final _note = TextEditingController(
    text: widget.edit?.note ?? widget.editDue?.note ?? '',
  );
  late bool _planned = widget.editDue != null;
  late DateTime _date =
      widget.edit?.date ?? widget.editDue?.dueDate ?? DateTime.now();

  bool get _isEdit => widget.edit != null || widget.editDue != null;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final db = repo.db;
    final profileId = ref.read(currentProfileProvider)!.id;
    final dose = int.tryParse(_dose.text.trim());
    final note = emptyToNull(_note.text);
    final name = _name.text.trim();
    if (_planned) {
      final base =
          widget.editDue ??
          DueVaccine(
            id: newId(),
            profileId: profileId,
            source: RecordSource.self,
            createdAt: DateTime.now(),
            vaccineName: name,
            dueDate: _date,
            done: false,
          );
      await repo.save(
        db.immunizationDue,
        base.copyWith(
          vaccineName: name,
          dueDate: dateOnly(_date),
          doseNumber: Value(dose),
          note: Value(note),
        ),
      );
    } else {
      final base =
          widget.edit ??
          Immunization(
            id: newId(),
            profileId: profileId,
            source: RecordSource.self,
            createdAt: DateTime.now(),
            vaccineName: name,
            date: _date,
          );
      await repo.save(
        db.immunizations,
        base.copyWith(
          vaccineName: name,
          date: _date,
          doseNumber: Value(dose),
          note: Value(note),
        ),
      );
    }
    await rescheduleNotifications(ref);
  }

  @override
  Widget build(BuildContext context) {
    return RecordFormScaffold(
      title: _isEdit ? 'Aşıyı düzenle' : 'Aşı ekle',
      canSave: _name.text.trim().isNotEmpty,
      onSave: _save,
      children: [
        if (!_isEdit) ...[
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Yapıldı'),
                icon: Icon(Icons.check),
              ),
              ButtonSegment(
                value: true,
                label: Text('Yapılacak'),
                icon: Icon(Icons.event),
              ),
            ],
            selected: {_planned},
            onSelectionChanged: (s) => setState(() {
              _planned = s.first;
              if (_planned && _date.isBefore(DateTime.now())) {
                _date = dateOnly(DateTime.now().add(const Duration(days: 30)));
              } else if (!_planned && _date.isAfter(DateTime.now())) {
                _date = DateTime.now();
              }
            }),
          ),
          formGap,
        ],
        SuggestField(
          controller: _name,
          label: 'Aşı adı *',
          hint: 'Örn. Grip aşısı',
          suggestions: vaccineSuggestions,
          autofocus: !_isEdit,
          onChanged: () => setState(() {}),
        ),
        formGap,
        DateField(
          label: _planned ? 'Aşı günü' : 'Yapıldığı tarih',
          value: _date,
          lastDate: _planned ? null : DateTime.now(),
          onChanged: (v) => setState(() => _date = v ?? _date),
        ),
        if (_planned)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Bir gün önce ve aşı günü sabah hatırlatırız.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        formGap,
        TextField(
          controller: _dose,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Kaçıncı doz? (isteğe bağlı)',
          ),
        ),
        formGap,
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)'),
        ),
      ],
    );
  }
}
