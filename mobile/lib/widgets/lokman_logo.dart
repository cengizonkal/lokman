import 'package:flutter/material.dart';

/// Lokman logosu: renkli daire üzerinde beyaz kalp, kalbin içinde hilal oyuğu.
/// Geometri uygulama simgesiyle aynıdır (kaynak: branding/render_icons.py).
class LokmanLogo extends StatelessWidget {
  const LokmanLogo({super.key, this.size = 72, this.color});

  final double size;

  /// Daire rengi; verilmezse temanın birincil rengi.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lokman',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(color ?? Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.color);

  final Color color;

  // 48x48 birimlik alanda kalp ve hilal (render_icons.py ile aynı değerler).
  static Path _mark() {
    return Path()
      ..moveTo(24, 46.3)
      ..lineTo(21.1, 43.66)
      ..cubicTo(10.8, 34.32, 4, 28.16, 4, 20.6)
      ..cubicTo(4, 14.44, 8.84, 9.6, 15, 9.6)
      ..cubicTo(18.48, 9.6, 21.82, 11.22, 24, 13.78)
      ..cubicTo(26.18, 11.22, 29.52, 9.6, 33, 9.6)
      ..cubicTo(39.16, 9.6, 44, 14.44, 44, 20.6)
      ..cubicTo(44, 28.16, 37.2, 34.32, 26.9, 43.68)
      ..close()
      ..moveTo(25.55, 17.44)
      ..arcToPoint(
        const Offset(31.04, 32.36),
        radius: const Radius.circular(10),
        largeArc: true,
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(25.55, 17.44),
        radius: const Radius.circular(8.2),
      )
      ..close()
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 48;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      Paint()..color = color,
    );
    canvas
      ..save()
      ..scale(unit)
      ..translate(24, 24)
      ..scale(0.72)
      ..translate(-24, -27.5)
      ..drawPath(_mark(), Paint()..color = Colors.white)
      ..restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.color != color;
}
