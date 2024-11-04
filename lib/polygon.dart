import 'package:flutter/material.dart';

import 'base_draw.dart';
import 'model/lat_lng.dart';


class Polygon extends BaseDraw {
  final String polygonId;
  final List<customLatLng> points;
  final List<List<customLatLng>>? holes;

  Polygon({
    required this.polygonId,
    required this.points,
    this.holes,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
  });
}
