import 'bill.dart';
import 'payment.dart';

enum ClaimStatus { draft, submitted, approved, rejected, partiallySettled }

class Claim {
  final String patientName;
  ClaimStatus status;

  List<Bill> bills;
  List<Payment> advances;
  List<Payment> settlements;

  Claim({
    required this.patientName,
    this.status = ClaimStatus.draft,
    List<Bill>? bills,
    List<Payment>? advances,
    List<Payment>? settlements,
  })  : bills = bills ?? [],
        advances = advances ?? [],
        settlements = settlements ?? [];

  double get totalBills => bills.fold(0.0, (sum, b) => sum + b.amount);

  double get totalAdvances => advances.fold(0.0, (sum, a) => sum + a.amount);

  double get totalSettlements =>
      settlements.fold(0.0, (sum, s) => sum + s.amount);

  double get pendingAmount => totalBills - totalAdvances - totalSettlements;

  // Helpers to modify lists
  void addBill(Bill bill) => bills.add(bill);
  void updateBill(int index, Bill bill) => bills[index] = bill;
  void removeBill(int index) => bills.removeAt(index);

  void addAdvance(Payment adv) => advances.add(adv);
  void removeAdvance(int index) => advances.removeAt(index);

  void addSettlement(Payment s) => settlements.add(s);
  void removeSettlement(int index) => settlements.removeAt(index);

  Map<String, dynamic> toJson() => {
        'patientName': patientName,
        'status': status.index,
        'bills': bills.map((b) => b.toJson()).toList(),
        'advances': advances.map((a) => a.toJson()).toList(),
        'settlements': settlements.map((s) => s.toJson()).toList(),
      };

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      patientName: json['patientName'] as String,
      status: ClaimStatus.values[(json['status'] as num).toInt()],
      bills: (json['bills'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      advances: (json['advances'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
