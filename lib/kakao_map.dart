import 'dart:convert';

import 'package:dyt/geolocator_options.dart';
import 'package:dyt/polygon.dart';
import 'package:dyt/polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'callbacks.dart';
import 'circle.dart';
import 'kakao_map_controller.dart';
import 'marker.dart';
import 'model/lat_lng.dart';

class KakaoMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final OnMapTap? onMapTap;
  final OnCameraIdle? onCameraIdle;
  final OnZoomChanged? onZoomChanged;

  final Set<Polyline>? polylines;
  final Set<Circle>? circles;
  final Set<Polygon>? polygons;
  final List<Marker>? markers;

  KakaoMap({
    Key? key,
    this.onMapCreated,
    this.onMapTap,
    this.onCameraIdle,
    this.onZoomChanged,
    this.polylines,
    this.circles,
    this.polygons,
    this.markers,
  }) : super(key: key);

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> {
  late final KakaoMapController _mapController;
  var userLocation = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://localhost:8080/'),
      ),
      initialFile: "assets/web/kakaomap.html",
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        // 필요시 다른 설정을 추가하세요.
      ),
      onWebViewCreated: (InAppWebViewController controller) async {},
      onLoadStop: (InAppWebViewController controller, url) async {
        _mapController = KakaoMapController(controller);

        while (_mapController == null) {
          _mapController = KakaoMapController(controller);
        }

        if (widget.onMapCreated != null) widget.onMapCreated!(_mapController);

        // 페이지 로드 후 appkey 설정
        await controller.evaluateJavascript(source: """
      window.appkey = "${dotenv.env['KAKAO_API_KEY']}";
      window.userlatitude = "${userLocation.userLatLng?.latitude}";
      window.userlongitude = "${userLocation.userLatLng?.longitude}";
      window.userzoom = "${3}";
      if (window.loadKakaoMap) {
        window.loadKakaoMap();
      }
    """);

        // 'onMapTap' 핸들러
        controller.addJavaScriptHandler(
          handlerName: 'onMapTap',
          callback: (args) {
            if (widget.onMapTap != null) {
              widget.onMapTap!(LatLng.fromJson(jsonDecode(args[0])));
            }
            return null; // JavaScript로 전달할 응답 값 (필요 시)
          },
        );

        // 'zoomChanged' 핸들러
        controller.addJavaScriptHandler(
          handlerName: 'zoomChanged',
          callback: (args) {
            print("zoomChanged ${args[0]}");
            if (widget.onZoomChanged != null) {
              widget.onZoomChanged!(jsonDecode(args[0])['zoomLevel']);
            }
            return null;
          },
        );

        // 'cameraIdle' 핸들러
        controller.addJavaScriptHandler(
          handlerName: 'cameraIdle',
          callback: (args) {
            print("idle ${args[0]}");
            if (widget.onCameraIdle != null) {
              widget.onCameraIdle!(
                LatLng.fromJson(jsonDecode(args[0])),
                jsonDecode(args[0])['zoomLevel'],
              );
            }
            return null;
          },
        );
        // 필요 시 추가 초기화 함수 호출
      },
      // JavaScript 채널 설정
    );
  }

  @override
  void didUpdateWidget(KakaoMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _mapController.addPolyline(polylines: widget.polylines);
    _mapController.addCircle(circles: widget.circles);
    _mapController.addPolygon(polygons: widget.polygons);
    _mapController.addMarker(markers: widget.markers);
  }
}
