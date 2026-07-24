enum ExpenseStatus { pending, approved, rejected }

class Expense {
  final String expenseId;
  final String userId;
  final String userName;
  final String categoryId;
  final String categoryName;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final ExpenseStatus status;
  final String? reviewedByManagerId;
  final String? reviewedByManagerName;
  final String? managerComment;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  Expense({
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.status,
    this.reviewedByManagerId,
    this.reviewedByManagerName,
    this.managerComment,
    this.reviewedAt,
    required this.createdAt,
  });

  static ExpenseStatus _parseStatus(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 1:
          return ExpenseStatus.approved;
        case 2:
          return ExpenseStatus.rejected;
        case 0:
        default:
          return ExpenseStatus.pending;
      }
    }
    final str = raw.toString().toLowerCase();
    if (str.contains('approved')) return ExpenseStatus.approved;
    if (str.contains('rejected')) return ExpenseStatus.rejected;
    return ExpenseStatus.pending;
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'] ?? json['ExpenseId'] ?? '',
      userId: json['userId'] ?? json['UserId'] ?? '',
      userName: json['userName'] ?? json['UserName'] ?? 'Unknown User',
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? '',
      categoryName: json['categoryName'] ?? json['CategoryName'] ?? 'General',
      description: json['description'] ?? json['Description'] ?? '',
      amount: (json['amount'] ?? json['Amount'] ?? 0.0).toDouble(),
      expenseDate: json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'])
          : (json['ExpenseDate'] != null
              ? DateTime.parse(json['ExpenseDate'])
              : DateTime.now()),
      status: _parseStatus(json['status'] ?? json['Status']),
      reviewedByManagerId:
          json['reviewedByManagerId'] ?? json['ReviewedByManagerId'],
      reviewedByManagerName:
          json['reviewedByManagerName'] ?? json['ReviewedByManagerName'],
      managerComment: json['managerComment'] ?? json['ManagerComment'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : (json['ReviewedAt'] != null
              ? DateTime.parse(json['ReviewedAt'])
              : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'userName': userName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
      'status': status.index,
      'reviewedByManagerId': reviewedByManagerId,
      'reviewedByManagerName': reviewedByManagerName,
      'managerComment': managerComment,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
