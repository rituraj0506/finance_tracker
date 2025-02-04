class FinanceData {
  final String id;
  final String selectedCategory;
  final String amount;
  final String date;
  final String description;
  final double totalBalance;

  FinanceData({
    required this.id,
    required this.selectedCategory,
    required this.amount,
    required this.date,
    required this.description,
    required this.totalBalance,
  });

  // Factory method to create an instance from JSON
  factory FinanceData.fromJson(Map<String, dynamic> json, String id) {
    return FinanceData(
      id: id,
      selectedCategory: json['selectedCategory'] as String,
      amount: json['amount'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      totalBalance: (json['_totalBalance'] ?? 0.0) as double,
    );
  }

  // Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedCategory': selectedCategory,
      'amount': amount,
      'date': date,
      'description': description,
      '_totalBalance': totalBalance,
    };
  }
}
