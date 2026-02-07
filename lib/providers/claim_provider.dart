import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../models/bill.dart';
import '../models/payment.dart';

class ClaimProvider extends ChangeNotifier {
  final List<Claim> _claims = [];

  List<Claim> get claims => _claims;

  // ---------------- CLAIM ----------------

  void addClaim(Claim claim) {
    _claims.add(claim);
    notifyListeners();
  }

  void deleteClaim(Claim claim) {
    _claims.remove(claim);
    notifyListeners();
  }

  void updateStatus(Claim claim, ClaimStatus status) {
    claim.status = status;
    notifyListeners();
  }

  // ---------------- BILL ----------------

  void addBill(Claim claim, Bill bill) {
    claim.addBill(bill);
    notifyListeners();
  }

  void updateBill(Claim claim, int index, Bill bill) {
    claim.updateBill(index, bill);
    notifyListeners();
  }

  void removeBill(Claim claim, int index) {
    claim.removeBill(index);
    notifyListeners();
  }

  // ---------------- ADVANCE ----------------

  void addAdvance(Claim claim, Payment adv) {
    claim.addAdvance(adv);
    notifyListeners();
  }

  void removeAdvance(Claim claim, int index) {
    claim.removeAdvance(index);
    notifyListeners();
  }

  // ---------------- SETTLEMENT ----------------

  void addSettlement(Claim claim, Payment s) {
    claim.addSettlement(s);
    notifyListeners();
  }

  void addDummyClaimsIfEmpty() {
    if (_claims.isNotEmpty) return;

    _claims.addAll([
      Claim(
        patientName: 'Utkarsh',
        status: ClaimStatus.approved,
        bills: [],
        advances: [],
        settlements: [],
      ),
      Claim(
        patientName: 'Vishal Vana',
        status: ClaimStatus.submitted,
        bills: [],
        advances: [],
        settlements: [],
      ),
    ]);

    notifyListeners();
  }

  void removeSettlement(Claim claim, int index) {
    claim.removeSettlement(index);
    notifyListeners();
  }
}
