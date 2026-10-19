import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/format.dart';
import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';
import 'profile_form.dart';

/// Üst çubuktaki profil düğmesi: seçili kişiyi gösterir, dokununca aile
/// üyeleri arasında geçiş sağlar.
class ProfileButton extends ConsumerWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showProfileSheet(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(profile, radius: 16),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  profile.firstName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showProfileSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => const _ProfileSheet(),
);

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final current = ref.watch(currentProfileProvider);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Kimin kayıtlarına bakıyorsunuz?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in profiles)
                  ListTile(
                    leading: ProfileAvatar(p),
                    title: Text(profileName(p)),
                    subtitle: p.birthDate == null
                        ? null
                        : Text(ageText(p.birthDate!, DateTime.now())),
                    trailing: p.id == current?.id
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      selectProfile(ref, p.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: const Text('Aile üyesi ekle'),
            subtitle: const Text(
              'Çocuğunuz, eşiniz ya da bakımını üstlendiğiniz biri',
            ),
            onTap: () async {
              Navigator.pop(context);
              await openProfileEditor(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Profilleri düzenle'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profiles');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Profil ekler ya da düzenler. Yeni profil eklenince o profile geçilir.
Future<void> openProfileEditor(BuildContext context, {Profile? profile}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfileEditorScreen(profile: profile),
      ),
    );

class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key, this.profile});

  final Profile? profile;

  @override
  ConsumerState<ProfileEditorScreen> createState() =>
      _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  late final ProfileFormData _data = widget.profile == null
      ? ProfileFormData()
      : ProfileFormData.from(widget.profile!);

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    if (widget.profile == null) {
      final id = await repo.addProfile(_data.toCompanion());
      await selectProfile(ref, id);
    } else {
      await repo.updateProfile(_data.applyTo(widget.profile!));
    }
    await rescheduleNotifications(ref);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.profile == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Aile üyesi ekle' : 'Profili düzenle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileFields(
            data: _data,
            autofocus: isNew,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
      bottomNavigationBar: BottomButton(
        label: 'Kaydet',
        onPressed: _data.isValid ? _save : null,
      ),
    );
  }
}

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Profiller')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openProfileEditor(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          for (final p in profiles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  leading: ProfileAvatar(p, radius: 24),
                  title: Text(profileName(p)),
                  subtitle: Text(
                    [
                      if (p.birthDate != null)
                        ageText(p.birthDate!, DateTime.now()),
                      ?p.bloodType,
                    ].join(' · '),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await openProfileEditor(context, profile: p);
                      } else if (v == 'delete') {
                        await _delete(context, ref, p, profiles.length);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                      PopupMenuItem(value: 'delete', child: Text('Sil')),
                    ],
                  ),
                  onTap: () => openProfileEditor(context, profile: p),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Profile p,
    int count,
  ) async {
    if (count <= 1) {
      showMessage(context, 'En az bir profil kalmalı.');
      return;
    }
    final ok = await confirm(
      context,
      title: '${profileName(p)} silinsin mi?',
      message:
          'Bu kişiye ait tüm ilaç, aşı, ölçüm ve diğer kayıtlar telefondan '
          'kalıcı olarak silinir. Önce verilerini dışa aktarmak isteyebilirsiniz.',
    );
    if (!ok) return;
    await ref.read(repositoryProvider).deleteProfile(p.id);
    await rescheduleNotifications(ref);
  }
}
