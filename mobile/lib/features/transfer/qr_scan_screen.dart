import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

/// Klinikten alınan QR kodu okur ve sağlık dosyasını indirir. Başarılı
/// olursa dosya metnini döndürür.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null) return;
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
    await _controller.stop();
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

  Future<void> _fail(String message) async {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR kod okut')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error.errorCode ==
                                MobileScannerErrorCode.permissionDenied
                            ? 'Kamera izni verilmedi. Ayarlardan Lokman için '
                                  'kamera iznini açın ya da dosya ile aktarın.'
                            : 'Kamera açılamadı.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                if (_busy)
                  const ColoredBox(
                    color: Colors.black54,
                    child: Center(
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
                  ),
              ],
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
