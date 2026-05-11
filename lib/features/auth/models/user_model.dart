class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? studentNo;
  final String? department;
  final bool verified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentNo,
    this.department,
    required this.verified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      studentNo: json['student_no'],
      department: json['department'],
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'student_no': studentNo,
      'department': department,
      'verified': verified,
    };
  }
}
