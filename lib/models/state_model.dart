class StateModel {
  final String name;
  final String state_code;
  final String country_code;
  final bool status;

  StateModel(
      {required this.name,
      required this.state_code,
      required this.country_code,
      required this.status});

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return name.toLowerCase().contains(query) ||
        state_code.toLowerCase().contains(query);
  }

  static StateModel fromJson(item) {
    return StateModel(
        name: item['name'] ?? '',
        state_code: item['state_code'] ?? '',
        country_code: item['country_code'] ?? '',
        status: item['status'] ?? false);
  }
}
