import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/terminology/icd11.dart';
import '../fhir/fhir_common.dart' show FhirSystems, codeSystemLabel;
import 'common.dart';

/// Hastalık / tanı adı alanı: yazarken uygulamaya gömülü ICD-11 kataloğunda
/// arar. Listeden seçilen kayıt kodunu da taşır; kullanıcı kendi yazdığı
/// metni de bırakabilir, o zaman kod boş kalır (kayıt yine tutulur).
///
/// Ad değiştirilirse kod düşer: kod artık o adı göstermiyordur.
class ConceptField extends ConsumerStatefulWidget {
  const ConceptField({
    super.key,
    required this.controller,
    required this.label,
    required this.code,
    required this.codeSystem,
    required this.onCode,
    this.hint,
    this.fallback = const [],
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  /// Kayıtta duran kod ve kod sistemi (yoksa null).
  final String? code;
  final String? codeSystem;

  /// Kod seçildiğinde / düştüğünde çağrılır.
  final void Function(String? code, String? system) onCode;

  /// Katalog henüz yüklenmemişse gösterilecek yaygın adlar.
  final List<String> fallback;
  final bool autofocus;

  /// Metin her değiştiğinde çağrılır (kaydet düğmesinin durumu için).
  final VoidCallback? onChanged;

  @override
  ConsumerState<ConceptField> createState() => _ConceptFieldState();
}

class _ConceptFieldState extends ConsumerState<ConceptField> {
  final _focus = FocusNode();

  /// Kayıttaki kodun gösterdiği ad; metin bundan farklılaşırsa kod düşer.
  String? _codedTitle;

  @override
  void initState() {
    super.initState();
    if (widget.code != null) _codedTitle = widget.controller.text.trim();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.dispose();
    super.dispose();
  }

  void _onText() {
    widget.onChanged?.call();
    if (widget.code != null && widget.controller.text.trim() != _codedTitle) {
      _codedTitle = null;
      widget.onCode(null, null);
    }
  }

  void _select(Icd11Concept concept) {
    _codedTitle = concept.titleTr;
    widget.controller.text = concept.titleTr;
    widget.onCode(concept.code, FhirSystems.icd11);
  }

  void _clearCode() {
    _codedTitle = null;
    widget.onCode(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(icd11Provider).value;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (catalog == null)
          // Katalog okunamadıysa uygulama çalışmaya devam eder: alan yaygın
          // adları önerir, kod boş kalır.
          SuggestField(
            controller: widget.controller,
            label: widget.label,
            hint: widget.hint,
            suggestions: widget.fallback,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
          )
        else
          RawAutocomplete<Icd11Concept>(
            textEditingController: widget.controller,
            focusNode: _focus,
            optionsBuilder: (value) => catalog.search(value.text, limit: 20),
            displayStringForOption: (concept) => concept.titleTr,
            onSelected: _select,
            fieldViewBuilder: (context, controller, focus, onSubmit) =>
                TextField(
                  controller: controller,
                  focusNode: focus,
                  autofocus: widget.autofocus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                  ),
                ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 280,
                    maxWidth: 420,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final concept in options)
                        ListTile(
                          dense: true,
                          title: Text(concept.titleTr),
                          subtitle: Text(
                            [
                              'ICD-11 ${concept.code}',
                              ?catalog.chapterName(concept.chapter),
                            ].join(' · '),
                          ),
                          onTap: () => onSelected(concept),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (widget.code != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${codeSystemLabel(widget.codeSystem) ?? 'Kod'} '
                    '${widget.code}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearCode,
                  child: const Text('Kodu kaldır'),
                ),
              ],
            ),
          )
        else if (catalog != null && widget.controller.text.trim().length >= 3)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Listeden seçerseniz hastalığın ICD-11 kodu da kaydedilir.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
