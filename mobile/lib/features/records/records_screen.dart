import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../profiles/profiles_screen.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final counts = profile == null
        ? const <String, int>{}
        : ref.watch(recordCountsProvider(profile.id)).value ?? const {};
    int n(String key) => counts[key] ?? 0;

    final planned = n('immunization_due');
    final tiles = [
      (
        Icons.vaccines_outlined,
        'Aşılar',
        [
          '${n('immunizations')} kayıt',
          if (planned > 0) '$planned planlı',
        ].join(' · '),
        'vaccines',
      ),
      (
        Icons.warning_amber_rounded,
        'Alerjiler',
        '${n('allergies')} kayıt',
        'allergies',
      ),
      (
        Icons.favorite_outline,
        'Kronik hastalıklar',
        '${n('conditions')} kayıt',
        'conditions',
      ),
      (
        Icons.monitor_heart_outlined,
        'Ölçümler',
        '${n('observations')} kayıt',
        'measurements',
      ),
      (
        Icons.event_outlined,
        'Randevular',
        '${n('appointments')} kayıt',
        'appointments',
      ),
      (
        Icons.medical_information_outlined,
        'Muayeneler',
        '${n('encounters')} kayıt',
        'visits',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlar'),
        actions: const [ProfileButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              for (final (icon, title, subtitle, path) in tiles)
                _Tile(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  onTap: () => context.go('/records/$path'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const Spacer(),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
