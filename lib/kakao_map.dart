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
  KakaoMapController? mapController;
  var userLocation = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://localhost:8080/assets/web/kakaomap.html'),
      ),
      // initialFile: "assets/web/kakaomap.html",
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        // 필요시 다른 설정을 추가하세요.
      ),
      onWebViewCreated: (InAppWebViewController controller) async {},
      onLoadStop: (InAppWebViewController controller, url) async {

        if (!Get.isRegistered<KakaoMapController>()) {
          mapController = Get.put(KakaoMapController(controller));
        } else {
          print("컨트롤러 등록 실패");
        }

        if (widget.onMapCreated != null) widget.onMapCreated!(mapController!);

        // 페이지 로드 후 appkey 설정
        await controller.evaluateJavascript(source: """
      window.appkey = "${dotenv.env['KAKAO_API_KEY']}";
      window.userlatitude = "${userLocation.userLatLng.value.latitude}";
      window.userlongitude = "${userLocation.userLatLng.value.longitude}";
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
              widget.onMapTap!(customLatLng.fromJson(jsonDecode(args[0])));
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
                customLatLng.fromJson(jsonDecode(args[0])),
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
    if(mapController != null) {
      mapController?.addPolyline(polylines: widget.polylines);
      mapController?.addCircle(circles: widget.circles);
      mapController?.addPolygon(polygons: widget.polygons);
      mapController?.addMarker(markers: widget.markers);
    }
  }
}
