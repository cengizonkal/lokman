import 'package:flutter/material.dart';

/// Lokman logosu: beyaz karo üzerinde mavi çerçeve, içinde ters üçgen.
/// Geometri uygulama simgesiyle aynıdır (kaynak: branding/render_icons.py).
class LokmanLogo extends StatelessWidget {
  const LokmanLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lokman',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: const _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  static const _deepBlue = Color(0xFF0D47A1);
  static const _blue = Color(0xFF1E88E5);

  // 48x48 birimlik alanda (render_icons.py çıktısıyla aynı değerler).
  static Path _frameOuter() {
    return Path()
      ..moveTo(13, 4)
      ..lineTo(35, 4)
      ..arcToPoint(const Offset(44, 13), radius: const Radius.circular(9))
      ..lineTo(44, 35)
      ..arcToPoint(const Offset(35, 44), radius: const Radius.circular(9))
      ..lineTo(13, 44)
      ..arcToPoint(const Offset(4, 35), radius: const Radius.circular(9))
      ..lineTo(4, 13)
      ..arcToPoint(const Offset(13, 4), radius: const Radius.circular(9))
      ..close();
  }

  static Path _frame() {
    return _frameOuter()
      ..moveTo(13, 7.6)
      ..lineTo(35, 7.6)
      ..arcToPoint(const Offset(40.4, 13), radius: const Radius.circular(5.4))
      ..lineTo(40.4, 35)
      ..arcToPoint(const Offset(35, 40.4), radius: const Radius.circular(5.4))
      ..lineTo(13, 40.4)
      ..arcToPoint(const Offset(7.6, 35), radius: const Radius.circular(5.4))
      ..lineTo(7.6, 13)
      ..arcToPoint(const Offset(13, 7.6), radius: const Radius.circular(5.4))
      ..close()
      ..fillType = PathFillType.evenOdd;
  }

  static Path _triangle() {
    return Path()
      ..moveTo(16, 13.07)
      ..lineTo(32, 13.07)
      ..arcToPoint(const Offset(35.46, 19.07), radius: const Radius.circular(4))
      ..lineTo(27.46, 32.93)
      ..arcToPoint(const Offset(20.54, 32.93), radius: const Radius.circular(4))
      ..lineTo(12.54, 19.07)
      ..arcToPoint(const Offset(16, 13.07), radius: const Radius.circular(4))
      ..close()
      ..moveTo(16, 16.67)
      ..lineTo(32, 16.67)
      ..arcToPoint(
        const Offset(32.35, 17.27),
        radius: const Radius.circular(0.4),
      )
      ..lineTo(24.35, 31.13)
      ..arcToPoint(
        const Offset(23.65, 31.13),
        radius: const Radius.circular(0.4),
      )
      ..lineTo(15.65, 17.27)
      ..arcToPoint(const Offset(16, 16.67), radius: const Radius.circular(0.4))
      ..close()
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Çerçeve 4..44 birim; logoyu kutuya tam sığdır.
    final unit = size.shortestSide / 40;
    canvas
      ..save()
      ..scale(unit)
      ..translate(-4, -4)
      ..drawPath(_frameOuter(), Paint()..color = Colors.white)
      ..drawPath(_frame(), Paint()..color = _deepBlue)
      ..drawPath(_triangle(), Paint()..color = _blue)
      ..restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
