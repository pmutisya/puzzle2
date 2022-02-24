import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageTilePainter extends CustomPainter {
  final ui.Image image;
  final Rect rect;
  final Rect imageRect;
  final double scaleX, scaleY;
  Paint defaultPaint = Paint();

  ImageTilePainter(this.image, {
    required int row, required int col,
    required int rows, required int cols,
    required double outputWidth, required double outputHeight}) :
        scaleX = outputWidth*cols/image.width,
        scaleY = outputHeight*rows/image.height,
        imageRect = Rect.fromLTWH(image.width*col/cols, image.height*row/rows,
            image.width/cols, image.height/rows),
        rect = Rect.fromLTWH(0, 0, outputWidth, outputHeight);

  @override
  bool shouldRepaint(ImageTilePainter oldDelegate) => imageRect != oldDelegate.imageRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(image, imageRect, rect, defaultPaint);
  }
}

