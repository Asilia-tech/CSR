class UserModel {
  final String user_id;
  final String user_name;
  final String designation;
  final String role;
  final String email_id;
  final String mobile;
  final String password;
  final String state_code;
  final String district_code;
  final String village_code;
  final Map<String, dynamic> access_control;
  final bool status;

  UserModel(
      {required this.user_id,
      required this.user_name,
      required this.designation,
      required this.role,
      required this.email_id,
      required this.mobile,
      required this.password,
      required this.state_code,
      required this.district_code,
      required this.village_code,
      required this.access_control,
      required this.status});

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
        user_id: json['user_id'] ?? '',
        user_name: json['user_name'] ?? '',
        designation: json['designation'] ?? '',
        role: json['role'] ?? '',
        email_id: json['email_id'] ?? '',
        mobile: json['mobile'] ?? '',
        password: json['password'] ?? '',
        state_code: json['state_code'] ?? '',
        district_code: json['district_code'] ?? '',
        village_code: json['village_code'] ?? '',
        access_control: Map<String, dynamic>.from(json['access_control'] ?? {}),
        status: json['status'] ?? false);
  }

  bool matchesSearch(String query) {
    query = query.toLowerCase();
    return user_name.toLowerCase().contains(query) ||
        email_id.toLowerCase().contains(query) ||
        user_id.toLowerCase().contains(query);
  }
}
