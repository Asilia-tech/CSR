class DueDiligenceModel {
  final String type;
  final bool status;
  final String duediligence_code;
  final String vendor_name;
  final String vendor_code;
  final String project_code;
  final String project_name;
  final String associate_project_code;
  final String associate_project_name;
  final String years_existence;
  final String clientele;
  final String subject_knowledge;
  final String turnaround_time;
  final String turnover;
  final Map<String, dynamic> document_map;

  DueDiligenceModel({
    required this.type,
    required this.status,
    required this.duediligence_code,
    required this.project_code,
    required this.vendor_code,
    required this.associate_project_code,
    required this.project_name,
    required this.vendor_name,
    required this.associate_project_name,
    required this.years_existence,
    required this.clientele,
    required this.subject_knowledge,
    required this.turnaround_time,
    required this.turnover,
    required this.document_map,
  });

  static DueDiligenceModel fromJson(Map<String, dynamic> json) {
    return DueDiligenceModel(
      type: json['type'] ?? '',
      duediligence_code: json['duediligence_code'] ?? '',
      status: json['status'] ?? false,
      vendor_code: json['vendor_code'] ?? '',
      project_code: json['project_code'] ?? '',
      associate_project_code: json['associate_project_code'] ?? '',
      vendor_name: json['vendor_name'] ?? '',
      project_name: json['project_name'] ?? '',
      associate_project_name: json['associate_project_name'] ?? '',
      years_existence: json['years_existence'] ?? '',
      clientele: json['clientele'] ?? '',
      subject_knowledge: json['subject_knowledge'] ?? '',
      turnaround_time: json['turnaround_time'] ?? '',
      turnover: json['turnover'] ?? '',
      document_map: Map<String, dynamic>.from(json['document_map'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      'duediligence_code': duediligence_code,
      'vendor_code': vendor_code,
      'project_code': project_code,
      'associate_project_code': associate_project_code,
      'vendor_name': vendor_name,
      'project_name': project_name,
      'associate_project_name': associate_project_name,
      'years_existence': years_existence,
      'clientele': clientele,
      'subject_knowledge': subject_knowledge,
      'turnaround_time': turnaround_time,
      'turnover': turnover,
      'document_map': document_map,
    };
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return associate_project_code.toString().contains(query) ||
        project_code.toString().contains(query) ||
        vendor_code.toLowerCase().contains(query);
  }
}
