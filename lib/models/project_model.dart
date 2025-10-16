class ProjectModel {
  final String project_code;
  final String project_name;
  final bool status;

  ProjectModel(
      {required this.project_name,
      required this.project_code,
      required this.status});

  static ProjectModel fromJson(Map<String, dynamic> json) {
    return ProjectModel(
        project_name: json['project_name'] ?? '',
        project_code: json['project_code'] ?? '',
        status: json['status'] ?? false);
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return project_name.toLowerCase().contains(query) ||
        project_code.toLowerCase().contains(query);
  }
}
