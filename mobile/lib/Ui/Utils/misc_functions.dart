import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Uint8List?> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png))
      ?.buffer
      .asUint8List();
}

Future<BitmapDescriptor?> getBitmapFromAssets(String asset) async {
  final Uint8List? markerIcon =
      await getBytesFromAsset('assets/icons/your_location.png', 150);
  if (markerIcon == null) return null;
  return BitmapDescriptor.fromBytes(markerIcon);
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}