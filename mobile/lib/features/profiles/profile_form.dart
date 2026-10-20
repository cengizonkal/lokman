import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../widgets/common.dart';

/// Profil bilgileri. Yalnızca ad zorunludur.
class ProfileFormData {
  ProfileFormData({
    this.firstName = '',
    this.lastName = '',
    this.birthDate,
    this.gender,
    this.bloodType,
  });

  factory ProfileFormData.from(Profile p) => ProfileFormData(
    firstName: p.firstName,
    lastName: p.lastName,
    birthDate: p.birthDate,
    gender: genders.contains(p.gender) ? p.gender : null,
    bloodType: p.bloodType,
  );

  String firstName;
  String lastName;
  DateTime? birthDate;
  String? gender;
  String? bloodType;

  bool get isValid => firstName.trim().isNotEmpty;

  ProfilesCompanion toCompanion() => ProfilesCompanion.insert(
    firstName: firstName.trim(),
    lastName: Value(lastName.trim()),
    birthDate: Value(birthDate),
    gender: Value(gender),
    bloodType: Value(bloodType),
  );

  Profile applyTo(Profile p) => p.copyWith(
    firstName: firstName.trim(),
    lastName: lastName.trim(),
    birthDate: Value(birthDate),
    gender: Value(gender),
    bloodType: Value(bloodType),
  );
}

/// Kaydedilen cinsiyet değerleri (FHIR `Patient.gender` ile aynı).
const genders = ['female', 'male'];

const bloodTypes = [
  '0 Rh+',
  '0 Rh-',
  'A Rh+',
  'A Rh-',
  'B Rh+',
  'B Rh-',
  'AB Rh+',
  'AB Rh-',
];

class ProfileFields extends StatefulWidget {
  const ProfileFields({
    super.key,
    required this.data,
    required this.onChanged,
    this.autofocus = false,
  });

  final ProfileFormData data;
  final VoidCallback onChanged;
  final bool autofocus;

  @override
  State<ProfileFields> createState() => _ProfileFieldsState();
}

class _ProfileFieldsState extends State<ProfileFields> {
  late final _first = TextEditingController(text: widget.data.firstName);
  late final _last = TextEditingController(text: widget.data.lastName);

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _update(VoidCallback f) {
    setState(f);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _first,
          autofocus: widget.autofocus,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Ad *'),
          onChanged: (v) => _update(() => d.firstName = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _last,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Soyad'),
          onChanged: (v) => _update(() => d.lastName = v),
        ),
        const SizedBox(height: 16),
        DateField(
          label: 'Doğum tarihi',
          value: d.birthDate,
          allowEmpty: true,
          lastDate: DateTime.now(),
          onChanged: (v) => _update(() => d.birthDate = v),
        ),
        const SizedBox(height: 20),
        Text('Cinsiyet', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String?>(
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'female', label: Text('Kadın')),
            ButtonSegment(value: 'male', label: Text('Erkek')),
          ],
          selected: {if (d.gender != null) d.gender},
          onSelectionChanged: (s) =>
              _update(() => d.gender = s.isEmpty ? null : s.first),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String?>(
          initialValue: d.bloodType,
          decoration: const InputDecoration(labelText: 'Kan grubu'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Bilmiyorum')),
            for (final b in bloodTypes)
              DropdownMenuItem(value: b, child: Text(b)),
          ],
          onChanged: (v) => _update(() => d.bloodType = v),
        ),
      ],
    );
  }
}
