import 'package:decimal/decimal.dart';

part 'lat_lng.g.dart';

class LatLng {
  Decimal _latitude;
  Decimal _longitude;

  String get latitude => _latitude.toString();
  String get longitude => _longitude.toString();

  // String 타입의 입력 값을 받도록 생성자 변경
  LatLng(double latitude, double longitude)
      : _latitude = Decimal.parse(latitude.toString()),
        _longitude = Decimal.parse(longitude.toString());

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}