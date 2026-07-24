enum UserRole { manager, employee }
enum UserApprovalStatus { pending, approved, rejected }

class UserModel {
  final String userId;
  final String firstName;
  final String? lastName;
  final String email;
  final UserRole userRole;
  final String? managerId;
  final String? managerName;
  final UserApprovalStatus approvalStatus;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.firstName,
    this.lastName,
    required this.email,
    required this.userRole,
    this.managerId,
    this.managerName,
    required this.approvalStatus,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  static UserRole _parseUserRole(dynamic raw) {
    if (raw is int) {
      return raw == 0 ? UserRole.manager : UserRole.employee;
    }
    final str = raw.toString().toLowerCase();
    if (str.contains('manager')) return UserRole.manager;
    return UserRole.employee;
  }

  static UserApprovalStatus _parseApprovalStatus(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 1:
          return UserApprovalStatus.approved;
        case 2:
          return UserApprovalStatus.rejected;
        case 0:
        default:
          return UserApprovalStatus.pending;
      }
    }
    final str = raw.toString().toLowerCase();
    if (str.contains('approved')) return UserApprovalStatus.approved;
    if (str.contains('rejected')) return UserApprovalStatus.rejected;
    return UserApprovalStatus.pending;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['UserId'] ?? '',
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'],
      email: json['email'] ?? json['Email'] ?? '',
      userRole: _parseUserRole(json['userRole'] ?? json['UserRole']),
      managerId: json['managerId'] ?? json['ManagerId'],
      managerName: json['managerName'] ?? json['ManagerName'],
      approvalStatus: _parseApprovalStatus(
          json['approvalStatus'] ?? json['ApprovalStatus']),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userRole': userRole.index,
      'managerId': managerId,
      'managerName': managerName,
      'approvalStatus': approvalStatus.index,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
