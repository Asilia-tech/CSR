class AssociateModel {
  final String associate_project_name;
  final String associate_project_code;
  final String project_code;
  final String project_name;
  final String start_date;
  final String end_date;
  final String financial_year;
  final String local_csr_name;
  final String local_csr_id;
  final String email_id;
  final String mobile;
  final List<Map<String, dynamic>> location;
  final String total_budget;
  final String milestone;
  final String ENFAID;
  final String entity;
  final String budget_source;
  final String focus_area;
  final bool status;

  AssociateModel(
      {required this.project_code,
      required this.associate_project_name,
      required this.associate_project_code,
      required this.local_csr_name,
      required this.local_csr_id,
      required this.financial_year,
      required this.email_id,
      required this.mobile,
      required this.location,
      required this.project_name,
      required this.start_date,
      required this.end_date,
      required this.total_budget,
      required this.milestone,
      required this.ENFAID,
      required this.entity,
      required this.budget_source,
      required this.focus_area,
      required this.status});

  static AssociateModel fromJson(Map<String, dynamic> json) {
    return AssociateModel(
      financial_year: json['financial_year'] ?? '',
      project_code: json['project_code'] ?? '',
      associate_project_name: json['associate_project_name'] ?? '',
      associate_project_code: json['associate_project_code'] ?? '',
      local_csr_name: json['local_csr_name'] ?? '',
      local_csr_id: json['local_csr_id'] ?? '',
      email_id: json['email_id'] ?? '',
      mobile: json['mobile'] ?? '',
      location: List<Map<String, dynamic>>.from(json['location'] ?? []),
      status: json['status'] ?? false,
      project_name: json['project_name'] ?? '',
      start_date: json['start_date'] ?? '',
      end_date: json['end_date'] ?? '',
      total_budget: json['total_budget'] ?? '',
      milestone: json['milestone'] ?? '',
      ENFAID: json['ENFAID'] ?? '',
      entity: json['entity'] ?? '',
      budget_source: json['budget_source'] ?? '',
      focus_area: json['focus_area'] ?? '',
    );
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return associate_project_name.toLowerCase().contains(query) ||
        local_csr_name.toString().contains(query) ||
        associate_project_code.toLowerCase().contains(query) ||
        project_code.toLowerCase().contains(query);
  }
}
