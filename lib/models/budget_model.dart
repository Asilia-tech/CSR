class BudgetModel {
  final String financial_year;
  final String total_budget;
  final String milestone;
  final String project_code;
  final String associate_project_code;
  final Map<String, dynamic> budget_map;
  final bool status;

  BudgetModel({
    required this.project_code,
    required this.milestone,
    required this.associate_project_code,
    required this.financial_year,
    required this.total_budget,
    required this.budget_map,
    required this.status,
  });

  static BudgetModel fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      financial_year: json['financial_year'] ?? '',
      milestone: json['milestone'] ?? '',
      status: json['status'] ?? false,
      budget_map: Map<String, dynamic>.from(json['budget_map'] ?? {}),
      total_budget: json['total_budget'] ?? '',
      project_code: json['project_code'] ?? '',
      associate_project_code: json['associate_project_code'] ?? '',
    );
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return associate_project_code.toLowerCase().contains(query) ||
        financial_year.toString().contains(query) ||
        project_code.toLowerCase().contains(query);
  }
}
