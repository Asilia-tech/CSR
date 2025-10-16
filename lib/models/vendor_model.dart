class VendorModel {
  final String vendor_name;
  final String vendor_code;
  final String contact_person;
  final String email_id;
  final String mobile;
  final String type;
  final String role;
  final Map<String, dynamic> access_control;
  final String state_code;
  final String village_code;
  final String district_code;
  final String project_code;
  final String associate_project_code;
  final bool status;

  VendorModel({
    required this.vendor_name,
    required this.associate_project_code,
    required this.project_code,
    required this.contact_person,
    required this.email_id,
    required this.mobile,
    required this.type,
    required this.role,
    required this.access_control,
    required this.vendor_code,
    required this.state_code,
    required this.village_code,
    required this.district_code,
    required this.status,
  });

  static VendorModel fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendor_name: json['vendor_name'] ?? '',
      vendor_code: json['vendor_code'] ?? '',
      contact_person: json['contact_person'] ?? '',
      email_id: json['email_id'] ?? '',
      mobile: json['mobile'] ?? '',
      type: json['type'] ?? '',
      role: json['role'] ?? '',
      access_control: json['access_control'] ?? '',
      state_code: json['state_code'] ?? '',
      village_code: json['village_code'] ?? '',
      district_code: json['district_code'] ?? '',
      status: json['status'] ?? false,
      associate_project_code: json['associate_project_code'] ?? '',
      project_code: json['project_code'] ?? '',
    );
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return vendor_name.toLowerCase().contains(query) ||
        state_code.toString().contains(query) ||
        contact_person.toString().contains(query) ||
        district_code.toString().contains(query) ||
        vendor_code.toLowerCase().contains(query);
  }
}
