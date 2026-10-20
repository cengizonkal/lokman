import 'package:drift/drift.dart' show Insertable, TableInfo;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';

/// Kayıt listesi sayfası: boşken açıklama, doluyken liste ve "Ekle" düğmesi.
class RecordListPage extends StatelessWidget {
  const RecordListPage({
    super.key,
    required this.title,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.children,
    this.addLabel,
    this.onAdd,
  });

  final String title;
  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String? addLabel;
  final VoidCallback? onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    floatingActionButton: isEmpty || onAdd == null
        ? null
        : FloatingActionButton.extended(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(addLabel ?? 'Ekle'),
          ),
    body: isEmpty
        ? EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
            actionLabel: onAdd == null ? null : addLabel,
            onAction: onAdd,
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: children,
          ),
  );
}

/// Listedeki tek kayıt kartı.
class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.title,
    required this.source,
    required this.onTap,
    this.subtitle,
    this.originName,
    this.leading,
    this.trailing,
    this.highlight = false,
  });

  final String title;
  final String? subtitle;
  final String source;
  final String? originName;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: highlight ? theme.colorScheme.errorContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 16)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SourceBadge(source: source, originName: originName),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kayıt ayrıntısı. Klinikten gelen kayıtlar salt okunurdur.
Future<void> showRecordSheet(
  BuildContext context, {
  required String title,
  required String source,
  String? originName,
  required List<Widget> details,
  VoidCallback? onEdit,
  Future<void> Function()? onDelete,
  List<Widget> actions = const [],
}) => showModalBottomSheet(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final fromClinic = source == RecordSource.clinic;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: SourceBadge(source: source, originName: originName),
            ),
            const SizedBox(height: 8),
            ...details,
            if (fromClinic)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Bu kayıt ${originName ?? 'klinik'} tarafından gönderildi; '
                  'değiştirilemez.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            ...actions,
            if (!fromClinic && onEdit != null) ...[
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Düzenle'),
              ),
              const SizedBox(height: 8),
            ],
            if (onDelete != null)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await onDelete();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Sil'),
              ),
          ],
        ),
      ),
    );
  },
);

/// Kaydı siler ve "Geri al" seçeneği sunar.
Future<void> deleteWithUndo<T extends RecordColumns, D>(
  BuildContext context,
  WidgetRef ref,
  TableInfo<T, D> table,
  String id,
  Insertable<D> row, {
  String message = 'Kayıt silindi',
}) async {
  final repo = ref.read(repositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  await repo.deleteRecord(table, id);
  await rescheduleNotifications(ref);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Geri al',
          onPressed: () async {
            await repo.restore(table, row);
            await rescheduleNotifications(ref);
          },
        ),
      ),
    );
}

/// Kayıt formu iskeleti.
class RecordFormScaffold extends StatelessWidget {
  const RecordFormScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.canSave,
    required this.onSave,
    this.result,
  });

  final String title;
  final List<Widget> children;
  final bool canSave;
  final Future<void> Function() onSave;

  /// Kaydettikten sonra formu açana döndürülecek değer.
  final Object? Function()? result;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(padding: const EdgeInsets.all(16), children: children),
    bottomNavigationBar: BottomButton(
      label: 'Kaydet',
      onPressed: canSave
          ? () async {
              await onSave();
              if (context.mounted) Navigator.pop(context, result?.call());
            }
          : null,
    ),
  );
}

Future<void> openForm(BuildContext context, Widget form) =>
    Navigator.of(context)
        .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => form));

const formGap = SizedBox(height: 16);

String? emptyToNull(String s) => s.trim().isEmpty ? null : s.trim();
