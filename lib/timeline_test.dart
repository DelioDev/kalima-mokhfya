
import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    super.key,
    this.currentStep = 0,
  });

  final int currentStep;

  static const Color activeColor = Color(0xFF2875F5);
  static const Color inactiveColor = Color(0xFFD5D7DA);

  final List<_TimelineItem> items = const [
    _TimelineItem(
      title: 'Pending',
      time: '12:26 PM',
      icon: Icons.hourglass_empty,
    ),
    _TimelineItem(
      title: 'Heading\nto business',
      time: '12:26 PM',
      icon: Icons.storefront_outlined,
    ),
    _TimelineItem(
      title: 'Picked-up',
      time: '',
      icon: Icons.back_hand_outlined,
    ),
    _TimelineItem(
      title: 'Delivered',
      time: '',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double timelineWidth = 650;

          return SizedBox(
            width: math.max(
              constraints.maxWidth,
              timelineWidth,
            ),
            height: 235,
            child: Stack(
              children: [
                // Connecting dashed lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: TimelinePainter(
                      currentStep: currentStep,
                    ),
                  ),
                ),

                // Timeline steps
                ...List.generate(items.length, (index) {
                  final double x = [
                    0.12,
                    0.37,
                    0.63,
                    0.88,
                  ][index];

                  return Positioned(
                    left: x * math.max(
                      constraints.maxWidth,
                      timelineWidth,
                    ) - 65,
                    top: 0,
                    width: 130,
                    height: 235,
                    child: TimelineStep(
                      item: items[index],
                      isActive: index <= currentStep,
                      isCurrent: index == currentStep,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimelineStep extends StatelessWidget {
  const TimelineStep({
    super.key,
    required this.item,
    required this.isActive,
    required this.isCurrent,
  });

  final _TimelineItem item;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? OrderTimeline.activeColor
        : OrderTimeline.inactiveColor;

    return Column(
      children: [
        SizedBox(
          height: 85,
          child: Center(
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                color: Color(0xFF252B38),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.icon,
            size: 30,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          item.time,
          style: TextStyle(
            fontSize: 18,
            color: isActive
                ? const Color(0xFF747984)
                : Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _TimelineItem {
  final String title;
  final String time;
  final IconData icon;

  const _TimelineItem({
    required this.title,
    required this.time,
    required this.icon,
  });
}

class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.currentStep,
  });

  final int currentStep;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * 0.12, 132),
      Offset(size.width * 0.37, 132),
      Offset(size.width * 0.63, 132),
      Offset(size.width * 0.88, 132),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      final path = Path()
        ..moveTo(points[i].dx, points[i].dy)
        ..cubicTo(
          points[i].dx + size.width * 0.09,
          points[i].dy + 35,
          points[i + 1].dx - size.width * 0.09,
          points[i + 1].dy - 35,
          points[i + 1].dx,
          points[i + 1].dy,
        );

      final paint = Paint()
        ..color = i < currentStep
            ? OrderTimeline.activeColor
            : OrderTimeline.inactiveColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
  ) {
    const double dashLength = 10;
    const double gapLength = 9;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double end = math.min(
          distance + dashLength,
          metric.length,
        );

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep;
  }
}
