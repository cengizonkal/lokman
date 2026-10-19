import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/catalog.dart';
import '../../domain/dose_schedule.dart';
import '../../widgets/common.dart';

Future<void> openMedicationWizard(BuildContext context, {Medication? edit}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MedicationWizard(edit: edit),
      ),
    );

const presetTimes = [
  ('Sabah', DoseTime(8, 0)),
  ('Öğle', DoseTime(13, 0)),
  ('Akşam', DoseTime(20, 0)),
  ('Gece', DoseTime(23, 0)),
];

const durationPresets = [3, 5, 7, 10, 14, 30];

/// Dört adımda ilaç ekleme: ad → doz → saatler → süre.
class MedicationWizard extends ConsumerStatefulWidget {
  const MedicationWizard({super.key, this.edit});

  final Medication? edit;

  @override
  ConsumerState<MedicationWizard> createState() => _MedicationWizardState();
}

class _MedicationWizardState extends ConsumerState<MedicationWizard> {
  late final Medication? _edit = widget.edit;
  late final _name = TextEditingController(text: _edit?.name ?? '');
  late final _dose = TextEditingController(text: _edit?.dose ?? '');
  late final _note = TextEditingController(text: _edit?.note ?? '');
  late final _days = TextEditingController(
    text: (_edit?.durationDays ?? 7).toString(),
  );
  late final Set<DoseTime> _times = _edit == null
      ? {const DoseTime(8, 0)}
      : DoseTime.parseList(_edit.timesOfDay).toSet();
  late bool _continuous = _edit != null && _edit.durationDays == null;
  late DateTime _start = _edit?.startDate ?? dateOnly(DateTime.now());
  int _step = 0;

  bool get _fromClinic => _edit?.source == RecordSource.clinic;

  static const _titles = [
    'İlacın adı ne?',
    'Her seferinde ne kadar?',
    'Hangi saatlerde?',
    'Ne kadar süre kullanılacak?',
  ];

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _note.dispose();
    _days.dispose();
    super.dispose();
  }

  int? get _durationDays {
    if (_continuous) return null;
    final v = int.tryParse(_days.text.trim());
    return v == null || v <= 0 ? null : v;
  }

  bool get _canContinue => switch (_step) {
    0 => _name.text.trim().isNotEmpty,
    3 => _continuous || _durationDays != null,
    _ => true,
  };

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final profile = ref.read(currentProfileProvider)!;
    final note = _note.text.trim();
    if (_edit == null) {
      await repo.save(
        repo.db.medications,
        MedicationsCompanion.insert(
          profileId: profile.id,
          name: _name.text.trim(),
          dose: Value(_dose.text.trim()),
          timesOfDay: Value(DoseTime.formatList(_times)),
          startDate: _start,
          durationDays: Value(_durationDays),
          note: Value(note.isEmpty ? null : note),
        ),
      );
    } else {
      await repo.save(
        repo.db.medications,
        _edit.copyWith(
          name: _name.text.trim(),
          dose: _dose.text.trim(),
          timesOfDay: DoseTime.formatList(_times),
          startDate: _start,
          durationDays: Value(_durationDays),
          note: Value(note.isEmpty ? null : note),
          stoppedAt: const Value(null),
        ),
      );
    }
    await rescheduleNotifications(ref);
    if (!mounted) return;
    Navigator.pop(context);
    showMessage(
      context,
      _times.isEmpty
          ? 'İlaç kaydedildi.'
          : 'İlaç kaydedildi. Saati gelince hatırlatacağız.',
    );
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  Future<void> _addCustomTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: 'İlaç saati',
    );
    if (t != null) setState(() => _times.add(DoseTime(t.hour, t.minute)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_edit == null ? 'İlaç ekle' : 'İlacı düzenle'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(value: (_step + 1) / 4),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Adım ${_step + 1} / 4',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(_titles[_step], style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            ...switch (_step) {
              0 => _nameStep(),
              1 => _doseStep(),
              2 => _timesStep(theme),
              _ => _durationStep(theme),
            },
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Geri'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _canContinue ? _next : null,
                  child: Text(_step < 3 ? 'Devam' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _nameStep() => [
    TextField(
      controller: _name,
      autofocus: _edit == null,
      readOnly: _fromClinic,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'İlaç adı',
        hintText: 'Örn. Parol 500 mg',
        helperText: _fromClinic
            ? 'Klinikten gelen ilacın adı değiştirilemez.'
            : 'Kutunun üzerindeki adı yazabilirsiniz.',
      ),
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _canContinue ? _next() : null,
    ),
  ];

  List<Widget> _doseStep() => [
    TextField(
      controller: _dose,
      decoration: const InputDecoration(
        labelText: 'Doz',
        hintText: 'Örn. 1 tablet',
        helperText: 'Bilmiyorsanız boş bırakabilirsiniz.',
      ),
      onChanged: (_) => setState(() {}),
    ),
    QuickChips(
      values: doseSuggestions,
      onTap: (v) => setState(() => _dose.text = v),
    ),
    const SizedBox(height: 20),
    TextField(
      controller: _note,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Not (isteğe bağlı)',
        hintText: 'Örn. Tok karnına',
      ),
    ),
    QuickChips(
      values: const ['Tok karnına', 'Aç karnına', 'Yemekle birlikte'],
      onTap: (v) => setState(() => _note.text = v),
    ),
  ];

  List<Widget> _timesStep(ThemeData theme) {
    final custom =
        _times.where((t) => !presetTimes.any((p) => p.$2 == t)).toList()
          ..sort();
    return [
      Text(
        'Seçtiğiniz saatlerde hatırlatma gelir. Birden fazla seçebilirsiniz.',
        style: theme.textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      for (final (label, time) in presetTimes)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: _times.contains(time),
            onChanged: (v) => setState(
              () => v == true ? _times.add(time) : _times.remove(time),
            ),
            title: Text(label),
            secondary: Text(time.label, style: theme.textTheme.titleMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: theme.colorScheme.surfaceContainerLow,
          ),
        ),
      for (final t in custom)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(t.label, style: theme.textTheme.titleMedium),
            trailing: IconButton(
              tooltip: 'Kaldır',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _times.remove(t)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: theme.colorScheme.surfaceContainerLow,
          ),
        ),
      OutlinedButton.icon(
        onPressed: _addCustomTime,
        icon: const Icon(Icons.more_time),
        label: const Text('Başka saat ekle'),
      ),
      if (_times.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Saat seçmezseniz ilaç “gerektiğinde” kullanılır ve hatırlatma '
            'gelmez.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];
  }

  List<Widget> _durationStep(ThemeData theme) => [
    RadioGroup<bool>(
      groupValue: _continuous,
      onChanged: (v) => setState(() => _continuous = v ?? false),
      child: const Column(
        children: [
          RadioListTile(
            value: false,
            title: Text('Belirli bir süre'),
            subtitle: Text('Örn. antibiyotik, 7 gün'),
          ),
          RadioListTile(
            value: true,
            title: Text('Sürekli kullanıyorum'),
            subtitle: Text('Örn. tansiyon ilacı'),
          ),
        ],
      ),
    ),
    if (!_continuous) ...[
      const SizedBox(height: 12),
      TextField(
        controller: _days,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Kaç gün?',
          suffixText: 'gün',
        ),
        onChanged: (_) => setState(() {}),
      ),
      QuickChips(
        values: [for (final d in durationPresets) '$d gün'],
        onTap: (v) => setState(() => _days.text = v.split(' ').first),
      ),
    ],
    const SizedBox(height: 20),
    DateField(
      label: 'Başlangıç',
      value: _start,
      onChanged: (v) => setState(() => _start = v ?? _start),
    ),
  ];
}
