class AuthResponse {
  final String token;
  final DateTime expiresAt;
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String role; // "Admin", "Employee", or "Manager"
  final String companyId;

  AuthResponse({
    required this.token,
    required this.expiresAt,
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    required this.role,
    required this.companyId,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['Token'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : (json['ExpiresAt'] != null
              ? DateTime.parse(json['ExpiresAt'])
              : DateTime.now()),
      id: json['id'] ?? json['Id'] ?? '',
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'],
      email: json['email'] ?? json['Email'] ?? '',
      role: json['role'] ?? json['Role'] ?? 'Employee',
      companyId: json['companyId'] ?? json['CompanyId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'companyId': companyId,
    };
  }
}
