// To parse this JSON data, do
//
//     final listOfConverdsations = crimeFromJson(jsonString);

import 'dart:convert';

Crime crimeFromJson(String str) => Crime.fromJson(json.decode(str));

String crimeToJson(Crime data) => json.encode(data.toJson());

class Crime {
  Crime({
    this.lng,
    this.crimeDesc,
    this.lat,
    this.id
  });

  String id;
  double lng;
  String crimeDesc;
  double lat;

  factory Crime.fromJson(Map<String, dynamic> json) => Crime(
        lng: json["lng"].toDouble(),
        crimeDesc: json["crime_desc"],
        lat: json["lat"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lng": lng,
        "crime_desc": crimeDesc,
        "lat": lat,
      };
}
