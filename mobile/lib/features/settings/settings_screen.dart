import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repository.dart';
import '../../widgets/common.dart';
import '../transfer/import_flow.dart';

final _flagProvider = StreamProvider.family<bool, String>(
  (ref, key) => ref
      .watch(repositoryProvider)
      .watchSetting(key)
      .map((v) => v == null || v == '1'),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _toggle(WidgetRef ref, String key, bool value) async {
    await ref.read(repositoryProvider).setFlag(key, value);
    await rescheduleNotifications(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Widget toggle(String key, String title, String subtitle) => SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: ref.watch(_flagProvider(key)).value ?? true,
      onChanged: (v) => _toggle(ref, key, v),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const _Header('Hatırlatmalar'),
          toggle(
            SettingKeys.notifyDoses,
            'İlaç saatleri',
            'İlacın saati gelince bildirim',
          ),
          toggle(
            SettingKeys.notifyVaccines,
            'Aşılar',
            'Aşı gününden bir gün önce ve aşı günü sabah',
          ),
          toggle(
            SettingKeys.notifyAppointments,
            'Randevular',
            'Bir gün önce akşam ve iki saat önce',
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Bildirim iznini kontrol et'),
            subtitle: const Text(
              'Hatırlatma gelmiyorsa buradan izin verin. Pil tasarrufu '
              'ayarları da bildirimleri geciktirebilir.',
            ),
            onTap: () async {
              final service = ref.read(notificationServiceProvider);
              final ok = await service.requestPermissions();
              await rescheduleNotifications(ref);
              if (context.mounted) {
                showMessage(
                  context,
                  ok
                      ? 'Bildirimlere izin verildi.'
                      : 'Bildirim izni kapalı. Telefon ayarlarından Lokman için '
                            'bildirimleri açabilirsiniz.',
                );
              }
            },
          ),
          const _Header('Deneme'),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Örnek klinik dosyasını dene'),
            subtitle: const Text(
              'Klinikten kayıt almanın nasıl göründüğünü örnek bir hastayla '
              '(Ayşe Şahin) görün. İstediğiniz zaman silebilirsiniz.',
            ),
            onTap: () async {
              final text = await rootBundle.loadString(
                'assets/examples/klinik-cikti-ayse.json',
              );
              if (context.mounted) await runImport(context, ref, text);
            },
          ),
          const _Header('Hakkında'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Verileriniz'),
            subtitle: const Text(
              'Tüm kayıtlar yalnızca bu telefonda saklanır; hesap ya da sunucu '
              'yoktur. Uygulama internete yalnızca QR kodla dosya indirirken '
              'bağlanır. Telefonunuzu ekran kilidiyle koruyun ve düzenli '
              'yedek alın.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Tıbbi uyarı'),
            subtitle: const Text(
              'Lokman bir kayıt ve hatırlatma aracıdır; tanı koymaz, tedavi '
              'önermez. Sağlığınızla ilgili kararlar için doktorunuza danışın.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Lokman'),
            subtitle: Text(
              [
                if ((ref.watch(appVersionProvider).value ?? '').isNotEmpty)
                  'Sürüm ${ref.watch(appVersionProvider).value}',
                'Açık kaynak (MIT lisansı)',
              ].join(' · '),
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Lokman',
              applicationVersion: ref.read(appVersionProvider).value,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'github.com/cengizonkal/lokman',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
