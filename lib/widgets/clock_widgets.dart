part of '../main.dart';

class ClockFace extends StatelessWidget {
  const ClockFace({
    super.key,
    required this.seconds,
    required this.running,
    required this.completed,
  });

  final int seconds;
  final bool running;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: CustomPaint(
        painter: ClockPainter(
          seconds: seconds,
          running: running,
          completed: completed,
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter({
    required this.seconds,
    required this.running,
    required this.completed,
  });

  final int seconds;
  final bool running;
  final bool completed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final progress = running
        ? (seconds % 3600) / 3600
        : completed
            ? 1.0
            : 0.0;
    final bg = Paint()..color = Colors.white;
    final ringBg = Paint()
      ..color = const Color(0xffdbe7e4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    final ring = Paint()
      ..color = const Color(0xff178a53)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 7, bg);
    canvas.drawCircle(center, radius - 7, ringBg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 7),
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      ring,
    );

    final tickPaint = Paint()
      ..color = const Color(0xff9ccac1)
      ..strokeWidth = 1;
    for (var i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final inner = radius - (i % 5 == 0 ? 34 : 24);
      final outer = radius - 18;
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        tickPaint,
      );
    }

    void hand(double degrees, double length, double width, Color color) {
      final angle = (degrees - 90) * math.pi / 180;
      final handPaint = Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle) * length, math.sin(angle) * length),
        handPaint,
      );
    }

    hand(seconds / 3600 * 30, 44, 5, const Color(0xff17212b));
    hand(seconds / 60 * 6, 66, 4, const Color(0xff1d6f68));
    hand(seconds * 6, 78, 2, const Color(0xffa1432f));
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xff17212b));
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) =>
      oldDelegate.seconds != seconds ||
      oldDelegate.running != running ||
      oldDelegate.completed != completed;
}
