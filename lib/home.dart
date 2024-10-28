import 'dart:convert';

import 'package:dyt/polygon.dart';
import 'package:dyt/polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'circle.dart';
import 'geolocator_options.dart';
import 'kakao_map.dart';
import 'kakao_map_controller.dart';
import 'marker.dart';
import 'model/lat_lng.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  KakaoMapController? _kakaoMapController;
  var userLocation = Get.find<LocationService>();

  Set<Polyline> polylines = {};
  Set<Circle> circles = {};
  Set<Polygon> polygons = {};
  Set<Marker> markers = {};

  Future<void> _initMethod() async {
    List<Map<String, dynamic>>? _result2 =
        await _kakaoMapController?.getCoinNore(userLocation.userLatLng!);

    _kakaoMapController?.findAllStore = _result2 ?? [];

    LatLng? _test1 = await _paintCircle();
    List<LatLng>? _test2 = await _markingStore(_result2);
    // LatLng? _test3 = await _3(_result2);
    List<LatLng>? _test4 = await _paintCloseStore(_result2);

    // if (_test1 != null && _test2 != null && _test3 != null && _test4 != null) {
    //   fitBounds([_test1, ..._test2, _test3, ..._test4]);
    // }

    if (_test1 != null && _test2 != null && _test4 != null) {
      fitBounds([_test1, ..._test2, ..._test4]);
    }

    setState(() {});
  }

  Future<LatLng?> _paintCircle() async {
    LatLng? center = userLocation.userLatLng;
    if (center != null) {
      circles.add(Circle(
          circleId: "3",
          center: center,
          radius: 1000,
          strokeColor: Colors.redAccent,
          strokeOpacity: 1,
          strokeWidth: 4));
      return center;
    }
    return null;
  }

  Future<List<LatLng>?> _markingStore(
      List<Map<String, dynamic>>? _result) async {
    if (_result == null) return null;

    for (var item in _result) {
      LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
      // LatLng _latlng = LatLng(37.3625806, 126.9248464);

      markers.add(
        Marker(
            markerId: item["id"],
            latLng: _latlng,
            infoWindowText: item["place_name"],
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),
      );
    }

    List<LatLng> bounds2 = markers.map((marker) => marker.latLng).toList();
    return bounds2;
  }

  Future<LatLng?> _3(List<Map<String, dynamic>>? _result) async {
    if (_result == null) return null;
    List<LatLng> bounds2 = [];
    for (var item in _result) {
      LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
      // LatLng _latlng = LatLng(37.3625806, 126.9248464);

      markers.add(
        Marker(
            markerId: item["id"],
            latLng: _latlng,
            infoWindowText: item["place_name"],
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),
      );
      bounds2.add(_latlng);
    }

    LatLng closestPoint =
        LocationService.findClosestPoint(userLocation.userLatLng!, bounds2);

    return closestPoint;
  }

  Future<List<LatLng>?> _paintCloseStore(
      List<Map<String, dynamic>>? _result2) async {
    if (_result2 == null) return null;
    List<LatLng> bounds2 = [];
    for (var item in _result2) {
      LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
      // LatLng _latlng = LatLng(37.3625806, 126.9248464);

      markers.add(
        Marker(
            markerId: item["id"],
            latLng: _latlng,
            infoWindowText: item["place_name"],
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),
      );
      bounds2.add(_latlng);
    }

    LatLng closestPoint =
        LocationService.findClosestPoint(userLocation.userLatLng!, bounds2);

    Map<String, dynamic> _findClosedStore = _result2.firstWhere(
        (Map<String, dynamic> e) =>
            LatLng(double.parse(e["y"]), double.parse(e["x"])) == closestPoint);

    List<LatLng>? _result = await _kakaoMapController?.findShortCoinNore(
        userLocation.userLatLng!, closestPoint, _findClosedStore);

    if (_result == null) return null;

    polylines.add(Polyline(
        polylineId: "1",
        points: _result,
        strokeColor: Colors.blueAccent,
        strokeOpacity: 0.7,
        strokeWidth: 8));

    return _result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (KakaoMapController controller) {
              _kakaoMapController = controller;
              _initMethod();
            },
            onMapTap: (LatLng latLng) async {
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              print("${jsonEncode(latLng)}");
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              Map<String, dynamic>? _findStore = _kakaoMapController
                  ?.findAllStore
                  .firstWhere((Map<String, dynamic> e) => LatLng(double.parse(e["y"]), double.parse(e["x"])) ==
                  latLng
              );
              List<LatLng>? _result =
                  await _kakaoMapController?.findShortCoinNore(
                      userLocation.userLatLng!, latLng, _findStore ?? {});

              // _clear();
              polylines.clear();

              polylines.add(Polyline(
                  polylineId: "1",
                  points: _result ?? [],
                  strokeColor: Colors.blueAccent,
                  strokeOpacity: 0.7,
                  strokeWidth: 8));

              setState(() {

              });
            },
            onCameraIdle: (LatLng latLng, int zoomLevel) {
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              print("${jsonEncode(latLng)}");
              print("zoomLevel : $zoomLevel");
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            },
            onZoomChanged: (int zoomLevel) {
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              print("zoomLevel : $zoomLevel");
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            },
            polylines: polylines,
            circles: circles,
            polygons: polygons,
            markers: markers.toList(),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    child: Column(
                      children: markers
                          .map((e) => Text(e.infoWindowText.toString()))
                          .toList(),
                    ),
                  )
                  // ElevatedButton(
                  //   child: const Text('직선'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<LatLng> list = [
                  //       LatLng(37.3625806, 126.9248464),
                  //       LatLng(37.3626138, 126.9264801),
                  //       LatLng(37.3632727, 126.9280313)
                  //     ];
                  //     List<LatLng> list2 = [
                  //       LatLng(37.3616144, 126.9250364),
                  //       LatLng(37.3614955, 126.9286686),
                  //       LatLng(37.3608681, 126.9306506),
                  //       LatLng(37.3594222, 126.9280014)
                  //     ];
                  //
                  //     setState(() {
                  //       polylines.add(Polyline(
                  //           polylineId: "1",
                  //           points: list,
                  //           strokeColor: Colors.red,
                  //           strokeOpacity: 0.7,
                  //           strokeWidth: 8));
                  //       polylines.add(Polyline(
                  //           polylineId: "2",
                  //           points: list2,
                  //           strokeColor: Colors.blue,
                  //           strokeOpacity: 1,
                  //           strokeWidth: 4));
                  //
                  //       fitBounds([...list, ...list2]);
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('원'),
                  //   onPressed: () {
                  //     LatLng? center = userLocation.userLatLng;
                  //     if (center != null) {
                  //       setState(() {
                  //         circles.add(Circle(
                  //             circleId: "3",
                  //             center: center,
                  //             radius: 1000,
                  //             strokeColor: Colors.amber,
                  //             strokeOpacity: 1,
                  //             strokeWidth: 4));
                  //
                  //         fitBounds([center]);
                  //       });
                  //     }
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('원-반전'),
                  //   onPressed: () {
                  //     LatLng? center = userLocation.userLatLng;
                  //     if (center != null) {
                  //       setState(() {
                  //         circles.add(Circle(
                  //           circleId: "7",
                  //           center: center,
                  //           radius: 44,
                  //           strokeWidth: 4,
                  //           strokeColor: Colors.blue,
                  //           strokeOpacity: 0.7,
                  //           fillColor: Colors.black,
                  //           fillOpacity: 0.5,
                  //         ));
                  //
                  //         fitBounds([center]);
                  //       });
                  //     }
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('다각형'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<LatLng> list = [
                  //       LatLng(37.3625806, 126.9248464),
                  //       LatLng(37.3626138, 126.9264801),
                  //       LatLng(37.3632727, 126.9280313)
                  //     ];
                  //     List<LatLng> list2 = [
                  //       LatLng(37.3616144, 126.9250364),
                  //       LatLng(37.3614955, 126.9286686),
                  //       LatLng(37.3608681, 126.9306506),
                  //       LatLng(37.3594222, 126.9280014)
                  //     ];
                  //
                  //     setState(() {
                  //       polygons.add(Polygon(
                  //           polygonId: "4",
                  //           points: list,
                  //           strokeWidth: 4,
                  //           strokeColor: Colors.blue,
                  //           strokeOpacity: 1,
                  //           fillColor: Colors.transparent,
                  //           fillOpacity: 0));
                  //       polygons.add(Polygon(
                  //           polygonId: "5",
                  //           points: list2,
                  //           strokeWidth: 4,
                  //           strokeColor: Colors.blue,
                  //           strokeOpacity: 1,
                  //           fillColor: Colors.transparent,
                  //           fillOpacity: 0));
                  //
                  //       fitBounds([...list, ...list2]);
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('다각형-반전'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<LatLng> list = [
                  //       LatLng(37.3625806, 126.9248464),
                  //       LatLng(37.3626138, 126.9264801),
                  //       LatLng(37.3632727, 126.9280313)
                  //     ];
                  //     List<LatLng> list2 = [
                  //       LatLng(37.3616144, 126.9250364),
                  //       LatLng(37.3614955, 126.9286686),
                  //       LatLng(37.3608681, 126.9306506),
                  //       LatLng(37.3594222, 126.9280014)
                  //     ];
                  //
                  //     setState(() {
                  //       polygons.add(Polygon(
                  //         polygonId: "6",
                  //         points: createOuterBounds(),
                  //         holes: [list, list2],
                  //         strokeWidth: 4,
                  //         strokeColor: Colors.blue,
                  //         strokeOpacity: 0.7,
                  //         fillColor: Colors.black,
                  //         fillOpacity: 0.5,
                  //       ));
                  //
                  //       fitBounds([...list, ...list2]);
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('마커'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<Map<String,
                  //         dynamic>>? _result = await _kakaoMapController
                  //         ?.getCoinNore(userLocation.userLatLng!);
                  //
                  //     if (_result == null) return;
                  //
                  //     for (var item in _result) {
                  //
                  //       LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
                  //       // LatLng _latlng = LatLng(37.3625806, 126.9248464);
                  //
                  //       markers.add(Marker(markerId: item["id"],
                  //           latLng: _latlng,
                  //           infoWindowText: item["place_name"],
                  //           markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),);
                  //       // bounds.add(_latlng);
                  //
                  //     }
                  //
                  //     // LatLng latLng = LatLng(37.3625806, 126.9248464);
                  //     // LatLng latLng2 = LatLng(37.3605008, 126.9252204);
                  //     // markers.add(Marker(markerId: "7", latLng: latLng, markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png', infoWindowText: 'TEST1'));
                  //     // markers.add(Marker(markerId: "8", latLng: latLng2, markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png', infoWindowText: 'TEST2'));
                  //
                  //
                  //     List<LatLng> bounds2 = markers.map((marker) => marker.latLng).toList();
                  //     setState(() {
                  //       fitBounds(bounds2);
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('최단거리??'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<Map<String,
                  //         dynamic>>? _result = await _kakaoMapController
                  //         ?.getCoinNore(userLocation.userLatLng!);
                  //
                  //     if (_result == null) return;
                  //     List<LatLng> bounds2 = [];
                  //     for (var item in _result) {
                  //       LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
                  //       // LatLng _latlng = LatLng(37.3625806, 126.9248464);
                  //
                  //       markers.add(Marker(markerId: item["id"],
                  //           latLng: _latlng,
                  //           infoWindowText: item["place_name"],
                  //           markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),);
                  //       bounds2.add(_latlng);
                  //     }
                  //
                  //     LatLng closestPoint = LocationService.findClosestPoint(userLocation.userLatLng!, bounds2);
                  //
                  //     setState(() {
                  //       fitBounds([closestPoint]);
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   child: const Text('길찾기'),
                  //   onPressed: () async {
                  //     _clear();
                  //
                  //     List<Map<String,
                  //         dynamic>>? _result2 = await _kakaoMapController
                  //         ?.getCoinNore(userLocation.userLatLng!);
                  //
                  //     if (_result2 == null) return;
                  //     List<LatLng> bounds2 = [];
                  //     for (var item in _result2) {
                  //       LatLng _latlng = LatLng(double.parse(item["y"]), double.parse(item["x"]));
                  //       // LatLng _latlng = LatLng(37.3625806, 126.9248464);
                  //
                  //       markers.add(Marker(markerId: item["id"],
                  //           latLng: _latlng,
                  //           infoWindowText: item["place_name"],
                  //           markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png'),);
                  //       bounds2.add(_latlng);
                  //     }
                  //
                  //     LatLng closestPoint = LocationService.findClosestPoint(userLocation.userLatLng!, bounds2);
                  //
                  //
                  //     List<LatLng>? _result = await _kakaoMapController
                  //         ?.findShortCoinNore(userLocation.userLatLng!, closestPoint);
                  //
                  //     if (_result == null) return;
                  //
                  //         setState(() {
                  //           polylines.add(Polyline(
                  //               polylineId: "1",
                  //               points: _result,
                  //               strokeColor: Colors.red,
                  //               strokeOpacity: 0.7,
                  //               strokeWidth: 8));
                  //
                  //           fitBounds(_result);
                  //         });
                  //   },
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _clear() {
    _kakaoMapController?.clear();
    polylines.clear();
    circles.clear();
    polygons.clear();
    markers.clear();
  }

  List<LatLng> createOuterBounds() {
    double delta = 0.01;

    List<LatLng> list = [];

    list.add(LatLng(90 - delta, -180 + delta));
    list.add(LatLng(0, -180 + delta));
    list.add(LatLng(-90 + delta, -180 + delta));
    list.add(LatLng(-90 + delta, 0));
    list.add(LatLng(-90 + delta, 180 - delta));
    list.add(LatLng(0, 180 - delta));
    list.add(LatLng(90 - delta, 180 - delta));
    list.add(LatLng(90 - delta, 0));
    list.add(LatLng(90 - delta, -180 + delta));

    return list;
  }

  fitBounds(List<LatLng> bounds) async {
    _kakaoMapController?.fitBounds(bounds);
  }
}
