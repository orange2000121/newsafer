import 'package:flutter/material.dart';

class CustomTriangleClipper extends CustomClipper<Path> {
  double w = 20, h = 20;
  @override
  Path getClip(Size size) {
    double x = size.width, y = size.height;
    final path = Path();
    path.moveTo((x - w) / 2, y - h);
    path.lineTo((x + w) / 2, y - h);
    path.lineTo(x / 2, y);
    path.lineTo((x - w) / 2, y - h);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
