import 'model/lat_lng.dart';

class Marker {
  final String markerId;
  final customLatLng latLng;
  String? markerImageSrc;
  int? width;
  int? height;
  int? offsetX;
  int? offsetY;
  int? distance;
  int? index;
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
    this.index,
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

  factory Marker.fromJson(Map<String, dynamic> json) =>
      Marker(
        markerId: json["id"],
        markerImageSrc: json["markerImageSrc"],
        latLng: customLatLng(double.parse(json["latLng"]["latitude"]), double.parse(json["latLng"]["longitude"])),
        width: json["width"],
        height: json["height"],
        offsetX: null,
        offsetY: null,
        index: json["index"],
        infoWindowText: json["place_name"],
      );

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'id': markerId,
      'latLng': {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      },
      'markerImageSrc': markerImageSrc,
      'width': width,
      'height': height,
      'x': offsetX,
      'distance': distance,
      'y': offsetY,
      'index': index,
      'place_name': infoWindowText,
    };
  }
}
