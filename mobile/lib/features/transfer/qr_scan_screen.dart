import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:http/http.dart' as http;

/// Klinikten alınan QR kodu okur ve sağlık dosyasını indirir. Başarılı
/// olursa dosya metnini döndürür.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  /// Dosya indirilirken kamera söküldüğü için okuma da durur.
  bool _busy = false;
  String? _error;
  bool _cameraFailed = false;

  Future<void> _onScan(Code code) async {
    if (_busy) return;
    final raw = code.text;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      setState(
        () => _error =
            'Bu QR kod bir Lokman sağlık dosyası değil. Kliniğinizin verdiği '
            'kodu okutun.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await http
          .get(uri, headers: {'Accept': 'application/fhir+json'})
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pop(context, const Utf8Decoder().convert(res.bodyBytes));
        return;
      }
      _fail(switch (res.statusCode) {
        410 || 404 =>
          'Bu QR kodun süresi dolmuş ya da daha önce kullanılmış. '
              'Klinikten yeni bir kod isteyin.',
        _ => 'Dosya indirilemedi (hata ${res.statusCode}). Tekrar deneyin.',
      });
    } catch (_) {
      _fail(
        'Dosya indirilemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.',
      );
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  /// Kamera hiç açılamazsa (izin yok, cihazda kamera yok) tarayıcı yerine
  /// açıklama gösterilir; kullanıcı dosya ile aktarmaya yönlendirilir.
  void _onControllerCreated(CameraController? controller, Exception? error) {
    final failed = error != null;
    if (failed == _cameraFailed || !mounted) return;
    setState(() => _cameraFailed = failed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR kod okut')),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_busy)
                    ReaderWidget(
                      onScan: _onScan,
                      onControllerCreated: _onControllerCreated,
                      codeFormat: Format.qrCode,
                      tryInverted: true,
                      cropPercent: 0.6,
                      showGallery: false,
                      showToggleCamera: false,
                      scanDelay: const Duration(milliseconds: 300),
                    ),
                  if (_cameraFailed)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Kamera açılamadı. Ayarlardan Lokman için kamera '
                        'iznini açın ya da dosya ile aktarın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_busy)
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Dosya indiriliyor…',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: _error == null
                ? theme.colorScheme.surfaceContainer
                : theme.colorScheme.errorContainer,
            child: SafeArea(
              top: false,
              child: Text(
                _error ??
                    'Kliniğinizin ekranındaki ya da kâğıttaki QR kodu çerçevenin '
                        'içine getirin.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
