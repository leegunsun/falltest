import 'package:decimal/decimal.dart';

part 'lat_lng.g.dart';

class customLatLng {
  Decimal _latitude;
  Decimal _longitude;

  String get latitude => _latitude.toString();
  String get longitude => _longitude.toString();

  // String 타입의 입력 값을 받도록 생성자 변경
  customLatLng(double latitude, double longitude)
      : _latitude = Decimal.parse(latitude.toString()),
        _longitude = Decimal.parse(longitude.toString());

  factory customLatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is customLatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}