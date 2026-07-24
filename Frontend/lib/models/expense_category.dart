class ExpenseCategory {
  final String categoryId;
  final String categoryName;

  ExpenseCategory({
    required this.categoryId,
    required this.categoryName,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? '',
      categoryName: json['categoryName'] ?? json['CategoryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
