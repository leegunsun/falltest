import 'dart:convert';
import 'package:dyt/hex_color.dart';

import 'package:dyt/polygon.dart';
import 'package:dyt/polyline.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';

import 'circle.dart';
import 'marker.dart';
import 'model/lat_lng.dart';

class KakaoMapController {
  final InAppWebViewController _webViewController;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://dapi.kakao.com/v2",
    headers: {
      "Authorization": dotenv.get("KAKAO_API_MASTER_KEY", fallback: ""),
      "Content-Type": "application/json" // 여기 추가
    },
  ));

  final Dio _dioKakaoMobility = Dio(BaseOptions(
    baseUrl: "https://apis-navi.kakaomobility.com/v1",
    headers: {
      "Authorization": dotenv.get("KAKAO_API_MASTER_KEY", fallback: ""),
      "Content-Type": "application/json" // 여기 추가
    },
  ));

  InAppWebViewController get webViewController => _webViewController;

  KakaoMapController(this._webViewController);

  addPolyline({Set<Polyline>? polylines}) async {
    if (polylines != null) {
      clearPolyline();
      for (var polyline in polylines) {
        await _webViewController.evaluateJavascript(
            source:
                "addPolyline('${polyline.polylineId}', '${jsonEncode(polyline.points)}', '${polyline.strokeColor?.toHexColor()}', '${polyline.strokeOpacity}', '${polyline.strokeWidth}');");
      }
    }
  }

  addCircle({Set<Circle>? circles}) async {
    if (circles != null) {
      clearCircle();
      for (var circle in circles) {
        await _webViewController.evaluateJavascript(
            source:
                "addCircle('${circle.circleId}', '${jsonEncode(circle.center)}', '${circle.radius}', '${circle.strokeWidth}', '${circle.strokeColor?.toHexColor()}', '${circle.strokeOpacity}');");
      }
    }
  }

  addPolygon({Set<Polygon>? polygons}) async {
    if (polygons != null) {
      clearPolygon();
      for (var polygon in polygons) {
        await _webViewController.evaluateJavascript(
            source:
                "addPolygon('${polygon.polygonId}', '${jsonEncode(polygon.points)}', '${jsonEncode(polygon.holes)}', '${polygon.strokeWidth}', '${polygon.strokeColor?.toHexColor()}', '${polygon.strokeOpacity}', '${polygon.strokeStyle}', '${polygon.fillColor?.toHexColor()}', '${polygon.fillOpacity}');");
      }
    }
  }

  addMarker({List<Marker>? markers}) async {
    if (markers != null) {
      clearMarker();
      for (var marker in markers) {
        await _webViewController.evaluateJavascript(
            source:
                "addMarker('${marker.markerId}', '${jsonEncode(marker.latLng)}', '${marker.markerImageSrc}', '${marker.width}', '${marker.height}', '${marker.offsetX}', '${marker.offsetY}', '${marker.infoWindowText}')");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCoinNore(LatLng points,
      [String? radius]) async {
    Response<dynamic> _getData =
        await _dio.get("/local/search/keyword.json", queryParameters: {
      "y": points.latitude,
      "x": points.longitude,
      "radius": radius ?? "1000",
      "query": "코인"
    });

    // 받은 데이터를 List<Map<String, dynamic>> 형태로 변환
    List<Map<String, dynamic>> _dataList =
        List<Map<String, dynamic>>.from(_getData.data["documents"]);

    // 'category_name'에 '노래'라는 단어가 포함된 데이터만 필터링
    List<Map<String, dynamic>> filteredData = _dataList.where((item) {
      String categoryName = item["category_name"] ?? "";
      return categoryName.contains("노래");
    }).toList();

    return filteredData;
  }

  Future<List<LatLng>> findShortCoinNore(LatLng userPoint, LatLng destinationPoint) async {

    Response<dynamic> _getData =
        await _dioKakaoMobility.get("/directions", queryParameters: {
      "origin": "${userPoint.longitude},${userPoint.latitude}",
      // "origin": "127.11015314141542,37.39472714688412",
      "destination": "${destinationPoint.longitude},${destinationPoint.latitude}",
      // "destination": "127.10824367964793,37.401937080111644",
      "waypoints": "",
      "priority": "RECOMMEND",
      "car_fuel": "GASOLINE",
      "car_hipass": "false",
      "alternatives": "false",
      "road_details": "false",
    });

    // routes -> sections -> roads -> vertexes로 접근하여 좌표 리스트 가져오기
    List<LatLng> coordinates = [];


      for (var road in _getData.data["routes"][0]["sections"][0]["roads"]) {
          for (int i = 0; i < road["vertexes"].length; i += 2) {
            double x = road["vertexes"][i];
            double y = road["vertexes"][i + 1];
            coordinates.add(LatLng(y, x));
      }
    }

    return coordinates;
  }

  clear() {
    _webViewController.evaluateJavascript(source: 'clear();');
  }

  clearPolyline() {
    _webViewController.evaluateJavascript(source: 'clearPolyline();');
  }

  clearCircle() {
    _webViewController.evaluateJavascript(source: 'clearCircle();');
  }

  clearPolygon() {
    _webViewController.evaluateJavascript(source: 'clearPolygon();');
  }

  clearMarker() {
    _webViewController.evaluateJavascript(source: 'clearMarker();');
  }

  fitBounds(List<LatLng> points) async {
    await _webViewController.evaluateJavascript(
        source: "fitBounds('${jsonEncode(points)}');");
  }
}
