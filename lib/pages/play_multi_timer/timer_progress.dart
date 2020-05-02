import 'package:flutter/material.dart';
import 'dart:math';
class TimerPainter extends CustomPainter {

  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;
  final double thickness;
  final double radiusFraction;


  TimerPainter(this.animation, this.backgroundColor, this.color, this.thickness,
    this.radiusFraction): super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {

    Offset center = Offset(size.width/2, size.height/2);
    double radius = min(size.width*radiusFraction,size.height*radiusFraction);

    Paint paint = new Paint()
        ..strokeCap = StrokeCap.square
        ..strokeWidth = thickness
        ..color = backgroundColor
        ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);

    paint
    ..color = color
    ..strokeWidth = thickness + 2.0;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi/2,
      animation.value * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value || color != old.color;
  }

}