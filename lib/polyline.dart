import 'package:flutter/material.dart';

import 'base_draw.dart';
import 'model/lat_lng.dart';


class Polyline extends BaseDraw {
  final String polylineId;
  final List<customLatLng> points;

  // Polyline({
  //   required this.polylineId,
  //   required this.points,
  //   super.strokeWidth,
  //   super.strokeColor,
  //   super.strokeOpacity,
  //   super.strokeStyle,
  //   super.fillColor,
  //   super.fillOpacity,
  // });

  Polyline({
    required this.polylineId,
    required this.points,
    int? strokeWidth,
    Color? strokeColor,
    double? strokeOpacity,
    String? strokeStyle,
    Color? fillColor,
    double? fillOpacity,
  }) {
    this.strokeWidth = strokeWidth;
    this.strokeColor = strokeColor;
    this.strokeOpacity = strokeOpacity;
    this.strokeStyle = strokeStyle;
    this.fillColor = fillColor;
    this.fillOpacity = fillOpacity;
  }
}
