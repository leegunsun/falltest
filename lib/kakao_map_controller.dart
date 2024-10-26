import 'dart:convert';
import 'package:dyt/hex_color.dart';

import 'package:dyt/polygon.dart';
import 'package:dyt/polyline.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'circle.dart';
import 'marker.dart';
import 'model/lat_lng.dart';

class KakaoMapController {
  final InAppWebViewController _webViewController;

  InAppWebViewController get webViewController => _webViewController;

  KakaoMapController(this._webViewController);

  addPolyline({Set<Polyline>? polylines}) async {
    if (polylines != null) {
      clearPolyline();
      for (var polyline in polylines) {
        await _webViewController.evaluateJavascript(
            source : "addPolyline('${polyline.polylineId}', '${jsonEncode(polyline.points)}', '${polyline.strokeColor?.toHexColor()}', '${polyline.strokeOpacity}', '${polyline.strokeWidth}');");
      }
    }
  }

  addCircle({Set<Circle>? circles}) async {
    if (circles != null) {
      clearCircle();
      for (var circle in circles) {
        await _webViewController.evaluateJavascript(
            source :  "addCircle('${circle.circleId}', '${jsonEncode(circle.center)}', '${circle.radius}', '${circle.strokeWidth}', '${circle.strokeColor?.toHexColor()}', '${circle.strokeOpacity}');");
      }
    }
  }

  addPolygon({Set<Polygon>? polygons}) async {
    if (polygons != null) {
      clearPolygon();
      for (var polygon in polygons) {
        await _webViewController.evaluateJavascript(
            source : "addPolygon('${polygon.polygonId}', '${jsonEncode(polygon.points)}', '${jsonEncode(polygon.holes)}', '${polygon.strokeWidth}', '${polygon.strokeColor?.toHexColor()}', '${polygon
                .strokeOpacity}', '${polygon.strokeStyle}', '${polygon.fillColor?.toHexColor()}', '${polygon.fillOpacity}');");
      }
    }
  }

  addMarker({List<Marker>? markers}) async {
    if (markers != null) {
      clearMarker();
      for (var marker in markers) {
        await _webViewController.evaluateJavascript(
            source : "addMarker('${marker.markerId}', '${jsonEncode(marker.latLng)}', '${marker.markerImageSrc}', '${marker.width}', '${marker.height}', '${marker.offsetX}', '${marker.offsetY}', '${marker
                .infoWindowText}')");
      }
    }
  }

  clear() {
    _webViewController.evaluateJavascript(source :'clear();');
  }

  clearPolyline() {
    _webViewController.evaluateJavascript(source :'clearPolyline();');
  }

  clearCircle() {
    _webViewController.evaluateJavascript(source :'clearCircle();');
  }

  clearPolygon() {
    _webViewController.evaluateJavascript(source :'clearPolygon();');
  }

  clearMarker() {
    _webViewController.evaluateJavascript(source :'clearMarker();');
  }

  fitBounds(List<LatLng> points) async {
    await _webViewController.evaluateJavascript(source :"fitBounds('${jsonEncode(points)}');");
  }
}
