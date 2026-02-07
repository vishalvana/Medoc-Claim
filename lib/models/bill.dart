class Bill {
  final String title;
  final double amount;

  Bill({required this.title, required this.amount});

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
      };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}
