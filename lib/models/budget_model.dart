class BudgetModel {
  final String name;
  final String budget_code;
  final String financial_year;
  final String state_code;
  final String district_code;
  final String village_code;
  final String total_budget;
  final String project_code;
  final String milestone;
  final String associate_project_code;
  final Map<String, dynamic> budget_map;
  final bool status;

  BudgetModel({
    required this.name,
    required this.budget_code,
    required this.project_code,
    required this.milestone,
    required this.associate_project_code,
    required this.financial_year,
    required this.state_code,
    required this.district_code,
    required this.village_code,
    required this.total_budget,
    required this.budget_map,
    required this.status,
  });

  static BudgetModel fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      name: json['name'] ?? '',
      budget_code: json['budget_code'] ?? '',
      financial_year: json['financial_year'] ?? '',
      milestone: json['milestone'] ?? '',
      state_code: json['state_code'] ?? '',
      status: json['status'] ?? false,
      budget_map: Map<String, dynamic>.from(json['budget_map'] ?? {}),
      district_code: json['district_code'] ?? '',
      village_code: json['village_code'] ?? '',
      total_budget: json['total_budget'] ?? '',
      project_code: json['project_code'] ?? '',
      associate_project_code: json['associate_project_code'] ?? '',
    );
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return name.toLowerCase().contains(query) ||
        financial_year.toString().contains(query) ||
        budget_code.toLowerCase().contains(query);
  }
}
