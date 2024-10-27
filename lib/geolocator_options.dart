import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'model/lat_lng.dart';

class LocationService extends GetxService {

  LatLng? userLatLng;
  final double defaultLatitude = 37.45194876896246;
  final double defaultLongitude = 126.63104459058991;

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
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );


    if(kDebugMode) {
      print('위도: ${defaultLatitude}, 경도: ${defaultLongitude}');
      userLatLng = LatLng(defaultLatitude, defaultLongitude);
    } else {
      print('위도: ${position.latitude}, 경도: ${position.longitude}');
      userLatLng = LatLng(position.latitude, position.longitude);
    }
  }
}

