import 'user_model.dart';

class SignUpUserDTO {
  final String companyId;
  final String firstName;
  final String? lastName;
  final String email;
  final String password;
  final UserRole userRole; // 0: Manager, 1: Employee

  SignUpUserDTO({
    required this.companyId,
    required this.firstName,
    this.lastName,
    required this.email,
    required this.password,
    required this.userRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'userRole': userRole.index,
    };
  }
}

class LoginUserDTO {
  final String email;
  final String password;

  LoginUserDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class CreateExpenseDTO {
  final String categoryId;
  final String description;
  final double amount;
  final DateTime expenseDate;

  CreateExpenseDTO({
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.expenseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
    };
  }
}

class UpdateExpenseDTO {
  final String categoryId;
  final String description;
  final double amount;
  final DateTime expenseDate;

  UpdateExpenseDTO({
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.expenseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
    };
  }
}

class ReviewExpenseDTO {
  final String expenseId;
  final bool approve;
  final String? comment;

  ReviewExpenseDTO({
    required this.expenseId,
    required this.approve,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'approve': approve,
      'comment': comment,
    };
  }
}

class CreateUserDTO {
  final String firstName;
  final String? lastName;
  final String email;
  final String password;
  final UserRole userRole;
  final String? managerId;

  CreateUserDTO({
    required this.firstName,
    this.lastName,
    required this.email,
    required this.password,
    required this.userRole,
    this.managerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'userRole': userRole.index,
      'managerId': managerId,
    };
  }
}

class ApproveSignupDTO {
  final String userId;
  final UserRole userRole;
  final String? managerId;

  ApproveSignupDTO({
    required this.userId,
    required this.userRole,
    this.managerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userRole': userRole.index,
      'managerId': managerId,
    };
  }
}

class RejectSignupDTO {
  final String userId;

  RejectSignupDTO({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
    };
  }
}

class AssignManagerDTO {
  final String userId;
  final String? managerId;

  AssignManagerDTO({required this.userId, this.managerId});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'managerId': managerId,
    };
  }
}

class ChangeRoleDTO {
  final String userId;
  final UserRole newRole;

  ChangeRoleDTO({required this.userId, required this.newRole});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'newRole': newRole.index,
    };
  }
}
