import 'dart:ui';

import 'base_draw.dart';
import 'model/lat_lng.dart';



class Circle extends BaseDraw {
  final String circleId;
  final LatLng center;
  double? radius;

  Circle({
    required this.circleId,
    required this.center,
    this.radius,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
  });
}
