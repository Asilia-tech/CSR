class LocationData {
  final String state_code;
  final String state_name;
  final List<District> districts;

  LocationData({
    required this.state_code,
    required this.state_name,
    required this.districts,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      state_code: json['state_code'],
      state_name: json['state_name'],
      districts:
          (json['districts'] as List).map((d) => District.fromJson(d)).toList(),
    );
  }
}

class District {
  final String district_code;
  final String district_name;
  final List<Village> villages;

  District({
    required this.district_code,
    required this.district_name,
    required this.villages,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      district_code: json['district_code'],
      district_name: json['district_name'],
      villages:
          (json['villages'] as List).map((v) => Village.fromJson(v)).toList(),
    );
  }
}

class Village {
  final String village_code;
  final String village_name;

  Village({
    required this.village_code,
    required this.village_name,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      village_code: json['village_code'],
      village_name: json['village_name'],
    );
  }
}
