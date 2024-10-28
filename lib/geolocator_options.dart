import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'marker.dart';
import 'model/lat_lng.dart';

class LocationService extends GetxService {

  Rx<LatLng> userLatLng = LatLng(0, 0).obs;
  final double defaultLatitude = 37.48891558895957;
  // final double defaultLatitude = 37.45194876896246;
  final double defaultLongitude = 127.12721264903897;
  // final double defaultLongitude = 126.63104459058991;

  Future<void> initService() async {
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 활성화되어 있지 않다면 예외 처리
      print('위치 서비스를 활성화해야 합니다.');
      return;
    }

    // 위치 권한 상태 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 위치 권한이 거부된 경우 예외 처리
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 위치 권한이 영구적으로 거부된 경우 예외 처리
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 활성화하세요.');
      return;
    }

    // 현재 위치 가져오기
    // 새로운 방식 (LocationSettings 사용)
    // Position position = await Geolocator.getCurrentPosition(
    //   locationSettings: const LocationSettings(
    //     accuracy: LocationAccuracy.best,
    //   ),
    // );
    userLatLng.value = LatLng(defaultLatitude, defaultLongitude);
    userLatLng.refresh();

    _trackUserLocation();

  }

  void _trackUserLocation() async {
    // 위치 변경 시마다 스트림을 통해 위치 정보 제공

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // 2미터 단위로 위치 갱신
      ),
    ).listen((Position position) {
      if(kDebugMode) {
        print('위도: ${defaultLatitude}, 경도: ${defaultLongitude}');
        userLatLng.value = LatLng(defaultLatitude, defaultLongitude);
        userLatLng.refresh();
      } else {
        print('위도: ${position.latitude}, 경도: ${position.longitude}');
        userLatLng.value = LatLng(position.latitude, position.longitude);
        userLatLng.refresh();
      }
    });
  }

  static Decimal _sqrt(Decimal value, {Decimal? epsilon}) {
    // 초기값 설정
    double x0 = value.toDouble() / 2;
    double x1 = (x0 + value.toDouble() / x0) / 2;

    // epsilon 값이 없을 경우 기본값 설정
    epsilon ??= Decimal.parse('0.0001');

    int maxIterations = 100; // 최대 반복 횟수 설정
    int iteration = 0;

    // 반복하여 제곱근 근사값 계산
    while ((x0 - x1).abs() > epsilon.toDouble() && iteration < maxIterations) {
      x0 = x1;
      x1 = (x0 + value.toDouble() / x0) / 2;
      iteration++;
    }

    // 최종 결과를 Decimal로 변환하여 반환
    return Decimal.parse(x1.toString());
  }


// 거리 계산 함수
  static Decimal _calculateDistance(LatLng a, LatLng b) {
    final latDiff = Decimal.parse(a.latitude.toString()) - Decimal.parse(b.latitude.toString());
    final lonDiff = Decimal.parse(a.longitude.toString()) - Decimal.parse(b.longitude.toString());

    // 제곱 연산
    final Decimal latDiffSquared = latDiff * latDiff;
    final Decimal lonDiffSquared = lonDiff * lonDiff;

    // 두 값의 합을 계산
    final Decimal sum = latDiffSquared + lonDiffSquared;

    // 사용자 정의 _sqrt 함수로 제곱근 계산
    return _sqrt(sum);
  }

// 가장 가까운 좌표 찾기 함수
  static LatLng findClosestPoint(LatLng myLocation, List<LatLng> points) {
    LatLng closestPoint = points[0];
    Decimal minDistance = _calculateDistance(myLocation, closestPoint);

    for (var point in points) {
      Decimal distance = _calculateDistance(myLocation, point);
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  // 마커 정렬 함수
// 마커 정렬 함수
  static Set<Marker> sortMarkersByDistance(LatLng userLocation, Set<Marker> markers) {
    List<Marker> sortedMarkers = markers.map((marker) {
      int distance = calculateDistance(userLocation, marker.latLng).round();
      return Marker(
        markerId: marker.markerId,
        latLng: marker.latLng,
        infoWindowText: marker.infoWindowText,
        markerImageSrc: marker.markerImageSrc,
        distance: distance,
      );
    }).toList();

    // 거리 순으로 정렬
    sortedMarkers.sort((a, b) => a.distance!.compareTo(b.distance!));

    // 정렬된 순서에 따라 index 필드 추가
    for (int i = 0; i < sortedMarkers.length; i++) {
      sortedMarkers[i] = Marker(
        markerId: sortedMarkers[i].markerId,
        latLng: sortedMarkers[i].latLng,
        infoWindowText: sortedMarkers[i].infoWindowText,
        markerImageSrc: sortedMarkers[i].markerImageSrc,
        distance: sortedMarkers[i].distance,
        index: i + 1, // 추가한 index 필드
      );
    }

    return sortedMarkers.toSet(); // 정렬된 마커 Set 반환
  }


  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // 지구 반지름 (미터 단위)

    double dLat = _degreeToRadian((Decimal.parse(end.latitude) - Decimal.parse(start.latitude)).toDouble());
    double dLon = _degreeToRadian((Decimal.parse(end.longitude) - Decimal.parse(start.longitude)).toDouble());

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(double.parse(start.latitude))) *
            cos(_degreeToRadian(double.parse(end.latitude))) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // 두 지점 간의 거리 (미터)
  }

  static int calculateTotalDistance(List<LatLng> coordinates) {
    double totalDistance = 0.0;

    for (int i = 0; i < coordinates.length - 1; i++) {
      final LatLng start = coordinates[i];
      final LatLng end = coordinates[i + 1];

      totalDistance += calculateDistance(start, end); // 두 지점 간 거리 누적
    }

    return totalDistance.round(); // 총 거리 (미터)
  }

  static double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}

