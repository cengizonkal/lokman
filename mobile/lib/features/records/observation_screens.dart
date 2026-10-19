import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../domain/catalog.dart';
import '../../widgets/common.dart';
import 'record_widgets.dart';

Future<void> openObservationForm(
  BuildContext context, {
  Observation? edit,
  String? typeKey,
}) => openForm(context, ObservationForm(edit: edit, initialType: typeKey));

IconData observationIcon(String key) => switch (key) {
  'bp' => Icons.favorite_outline,
  'pulse' => Icons.monitor_heart_outlined,
  'glucose' => Icons.water_drop_outlined,
  'weight' => Icons.monitor_weight_outlined,
  'height' => Icons.height,
  'temp' => Icons.thermostat,
  'spo2' => Icons.air,
  _ => Icons.analytics_outlined,
};

/// Değer normal aralığın dışında mı? (Yalnızca bilgi amaçlı.)
bool isOutOfRange(Observation o) {
  final t = observationTypeByKey(o.typeKey);
  if (t == null || o.value == null) return false;
  if (t.normalHigh != null && o.value! > t.normalHigh!) return true;
  if (t.normalLow != null && o.value! < t.normalLow!) return true;
  if (o.typeKey == 'bp' && o.value2 != null && o.value2! > 90) return true;
  return false;
}

class ObservationsScreen extends ConsumerStatefulWidget {
  const ObservationsScreen({super.key});

  @override
  ConsumerState<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends ConsumerState<ObservationsScreen> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final all = ref.watch(observationsProvider(profile.id)).value ?? const [];
    final types = <String>{for (final o in all) o.typeKey}.toList();
    final selected = _type != null && types.contains(_type)
        ? _type
        : (types.isEmpty ? null : types.first);
    final items = all.where((o) => o.typeKey == selected).toList();
    final now = DateTime.now();

    String typeName(String key) =>
        observationTypeByKey(key)?.nameTr ??
        all.firstWhere((o) => o.typeKey == key).name;

    return RecordListPage(
      title: 'Ölçümler',
      isEmpty: all.isEmpty,
      emptyIcon: Icons.monitor_heart_outlined,
      emptyTitle: 'Henüz ölçüm yok',
      emptyMessage:
          'Tansiyon, şeker, kilo, ateş gibi ölçümlerinizi kaydedin; '
          'değişimi grafikte görün.',
      addLabel: 'Ölçüm ekle',
      onAdd: () => openObservationForm(context, typeKey: selected),
      children: [
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in types)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(observationIcon(t), size: 18),
                    label: Text(typeName(t)),
                    selected: t == selected,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (items.where((o) => o.value != null).length >= 2)
          _TrendChart(items: items),
        const SizedBox(height: 8),
        for (final o in items)
          RecordCard(
            title: observationValue(o),
            subtitle: [
              '${relativeDay(o.effectiveAt, now)}, ${formatTime(o.effectiveAt)}',
              if (isOutOfRange(o)) 'Normal aralığın dışında',
              if (o.value != null) ?o.note,
            ].join(' · '),
            source: o.source,
            originName: o.originName,
            leading: Icon(
              observationIcon(o.typeKey),
              color: isOutOfRange(o)
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            onTap: () => showRecordSheet(
              context,
              title: '${o.name}: ${observationValue(o)}',
              source: o.source,
              originName: o.originName,
              details: [
                InfoRow('Tarih', formatDayTime(o.effectiveAt)),
                InfoRow('Not', o.note),
              ],
              onEdit: () => openObservationForm(context, edit: o),
              onDelete: () => deleteWithUndo(
                context,
                ref,
                ref.read(databaseProvider).observations,
                o.id,
                o,
              ),
            ),
          ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.items});

  final List<Observation> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = items.where((o) => o.value != null).toList()
      ..sort((a, b) => a.effectiveAt.compareTo(b.effectiveAt));
    final recent = points.length > 30
        ? points.sublist(points.length - 30)
        : points;
    double x(Observation o) =>
        o.effectiveAt.millisecondsSinceEpoch / Duration.millisecondsPerDay;
    final hasSecond = recent.any((o) => o.value2 != null);

    LineChartBarData line(List<FlSpot> spots, Color color) => LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 3,
      isCurved: false,
      dotData: const FlDotData(show: true),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _interval(recent, x),
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        formatDayShort(
                          DateTime.fromMillisecondsSinceEpoch(
                            (v * Duration.millisecondsPerDay).round(),
                          ),
                        ),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
              ),
              lineTouchData: const LineTouchData(enabled: true),
              lineBarsData: [
                line([
                  for (final o in recent) FlSpot(x(o), o.value!),
                ], scheme.primary),
                if (hasSecond)
                  line([
                    for (final o in recent)
                      if (o.value2 != null) FlSpot(x(o), o.value2!),
                  ], scheme.tertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _interval(List<Observation> items, double Function(Observation) x) {
    final span = x(items.last) - x(items.first);
    return span <= 0 ? 1 : (span / 3).clamp(1, 3650).toDouble();
  }
}

class ObservationForm extends ConsumerStatefulWidget {
  const ObservationForm({super.key, this.edit, this.initialType});

  final Observation? edit;
  final String? initialType;

  @override
  ConsumerState<ObservationForm> createState() => _ObservationFormState();
}

class _ObservationFormState extends ConsumerState<ObservationForm> {
  late String _typeKey =
      widget.edit?.typeKey ??
      (observationTypeByKey(widget.initialType ?? '') != null
          ? widget.initialType!
          : 'bp');
  late final _value = TextEditingController(text: _fmt(widget.edit?.value));
  late final _value2 = TextEditingController(text: _fmt(widget.edit?.value2));
  late final _note = TextEditingController(text: widget.edit?.note ?? '');
  late DateTime _at = widget.edit?.effectiveAt ?? DateTime.now();

  static String _fmt(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : '$v');

  ObservationType? get _type => observationTypeByKey(_typeKey);

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _valid {
    if (_parse(_value) == null) return false;
    if (_type?.hasTwoValues == true && _parse(_value2) == null) return false;
    return true;
  }

  @override
  void dispose() {
    _value.dispose();
    _value2.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final t = _type;
    final base =
        widget.edit ??
        Observation(
          id: newId(),
          profileId: ref.read(currentProfileProvider)!.id,
          source: RecordSource.self,
          createdAt: DateTime.now(),
          typeKey: _typeKey,
          name: '',
          unit: '',
          effectiveAt: _at,
        );
    final saved = base.copyWith(
      typeKey: _typeKey,
      code: Value(t?.loinc ?? base.code),
      name: t?.nameTr ?? base.name,
      unit: t?.unit ?? base.unit,
      value: Value(_parse(_value)),
      value2: Value(t?.hasTwoValues == true ? _parse(_value2) : null),
      effectiveAt: _at,
      note: Value(emptyToNull(_note.text)),
    );
    await repo.save(repo.db.observations, saved);
    if (isOutOfRange(saved) && mounted) {
      showMessage(
        context,
        'Bu değer genel normal aralığın dışında görünüyor. Gerekirse '
        'doktorunuza danışın.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = _type;
    final numberInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return RecordFormScaffold(
      title: widget.edit == null ? 'Ölçüm ekle' : 'Ölçümü düzenle',
      canSave: _valid,
      onSave: _save,
      children: [
        if (widget.edit == null ||
            widget.edit!.source == RecordSource.self) ...[
          Text('Ne ölçtünüz?', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in observationTypes)
                ChoiceChip(
                  avatar: Icon(observationIcon(type.key), size: 18),
                  label: Text(type.nameTr),
                  selected: type.key == _typeKey,
                  onSelected: (_) => setState(() => _typeKey = type.key),
                ),
            ],
          ),
          formGap,
        ],
        if (t?.hasTwoValues == true)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _value,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: numberInput,
                  decoration: InputDecoration(
                    labelText: 'Büyük',
                    hintText: '120',
                    suffixText: t!.unit,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('/', style: TextStyle(fontSize: 28)),
              ),
              Expanded(
                child: TextField(
                  controller: _value2,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: numberInput,
                  decoration: InputDecoration(
                    labelText: 'Küçük',
                    hintText: '80',
                    suffixText: t.unit,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          )
        else
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: numberInput,
            decoration: InputDecoration(
              labelText: 'Değer',
              suffixText: t?.unit ?? widget.edit?.unit,
            ),
            onChanged: (_) => setState(() {}),
          ),
        formGap,
        DateField(
          label: 'Ölçüm zamanı',
          value: _at,
          withTime: true,
          lastDate: DateTime.now(),
          onChanged: (v) => setState(() => _at = v ?? _at),
        ),
        formGap,
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Not (isteğe bağlı)',
            hintText: 'Örn. Yemekten sonra',
          ),
        ),
      ],
    );
  }
}
