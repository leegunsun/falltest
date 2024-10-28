import 'dart:convert';
import 'dart:math';
import 'package:decimal/decimal.dart';
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
  List<Map<String, dynamic>> findAllStore = [];
  Map<String, dynamic>? selectStore;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://dapi.kakao.com/v2",
    headers: {
      "Authorization": dotenv.get("KAKAO_API_MASTER_KEY", fallback: ""),
      "Content-Type": "application/json" // 여기 추가
    },
  ));

  final Dio _dioTMap = Dio(BaseOptions(
    baseUrl: "https://apis.openapi.sk.com",
    headers: {
      "appKey": dotenv.get("TMAP_API_MASTER_KEY", fallback: ""),
      "content-type": "application/x-www-form-urlencoded" // 여기 추가
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

  Future<List<LatLng>> findShortCoinNore(LatLng userPoint, LatLng destinationPoint, Map<String, dynamic> storeData) async {

    Response<dynamic> _getData =
        await _dioTMap.get("/tmap/routes/pedestrian", queryParameters: {
      // "origin": "${userPoint.longitude},${userPoint.latitude}",
      // "destination": "${destinationPoint.longitude},${destinationPoint.latitude}",
      "startName": "내 위치",
      "endName": storeData["place_name"] ?? "",
      "endY": destinationPoint.latitude,
      "endX": destinationPoint.longitude,
      "startY": userPoint.latitude,
      "startX": userPoint.longitude,
      "version": "1",
    });

    // routes -> sections -> roads -> vertexes로 접근하여 좌표 리스트 가져오기
    List<LatLng> coordinates = [];


    //   for (var road in _getData.data["routes"][0]["sections"][0]["roads"]) {
    //       for (int i = 0; i < road["vertexes"].length; i += 2) {
    //         double x = road["vertexes"][i];
    //         double y = road["vertexes"][i + 1];
    //         coordinates.add(LatLng(y, x));
    //   }
    // }

    // JSON 데이터의 `features` 안에 있는 모든 `LineString` 좌표를 가져옵니다.
    List<dynamic> features = _getData.data["features"];
    for (var feature in features) {
      if (feature["geometry"]["type"] == "LineString") {
        List<dynamic> points = feature["geometry"]["coordinates"];
        for (var point in points) {
          double longitude = point[0];
          double latitude = point[1];
          coordinates.add(LatLng(latitude, longitude));
        }
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
