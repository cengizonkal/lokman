import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repository.dart';
import '../../widgets/lokman_logo.dart';
import '../profiles/profile_form.dart';

/// İlk açılış: kısa tanıtım + ilk profil + bildirim izni.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _data = ProfileFormData();
  bool _busy = false;

  Future<void> _createProfile() async {
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final id = await repo.addProfile(_data.toCompanion());
    await selectProfile(ref, id);
    if (!mounted) return;
    setState(() {
      _step = 2;
      _busy = false;
    });
  }

  Future<void> _finish({required bool askPermission}) async {
    if (askPermission) {
      await ref.read(notificationServiceProvider).requestPermissions();
    }
    await ref
        .read(repositoryProvider)
        .setFlag(SettingKeys.onboardingDone, true);
    if (mounted) context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_step) {
            0 => _Welcome(onNext: () => setState(() => _step = 1)),
            1 => _FirstProfile(
              data: _data,
              busy: _busy,
              onChanged: () => setState(() {}),
              onBack: () => setState(() => _step = 0),
              onNext: _createProfile,
            ),
            _ => _Permission(
              onAllow: () => _finish(askPermission: true),
              onSkip: () => _finish(askPermission: false),
            ),
          },
        ),
      ),
    );
  }
}

class _Welcome extends ConsumerWidget {
  const _Welcome({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value ?? '';
    Widget point(IconData icon, String title, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 24),
                const Center(child: LokmanLogo(size: 88)),
                const SizedBox(height: 16),
                Text(
                  'Lokman’a hoş geldiniz',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ailenizin sağlık defteri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (version.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Sürüm $version',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 40),
                point(
                  Icons.alarm,
                  'İlaç saatlerini hatırlatır',
                  'Saati gelince bildirim gelir; “Aldım” demeniz yeterli.',
                ),
                point(
                  Icons.folder_shared_outlined,
                  'Her şey tek yerde',
                  'Aşılar, alerjiler, hastalıklar, ölçümler ve randevular.',
                ),
                point(
                  Icons.qr_code_2,
                  'Klinikten kolay aktarım',
                  'Doktorunuzun verdiği QR kodu okutun, kayıtlar gelsin.',
                ),
                point(
                  Icons.lock_outline,
                  'Verileriniz sizde',
                  'Hesap açmanız gerekmez. Bilgiler yalnızca bu telefonda durur.',
                ),
              ],
            ),
          ),
          FilledButton(onPressed: onNext, child: const Text('Başlayalım')),
        ],
      ),
    );
  }
}

class _FirstProfile extends StatelessWidget {
  const _FirstProfile({
    required this.data,
    required this.busy,
    required this.onChanged,
    required this.onBack,
    required this.onNext,
  });

  final ProfileFormData data;
  final bool busy;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('profile'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Geri',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              Text(
                'Bu defteri kimin için tutacaksınız?',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Önce kendinizi ya da bakımını üstlendiğiniz kişiyi ekleyin. '
                'Diğer aile üyelerini sonra ekleyebilirsiniz. Yalnızca ad zorunlu.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ProfileFields(data: data, onChanged: onChanged),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            onPressed: data.isValid && !busy ? onNext : null,
            child: const Text('Devam'),
          ),
        ),
      ],
    );
  }
}

class _Permission extends StatelessWidget {
  const _Permission({required this.onAllow, required this.onSkip});

  final VoidCallback onAllow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: const ValueKey('permission'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(
            Icons.notifications_active_outlined,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Hatırlatmalara izin verin',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'İlaç saatleri, yaklaşan aşılar ve randevular için telefonunuza '
            'bildirim gönderebilmemiz gerekiyor. Bildirimler internetsiz, '
            'telefonun kendisinde kurulur.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onAllow,
            icon: const Icon(Icons.check),
            label: const Text('İzin ver'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onSkip, child: const Text('Şimdi değil')),
        ],
      ),
    );
  }
}
