

import 'kakao_map_controller.dart';
import 'model/lat_lng.dart';

typedef MapCreateCallback = void Function(KakaoMapController controller);
typedef SetStateCallback = void Function();

//typedef void CameraPositionCallback(CameraPosition position);

//typedef void OnMarkerTab(Marker? marker, Map<String, int?> iconSize);

typedef OnMapTap = void Function(customLatLng latLng);

//typedef void OnMapLongTap(LatLng latLng);
//
//typedef void OnMapDoubleTap(LatLng latLng);
//
//typedef void OnMapTwoFingerTap(LatLng latLng);
//
// typedef void OnCameraChange(LatLng? latLng, CameraChangeReason reason, bool? isAnimated);

typedef OnCameraIdle = void Function(customLatLng latLng, int zoomLevel);

typedef OnZoomChanged = void Function(int zoomLevel);

//typedef void OnSymbolTap(LatLng? position, String? caption);
//
//typedef void OnPathOverlayTab(PathOverlayId pathOverlayId);
