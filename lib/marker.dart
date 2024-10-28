
import 'model/lat_lng.dart';

class Marker {
  final String markerId;
  final LatLng latLng;
  String? markerImageSrc;
  int? width;
  int? height;
  int? offsetX;
  int? offsetY;
  int? distance;
  String? infoWindowText;

  Marker({
    required this.markerId,
    required this.latLng,
    this.markerImageSrc,
    this.width,
    this.height,
    this.offsetX,
    this.distance,
    this.offsetY,
    this.infoWindowText,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Marker) return false;
    return markerId == other.markerId && infoWindowText == other.infoWindowText;
  }

  @override
  int get hashCode => markerId.hashCode ^ infoWindowText.hashCode;

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'markerId': markerId,
      'latLng': {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      },
      'markerImageSrc': markerImageSrc,
      'width': width,
      'height': height,
      'offsetX': offsetX,
      'distance': distance,
      'offsetY': offsetY,
      'infoWindowText': infoWindowText,
    };
  }
}
