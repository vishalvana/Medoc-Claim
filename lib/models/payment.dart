class Payment {
  final double amount;

  Payment(this.amount);

  Map<String, dynamic> toJson() => {'amount': amount};

  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment((json['amount'] as num).toDouble());
}
