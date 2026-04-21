import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures the garden view, adds a watermark, and shares.
class GardenShareService {
  GardenShareService._();

  static Future<void> captureAndShare(
    GlobalKey repaintBoundaryKey,
    String viewLabel,
  ) async {
    final boundary = repaintBoundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);

    // Add watermark via Canvas overlay
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    // Watermark text
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Built in Amal \u00B7 amal-app.com',
        style: TextStyle(
          color: Color(0xCCFFF8DC),
          fontSize: 33, // ~11px * 3.0 pixel ratio
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(16 * 3.0, image.height - tp.height - 16 * 3.0),
    );

    final picture = recorder.endRecording();
    final watermarked = await picture.toImage(image.width, image.height);
    final byteData =
        await watermarked.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();

    // Write to temp file
    final dir = await getTemporaryDirectory();
    final safeName = viewLabel.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${dir.path}/amal_garden_$safeName.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My Jannah Garden in Amal \u00B7 amal-app.com',
    );
  }
}
