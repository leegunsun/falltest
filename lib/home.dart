import 'dart:convert';

import 'package:dyt/polygon.dart';
import 'package:dyt/polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'callbacks.dart';
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
  String webId = "";
  bool isWebViewVisible = false;
  int selectIndex = 0;

  // Worker? _worker;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _worker = ever<LatLng>(Get.find<LocationService>().userLatLng, (LatLng value) {
  //     _set();
  //   });
  // }
  //
  // void _set() {
  //   setState(() {});
  // }
  //
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   _worker?.dispose();
  //   super.dispose();
  // }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedMarker(Marker _select) {
    if (_kakaoMapController?.markers == null) return;

    // 선택된 마커의 인덱스를 찾습니다.
    final index = _select.index;

    if(index == null) return;

    // 선택된 마커가 있는 경우 해당 인덱스로 스크롤합니다.
    if (index != -1) {
      final itemHeight = 10.0; // 각 항목의 추정 높이
      final scrollPosition = index * itemHeight;
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          KakaoMap(
            onMapCreated: (KakaoMapController controller) async {
              _kakaoMapController = controller;
              if (_kakaoMapController != null) {
                await _kakaoMapController?.initMethod();
                setState(() {});
              }
            },
            onMapTap: (LatLng latLng) async {
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              print("${jsonEncode(latLng)}");
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              await _selecetStoreMaker(latLng);
              if(_kakaoMapController?.selectStore != null) {
                _scrollToSelectedMarker(_kakaoMapController!.selectStore!);
              }
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
            polylines: _kakaoMapController?.polylines,
            circles: _kakaoMapController?.circles,
            polygons: _kakaoMapController?.polygons,
            markers: _kakaoMapController?.markers.toList(),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    height: Get.height / 4,
                    width: Get.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, -1),
                              blurRadius: 10)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 24.0, left: 24.0, top: 30),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: _kakaoMapController?.markers == null
                              ? [const SizedBox()]
                              : _kakaoMapController!.markers.map((e) {
                                  bool _isSelect =
                                      e.infoWindowText.toString() ==
                                          _kakaoMapController
                                              ?.selectStore?.infoWindowText;

                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      await _selecetStoreMaker(e.latLng);
                                      // webId = _kakaoMapController?.selectStore?["id"];
                                      Get.to(
                                        () => OpenMapPage(
                                          webId: _kakaoMapController
                                              ?.selectStore?.markerId ?? "",
                                        ),
                                        transition: Transition.downToUp,
                                        // 아래에서 위로 올라오는 효과
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                      // await _test111(_kakaoMapController?.selectStore?["id"]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 9.0),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 0,
                                              child: Row(
                                                children: [
                                                  if (_isSelect) ...[
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    const SizedBox(width: 10,)
                                                  ],
                                                  Text(
                                                    e.infoWindowText.toString(),
                                                    style: TextStyle(
                                                        color: _isSelect
                                                            ? Colors.blueAccent
                                                            : null,
                                                        fontSize: 18,
                                                        fontWeight: _isSelect
                                                            ? FontWeight.bold
                                                            : null),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex : 1,
                                              child: Text("${e.distance.toString()} m",
                                                  style: TextStyle(
                                                      color: _isSelect
                                                          ? Colors.blueAccent
                                                          : null,
                                                      fontSize: 18,
                                                      fontWeight: _isSelect
                                                          ? FontWeight.bold
                                                          : null)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecetStoreMaker(LatLng latLng) async {
    Map<String,dynamic>? _find = _kakaoMapController?.findAllStore
        .firstWhere((Map<String, dynamic> e) =>
            LatLng(double.parse(e["latLng"]["latitude"]), double.parse(e["latLng"]["longitude"])) == latLng, orElse: () => <String, dynamic>{});

    _kakaoMapController?.selectStore = Marker.fromJson(_find ?? {});

    List<LatLng>? _result = await _kakaoMapController?.findShortCoinNore(
        _kakaoMapController!.userLocation.userLatLng.value,
        latLng,
        _kakaoMapController?.selectStore?.toJson() ?? {});

    _kakaoMapController!.polylines.clear();

    _kakaoMapController!.polylines.add(Polyline(
        polylineId: "1",
        points: _result ?? [],
        strokeColor: Colors.blueAccent,
        strokeOpacity: 0.7,
        strokeWidth: 8));

    setState(() {});
  }

  _clear() {
    _kakaoMapController?.clear();
    _kakaoMapController?..clear();
    _kakaoMapController?.circles.clear();
    _kakaoMapController?.polygons.clear();
    _kakaoMapController?.markers.clear();
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

  Future<void> fitBounds(List<LatLng> bounds) async {
    await _kakaoMapController?.fitBounds(bounds);
  }
}

class OpenMapPage extends StatelessWidget {
  final String webId;

  const OpenMapPage({super.key, required this.webId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://place.map.kakao.com/$webId"),
        ),
      ),
    );
  }
}

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
