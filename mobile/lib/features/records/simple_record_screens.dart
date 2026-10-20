import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/catalog.dart';
import '../../domain/dose_schedule.dart' show dateOnly;
import '../medications/medication_wizard.dart';
import '../../widgets/common.dart';
import 'record_widgets.dart';

// ------------------------------------------------------------------ Alerjiler

class AllergiesScreen extends ConsumerWidget {
  const AllergiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final items = ref.watch(allergiesProvider(profile.id)).value ?? const [];
    return RecordListPage(
      title: 'Alerjiler',
      isEmpty: items.isEmpty,
      emptyIcon: Icons.warning_amber_rounded,
      emptyTitle: 'Bilinen alerji yok',
      emptyMessage:
          'İlaç, besin ya da başka bir şeye alerjiniz varsa ekleyin. '
          'Doktorunuza giderken bu liste çok işe yarar.',
      addLabel: 'Alerji ekle',
      onAdd: () => openForm(context, const AllergyForm()),
      children: [
        const SizedBox(height: 8),
        for (final a in items)
          RecordCard(
            title: a.substance,
            subtitle: [
              a.reaction,
              if (a.criticality == 'high') 'Ağır',
              if (a.criticality == 'low') 'Hafif',
            ].nonNulls.join(' · '),
            source: a.source,
            originName: a.originName,
            leading: Icon(
              Icons.warning_amber_rounded,
              color: a.criticality == 'high'
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            onTap: () => showRecordSheet(
              context,
              title: a.substance,
              source: a.source,
              originName: a.originName,
              details: [
                InfoRow('Tepki', a.reaction),
                InfoRow('Şiddet', switch (a.criticality) {
                  'high' => 'Ağır',
                  'low' => 'Hafif',
                  _ => null,
                }),
                InfoRow('Kod', a.code),
                InfoRow('Not', a.note),
              ],
              onEdit: () => openForm(context, AllergyForm(edit: a)),
              onDelete: () => deleteWithUndo(
                context,
                ref,
                ref.read(databaseProvider).allergies,
                a.id,
                a,
              ),
            ),
          ),
      ],
    );
  }
}

class AllergyForm extends ConsumerStatefulWidget {
  const AllergyForm({super.key, this.edit});

  final Allergy? edit;

  @override
  ConsumerState<AllergyForm> createState() => _AllergyFormState();
}

class _AllergyFormState extends ConsumerState<AllergyForm> {
  late final _name = TextEditingController(text: widget.edit?.substance ?? '');
  late final _reaction = TextEditingController(
    text: widget.edit?.reaction ?? '',
  );
  late final _note = TextEditingController(text: widget.edit?.note ?? '');
  late String? _criticality = widget.edit?.criticality;

  @override
  void dispose() {
    _name.dispose();
    _reaction.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final base =
        widget.edit ??
        Allergy(
          id: newId(),
          profileId: ref.read(currentProfileProvider)!.id,
          source: RecordSource.self,
          createdAt: DateTime.now(),
          substance: '',
        );
    await repo.save(
      repo.db.allergies,
      base.copyWith(
        substance: _name.text.trim(),
        reaction: Value(emptyToNull(_reaction.text)),
        criticality: Value(_criticality),
        note: Value(emptyToNull(_note.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
    title: widget.edit == null ? 'Alerji ekle' : 'Alerjiyi düzenle',
    canSave: _name.text.trim().isNotEmpty,
    onSave: _save,
    children: [
      SuggestField(
        controller: _name,
        label: 'Neye alerjiniz var? *',
        hint: 'Örn. Penisilin',
        suggestions: allergySuggestions,
        autofocus: widget.edit == null,
        onChanged: () => setState(() {}),
      ),
      formGap,
      TextField(
        controller: _reaction,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Ne oluyor? (isteğe bağlı)',
          hintText: 'Örn. Kaşıntı, kızarıklık',
        ),
      ),
      QuickChips(
        values: const [
          'Kaşıntı',
          'Kurdeşen',
          'Nefes darlığı',
          'Şişlik',
          'Bulantı',
        ],
        onTap: (v) => setState(
          () => _reaction.text = _reaction.text.trim().isEmpty
              ? v
              : '${_reaction.text.trim()}, $v',
        ),
      ),
      formGap,
      Text('Ne kadar ciddi?', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      SegmentedButton<String?>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: null, label: Text('Bilmiyorum')),
          ButtonSegment(value: 'low', label: Text('Hafif')),
          ButtonSegment(value: 'high', label: Text('Ağır')),
        ],
        selected: {_criticality},
        onSelectionChanged: (s) => setState(() => _criticality = s.first),
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

// ----------------------------------------------------------------- Hastalıklar

class ConditionsScreen extends ConsumerWidget {
  const ConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final items = ref.watch(conditionsProvider(profile.id)).value ?? const [];
    final active = items
        .where((c) => c.status != ConditionStatus.resolved)
        .toList();
    final past = items
        .where((c) => c.status == ConditionStatus.resolved)
        .toList();
    return RecordListPage(
      title: 'Hastalıklar',
      isEmpty: items.isEmpty,
      emptyIcon: Icons.monitor_heart_outlined,
      emptyTitle: 'Kayıtlı hastalık yok',
      emptyMessage:
          'Tansiyon, şeker, astım gibi devam eden hastalıklarınızı ve '
          'zatürre, sarılık gibi geçirdiğiniz hastalıkları ekleyin.',
      addLabel: 'Hastalık ekle',
      onAdd: () => openForm(context, const ConditionForm()),
      children: [
        if (active.isNotEmpty) ...[
          const SectionTitle('Devam eden'),
          for (final c in active) _card(context, ref, c),
        ],
        if (past.isNotEmpty) ...[
          const SectionTitle('Geçirilmiş'),
          for (final c in past) _card(context, ref, c),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, Condition c) {
    final resolved = c.status == ConditionStatus.resolved;
    final onset = c.onsetDate?.year;
    final end = c.resolvedDate?.year;
    return RecordCard(
      title: c.name,
      subtitle: [
        if (!resolved && onset != null) '$onset yılından beri',
        if (resolved && onset != null && end != null)
          onset == end ? '$end' : '$onset – $end',
        if (resolved && onset == null && end != null) '$end yılında geçti',
        if (resolved && onset != null && end == null) '$onset yılında başladı',
        ?c.code,
      ].join(' · '),
      source: c.source,
      originName: c.originName,
      leading: Icon(
        resolved ? Icons.check_circle_outline : Icons.favorite_outline,
      ),
      onTap: () => showRecordSheet(
        context,
        title: c.name,
        source: c.source,
        originName: c.originName,
        details: [
          InfoRow('Durum', resolved ? 'Geçti' : 'Devam ediyor'),
          InfoRow(
            'Başlangıç',
            c.onsetDate == null ? null : formatDay(c.onsetDate!),
          ),
          InfoRow(
            'Geçtiği tarih',
            c.resolvedDate == null ? null : formatDay(c.resolvedDate!),
          ),
          InfoRow('Kod (ICD-10)', c.code),
          InfoRow('Not', c.note),
        ],
        onEdit: () => openForm(context, ConditionForm(edit: c)),
        onDelete: () => deleteWithUndo(
          context,
          ref,
          ref.read(databaseProvider).conditions,
          c.id,
          c,
        ),
      ),
    );
  }
}

class ConditionForm extends ConsumerStatefulWidget {
  const ConditionForm({super.key, this.edit});

  final Condition? edit;

  @override
  ConsumerState<ConditionForm> createState() => _ConditionFormState();
}

class _ConditionFormState extends ConsumerState<ConditionForm> {
  late final _name = TextEditingController(text: widget.edit?.name ?? '');
  late final _note = TextEditingController(text: widget.edit?.note ?? '');
  late DateTime? _onset = widget.edit?.onsetDate;
  late bool _resolved = widget.edit?.status == ConditionStatus.resolved;
  late DateTime? _resolvedDate = widget.edit?.resolvedDate;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final base =
        widget.edit ??
        Condition(
          id: newId(),
          profileId: ref.read(currentProfileProvider)!.id,
          source: RecordSource.self,
          createdAt: DateTime.now(),
          name: '',
          status: ConditionStatus.active,
        );
    await repo.save(
      repo.db.conditions,
      base.copyWith(
        name: _name.text.trim(),
        onsetDate: Value(_onset),
        status: _resolved ? ConditionStatus.resolved : ConditionStatus.active,
        resolvedDate: Value(_resolved ? _resolvedDate : null),
        note: Value(emptyToNull(_note.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
    title: widget.edit == null ? 'Hastalık ekle' : 'Hastalığı düzenle',
    canSave: _name.text.trim().isNotEmpty,
    onSave: _save,
    children: [
      SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('Devam ediyor'),
            icon: Icon(Icons.favorite_outline),
          ),
          ButtonSegment(
            value: true,
            label: Text('Geçti'),
            icon: Icon(Icons.check),
          ),
        ],
        selected: {_resolved},
        onSelectionChanged: (s) => setState(() => _resolved = s.first),
      ),
      formGap,
      SuggestField(
        controller: _name,
        label: 'Hastalığın adı *',
        hint: _resolved ? 'Örn. Zatürre' : 'Örn. Hipertansiyon',
        suggestions: _resolved
            ? pastConditionSuggestions
            : conditionSuggestions,
        autofocus: widget.edit == null,
        onChanged: () => setState(() {}),
      ),
      formGap,
      DateField(
        label: _resolved
            ? 'Ne zaman başladı? (isteğe bağlı)'
            : 'Ne zamandan beri? (isteğe bağlı)',
        value: _onset,
        allowEmpty: true,
        lastDate: _resolved ? _resolvedDate ?? DateTime.now() : DateTime.now(),
        onChanged: (v) => setState(() => _onset = v),
      ),
      if (_resolved) ...[
        formGap,
        DateField(
          label: 'Ne zaman geçti? (isteğe bağlı)',
          value: _resolvedDate,
          allowEmpty: true,
          firstDate: _onset,
          lastDate: DateTime.now(),
          onChanged: (v) => setState(() => _resolvedDate = v),
        ),
      ],
      formGap,
      TextField(
        controller: _note,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)'),
      ),
    ],
  );
}

// ----------------------------------------------------------------- Randevular

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final items = ref.watch(appointmentsProvider(profile.id)).value ?? const [];
    final now = DateTime.now();
    final upcoming = items.where((a) => !a.start.isBefore(now)).toList();
    final past = items.where((a) => a.start.isBefore(now)).toList().reversed;

    Widget card(Appointment a) => RecordCard(
      title: a.title.isEmpty ? 'Randevu' : a.title,
      subtitle: [
        '${relativeDay(a.start, now)}, ${formatTime(a.start)}',
        a.practitioner,
        a.location,
      ].nonNulls.join(' · '),
      source: a.source,
      originName: a.originName,
      leading: const Icon(Icons.event_outlined),
      onTap: () => showRecordSheet(
        context,
        title: a.title.isEmpty ? 'Randevu' : a.title,
        source: a.source,
        originName: a.originName,
        details: [
          InfoRow('Tarih', formatDayTime(a.start)),
          InfoRow('Doktor', a.practitioner),
          InfoRow('Yer', a.location),
          InfoRow('Not', a.note),
        ],
        onEdit: () => openForm(context, AppointmentForm(edit: a)),
        onDelete: () => deleteWithUndo(
          context,
          ref,
          ref.read(databaseProvider).appointments,
          a.id,
          a,
        ),
      ),
    );

    return RecordListPage(
      title: 'Randevular',
      isEmpty: items.isEmpty,
      emptyIcon: Icons.event_outlined,
      emptyTitle: 'Randevu yok',
      emptyMessage:
          'Doktor randevularınızı ekleyin; bir gün önce ve iki saat önce '
          'hatırlatalım.',
      addLabel: 'Randevu ekle',
      onAdd: () => openForm(context, const AppointmentForm()),
      children: [
        if (upcoming.isNotEmpty) ...[
          const SectionTitle('Yaklaşan'),
          ...upcoming.map(card),
        ],
        if (past.isNotEmpty) ...[
          const SectionTitle('Geçmiş'),
          ...past.map(card),
        ],
      ],
    );
  }
}

class AppointmentForm extends ConsumerStatefulWidget {
  const AppointmentForm({super.key, this.edit});

  final Appointment? edit;

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  late final _title = TextEditingController(text: widget.edit?.title ?? '');
  late final _doctor = TextEditingController(
    text: widget.edit?.practitioner ?? '',
  );
  late final _place = TextEditingController(text: widget.edit?.location ?? '');
  late final _note = TextEditingController(text: widget.edit?.note ?? '');
  late DateTime? _start = widget.edit?.start;

  @override
  void dispose() {
    _title.dispose();
    _doctor.dispose();
    _place.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final base =
        widget.edit ??
        Appointment(
          id: newId(),
          profileId: ref.read(currentProfileProvider)!.id,
          source: RecordSource.self,
          createdAt: DateTime.now(),
          start: _start!,
          title: '',
        );
    await repo.save(
      repo.db.appointments,
      base.copyWith(
        start: _start,
        title: _title.text.trim(),
        practitioner: Value(emptyToNull(_doctor.text)),
        location: Value(emptyToNull(_place.text)),
        note: Value(emptyToNull(_note.text)),
      ),
    );
    await rescheduleNotifications(ref);
  }

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
    title: widget.edit == null ? 'Randevu ekle' : 'Randevuyu düzenle',
    canSave: _start != null,
    onSave: _save,
    children: [
      DateField(
        label: 'Tarih ve saat *',
        value: _start,
        withTime: true,
        firstDate: DateTime(2000),
        onChanged: (v) => setState(() => _start = v),
      ),
      formGap,
      TextField(
        controller: _title,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Konu',
          hintText: 'Örn. Tansiyon kontrolü',
        ),
      ),
      formGap,
      TextField(
        controller: _doctor,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Doktor'),
      ),
      formGap,
      TextField(
        controller: _place,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Hastane / klinik'),
      ),
      formGap,
      TextField(
        controller: _note,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Not',
          hintText: 'Örn. Aç gelinecek, tahlil sonuçlarını getir',
        ),
      ),
    ],
  );
}

// ----------------------------------------------------------------- Muayeneler

/// Muayeneler: klinikten gelenler ve kullanıcının kendi eklediği doktor
/// ziyaretleri.
class EncountersScreen extends ConsumerWidget {
  const EncountersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final items = ref.watch(encountersProvider(profile.id)).value ?? const [];
    final diagnoses =
        ref.watch(diagnosesProvider(profile.id)).value ?? const [];
    final medications =
        ref.watch(medicationsProvider(profile.id)).value ?? const [];
    return RecordListPage(
      title: 'Muayeneler',
      isEmpty: items.isEmpty,
      emptyIcon: Icons.medical_information_outlined,
      emptyTitle: 'Muayene kaydı yok',
      emptyMessage:
          'Gittiğiniz doktor ziyaretlerini ekleyin: nereye, neden gittiniz, '
          'doktor ne dedi. Klinikten aldığınız QR kodu ya da dosyayı '
          '“Paylaş” sekmesinden de aktarabilirsiniz.',
      addLabel: 'Ziyaret ekle',
      onAdd: () => addVisit(context),
      children: [
        const SizedBox(height: 8),
        for (final e in items)
          _card(
            context,
            ref,
            e,
            diagnoses.where((d) => d.encounterId == e.id).toList(),
            medications.where((m) => m.encounterId == e.id).toList(),
          ),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    WidgetRef ref,
    Encounter e,
    List<Diagnosis> dx,
    List<Medication> meds,
  ) {
    final self = e.source == RecordSource.self;
    return RecordCard(
      title: formatDay(e.date),
      subtitle: [
        e.location,
        e.practitioner,
        e.complaint,
        if (dx.isNotEmpty) dx.map((d) => d.name).join(', '),
      ].nonNulls.join(' · '),
      source: e.source,
      originName: e.originName,
      leading: const Icon(Icons.medical_information_outlined),
      onTap: () => showRecordSheet(
        context,
        title: self
            ? 'Doktor ziyareti · ${formatDay(e.date)}'
            : 'Muayene · ${formatDay(e.date)}',
        source: e.source,
        originName: e.originName,
        details: [
          InfoRow('Hastane / klinik', e.location),
          InfoRow('Doktor', e.practitioner),
          InfoRow(self ? 'Neden gittiniz' : 'Şikayet', e.complaint),
          InfoRow('Bulgular', e.findings),
          for (final d in dx)
            InfoRow(
              d.verification == 'provisional' ? 'Ön tanı' : 'Tanı',
              [d.name, if (d.code != null) '(${d.code})'].join(' '),
            ),
          InfoRow('Doktorun önerileri', e.plan),
          InfoRow(
            'Yazılan ilaçlar',
            meds.isEmpty ? null : meds.map((m) => m.name).join(', '),
          ),
          InfoRow('Notlarım', e.note),
        ],
        actions: [
          if (self)
            Builder(
              builder: (sheet) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheet);
                    openMedicationWizard(context, encounterId: e.id);
                  },
                  icon: const Icon(Icons.medication_outlined),
                  label: const Text('Bu ziyarette yazılan ilacı ekle'),
                ),
              ),
            ),
        ],
        onEdit: () => openForm(
          context,
          EncounterForm(edit: e, diagnosis: dx.firstOrNull),
        ),
        onDelete: () => _delete(context, ref, e, dx),
      ),
    );
  }

  /// Muayeneyi ve ona bağlı tanıları birlikte siler; "Geri al" ikisini de
  /// geri getirir. Bağlı ilaçlar kullanılmaya devam edebileceği için kalır.
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Encounter e,
    List<Diagnosis> dx,
  ) async {
    final repo = ref.read(repositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    for (final d in dx) {
      await repo.deleteRecord(repo.db.diagnoses, d.id);
    }
    await repo.deleteRecord(repo.db.encounters, e.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Kayıt silindi'),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () async {
              await repo.restore(repo.db.encounters, e);
              for (final d in dx) {
                await repo.restore(repo.db.diagnoses, d);
              }
            },
          ),
        ),
      );
  }
}

/// Yeni doktor ziyareti ekler; kaydedilince bu ziyarette ilaç yazılıp
/// yazılmadığını sorar.
Future<void> addVisit(BuildContext context) async {
  final saved = await Navigator.of(context).push<Encounter>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const EncounterForm(),
    ),
  );
  if (saved == null || !context.mounted) return;
  final addMedication = await confirm(
    context,
    title: 'Bu ziyarette ilaç yazıldı mı?',
    message:
        'İlacı şimdi eklerseniz bu ziyaretle birlikte saklanır ve saatinde '
        'hatırlatılır.',
    action: 'İlaç ekle',
    cancel: 'Hayır',
    destructive: false,
  );
  if (addMedication && context.mounted) {
    await openMedicationWizard(context, encounterId: saved.id);
  }
}

class EncounterForm extends ConsumerStatefulWidget {
  const EncounterForm({super.key, this.edit, this.diagnosis});

  final Encounter? edit;

  /// Ziyarete bağlı (kullanıcının girdiği) tanı.
  final Diagnosis? diagnosis;

  @override
  ConsumerState<EncounterForm> createState() => _EncounterFormState();
}

class _EncounterFormState extends ConsumerState<EncounterForm> {
  late final _location = TextEditingController(
    text: widget.edit?.location ?? '',
  );
  late final _doctor = TextEditingController(
    text: widget.edit?.practitioner ?? '',
  );
  late final _complaint = TextEditingController(
    text: widget.edit?.complaint ?? '',
  );
  late final _diagnosis = TextEditingController(
    text: widget.diagnosis?.name ?? '',
  );
  late final _plan = TextEditingController(text: widget.edit?.plan ?? '');
  late final _note = TextEditingController(text: widget.edit?.note ?? '');
  late DateTime? _date = widget.edit?.date ?? dateOnly(DateTime.now());
  DateTime? _followUp;
  Encounter? _saved;

  bool get _isNew => widget.edit == null;

  @override
  void dispose() {
    for (final c in [
      _location,
      _doctor,
      _complaint,
      _diagnosis,
      _plan,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final profileId = ref.read(currentProfileProvider)!.id;
    final now = DateTime.now();
    final base =
        widget.edit ??
        Encounter(
          id: newId(),
          profileId: profileId,
          source: RecordSource.self,
          createdAt: now,
          date: _date!,
        );
    final encounter = base.copyWith(
      date: _date,
      location: Value(emptyToNull(_location.text)),
      practitioner: Value(emptyToNull(_doctor.text)),
      complaint: Value(emptyToNull(_complaint.text)),
      plan: Value(emptyToNull(_plan.text)),
      note: Value(emptyToNull(_note.text)),
    );
    await repo.save(repo.db.encounters, encounter);

    final dxName = emptyToNull(_diagnosis.text);
    final existing = widget.diagnosis;
    if (dxName == null) {
      if (existing != null) {
        await repo.deleteRecord(repo.db.diagnoses, existing.id);
      }
    } else if (existing?.name != dxName || existing?.date != _date) {
      final dx =
          existing ??
          Diagnosis(
            id: newId(),
            profileId: profileId,
            source: RecordSource.self,
            createdAt: now,
            name: dxName,
            verification: 'confirmed',
          );
      await repo.save(
        repo.db.diagnoses,
        dx.copyWith(
          name: dxName,
          encounterId: Value(encounter.id),
          date: Value(_date),
          // Ad değiştiyse eski kod artık geçerli değildir.
          code: Value(existing?.name == dxName ? existing?.code : null),
        ),
      );
    }

    if (_followUp != null) {
      await repo.save(
        repo.db.appointments,
        AppointmentsCompanion.insert(
          profileId: profileId,
          start: _followUp!,
          title: const Value('Kontrol'),
          practitioner: Value(encounter.practitioner),
          location: Value(encounter.location),
        ),
      );
      await rescheduleNotifications(ref);
    }
    _saved = encounter;
  }

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
    title: _isNew ? 'Doktor ziyareti ekle' : 'Ziyareti düzenle',
    canSave: _date != null,
    onSave: _save,
    result: () => _saved,
    children: [
      DateField(
        label: 'Ziyaret tarihi *',
        value: _date,
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        onChanged: (v) => setState(() => _date = v),
      ),
      formGap,
      TextField(
        controller: _location,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Hastane / klinik',
          hintText: 'Örn. Şehir Hastanesi',
        ),
      ),
      formGap,
      TextField(
        controller: _doctor,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Doktor / bölüm',
          hintText: 'Örn. Dr. Elif Kaya, KBB',
        ),
      ),
      formGap,
      TextField(
        controller: _complaint,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Neden gittiniz?',
          hintText: 'Örn. Boğaz ağrısı, ateş',
        ),
      ),
      formGap,
      SuggestField(
        controller: _diagnosis,
        label: 'Doktorun söylediği tanı',
        hint: 'Örn. Bademcik iltihabı',
        suggestions: conditionSuggestions,
      ),
      formGap,
      TextField(
        controller: _plan,
        textCapitalization: TextCapitalization.sentences,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: 'Doktorun önerileri',
          hintText: 'Örn. Bol sıvı, 1 hafta sonra kontrol',
        ),
      ),
      if (_isNew) ...[
        formGap,
        DateField(
          label: 'Kontrol randevusu (varsa)',
          value: _followUp,
          withTime: true,
          allowEmpty: true,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          onChanged: (v) => setState(() => _followUp = v),
        ),
      ],
      formGap,
      TextField(
        controller: _note,
        textCapitalization: TextCapitalization.sentences,
        maxLines: null,
        decoration: const InputDecoration(labelText: 'Notlarım'),
      ),
    ],
  );
}
