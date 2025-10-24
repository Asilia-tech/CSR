class IndicatorModel {
  final String indicator_code;
  final String indicator_name;
  final String frequency;
  final String type_of_field;
  final String beneficiary_type;
  final String project_code;
  final String project_name;
  final String associate_project_code;
  final String associate_project_name;
  final Map<String, dynamic> indicator_map;
  final Map<String, dynamic> reviewer_status;

  IndicatorModel({
    required this.reviewer_status,
    required this.indicator_code,
    required this.project_code,
    required this.associate_project_code,
    required this.project_name,
    required this.associate_project_name,
    required this.indicator_name,
    required this.frequency,
    required this.type_of_field,
    required this.beneficiary_type,
    required this.indicator_map,
  });

  static IndicatorModel fromJson(Map<String, dynamic> json) {
    return IndicatorModel(
      indicator_code: json['indicator_code'] ?? '',
      reviewer_status: json['reviewer_status'] ?? false,
      project_code: json['project_code'] ?? '',
      project_name: json['project_name'] ?? '',
      associate_project_code: json['associate_project_code'] ?? '',
      associate_project_name: json['associate_project_name'] ?? '',
      indicator_name: json['indicator_name'] ?? '',
      frequency: json['frequency'] ?? '',
      type_of_field: json['type_of_field'] ?? '',
      beneficiary_type: json['beneficiary_type'] ?? '',
      indicator_map: Map<String, dynamic>.from(json['indicator_map'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewer_status': reviewer_status,
      'indicator_code': indicator_code,
      'project_code': project_code,
      'associate_project_code': associate_project_code,
      'project_name': project_name,
      'associate_project_name': associate_project_name,
      'indicator_map': indicator_map,
      'indicator_name': indicator_name,
      'frequency': frequency,
      'type_of_field': type_of_field,
      'beneficiary_type': beneficiary_type,
    };
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return associate_project_name.toString().contains(query) ||
        project_name.toString().contains(query) ||
        indicator_name.toLowerCase().contains(query);
  }
}
