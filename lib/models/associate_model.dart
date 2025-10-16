class AssociateModel {
  final String associate_project_name;
  final String associate_project_code;
  final String project_code;
  final String project_name;
  final String start_date;
  final String end_date;
  final String financial_year;
  final String contact_person;
  final String email_id;
  final String mobile;
  final List<String> state_code;
  final List<String> district_code;
  final List<String> village_code;
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
      required this.contact_person,
      required this.financial_year,
      required this.email_id,
      required this.mobile,
      required this.state_code,
      required this.district_code,
      required this.village_code,
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
      contact_person: json['contact_person'] ?? '',
      email_id: json['email_id'] ?? '',
      mobile: json['mobile'] ?? '',
      state_code: List<String>.from(json['state_code'] ?? []),
      district_code: List<String>.from(json['district_code'] ?? []),
      village_code: List<String>.from(json['village_code'] ?? []),
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
        contact_person.toString().contains(query) ||
        associate_project_code.toLowerCase().contains(query) ||
        project_code.toLowerCase().contains(query);
  }
}
