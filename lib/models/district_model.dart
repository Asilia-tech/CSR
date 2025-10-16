class DistrictModel {
  final String name;
  final String district_code;
  final String state_code;
  final bool status;
  
  DistrictModel(
      {required this.name,
      required this.district_code,
      required this.state_code,
      required this.status});

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return name.toLowerCase().contains(query) ||
        state_code.toString().contains(query) ||
        district_code.toLowerCase().contains(query);
  }

  static DistrictModel fromJson(item) {
    return DistrictModel(
        name: item['name'] ?? "",
        district_code: item['district_code'] ?? "",
        state_code: item['state_code'] ?? "",
        status: item['status'] ?? false);
  }
}
