class FinancialModel {
  final String name;
  final String financial_year_code;
  final bool status;

  FinancialModel(
      {required this.name,
      required this.financial_year_code,
      required this.status});

  static FinancialModel fromJson(Map<String, dynamic> json) {
    return FinancialModel(
        name: json['name'] ?? '',
        financial_year_code: json['financial_year_code'] ?? '',
        status: json['status'] ?? false);
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return name.toLowerCase().contains(query) ||
        financial_year_code.toLowerCase().contains(query);
  }
}
