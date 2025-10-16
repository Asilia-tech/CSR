class VillageModel {
  final String name;
  final String village_code;
  final String state_code;
  final String district_code;
  final bool status;

  VillageModel(
      {required this.name,
      required this.village_code,
      required this.district_code,
      required this.state_code,
      required this.status});

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return name.toLowerCase().contains(query) ||
        state_code.toString().contains(query) ||
        district_code.toString().contains(query) ||
        village_code.toLowerCase().contains(query);
  }

  static VillageModel fromJson(item) {
    return VillageModel(
        name: item['name'] ?? "",
        village_code: item['village_code'] ?? "",
        district_code: item['district_code'] ?? "",
        state_code: item['state_code'] ?? "",
        status: item['status'] ?? true);
  }
}
